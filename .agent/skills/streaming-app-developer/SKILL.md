---
name: streaming-app-developer
description: "Expert streaming platform development including video/audio streaming, HLS/DASH, live streaming, content delivery, recommendations, multi-profile, DRM, and OTT applications"
---

# Streaming App Developer

## Overview

Expert in building **Netflix/Viu-grade streaming platforms**. Covers **HLS/DASH streaming**, **transcoding**, **DRM protection**, **recommendation engine**, **multi-profile accounts**, **offline download**, and **content discovery**.

## When to Use This Skill

- Building video-on-demand (VOD) platforms like Netflix, Viu, Disney+
- Implementing live streaming features
- Creating music/podcast streaming apps (Spotify-style)
- Building OTT (Over-The-Top) applications
- Implementing content protection and DRM

---

## Part 1: Streaming Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      OTT Streaming Platform                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Ingest &   │  │  Transcode   │  │    DRM &     │  │     CDN      │ │
│  │   Upload     │→ │  Pipeline    │→ │  Packaging   │→ │   Delivery   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Multi-     │  │  Content     │  │ Recommendation│  │  Analytics   │ │
│  │   Profile    │  │  Discovery   │  │    Engine     │  │  & Metrics   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Subscription │  │   Offline    │  │   Watchlist  │  │   Stream     │ │
│  │   Billing    │  │   Download   │  │   & Lists    │  │   Limiter    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Streaming Protocols

| Protocol | Use Case | Latency | DRM Support |
|----------|----------|---------|-------------|
| **HLS** | VOD, most compatible | 10-30s | FairPlay |
| **DASH** | VOD, adaptive | 10-30s | Widevine, PlayReady |
| **LL-HLS** | Low-latency live | 2-5s | FairPlay |
| **CMAF** | Universal packaging | Variable | All |

---

## Part 2: Database Schema

### 2.1 Core Content Tables

```sql
-- Content (Movies, Series)
CREATE TABLE contents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    original_title VARCHAR(255),
    description TEXT,
    type VARCHAR(20) NOT NULL,  -- 'movie', 'series'
    
    -- Media
    duration_seconds INTEGER,
    thumbnail_url TEXT,
    poster_url TEXT,
    backdrop_url TEXT,
    trailer_url TEXT,
    logo_url TEXT,
    
    -- Streaming
    hls_url TEXT,
    dash_url TEXT,
    drm_key_id VARCHAR(100),
    
    -- Metadata
    release_year INTEGER,
    release_date DATE,
    genres UUID[],
    tags TEXT[],
    cast_members JSONB,      -- [{name, role, photo}]
    directors TEXT[],
    studio VARCHAR(200),
    
    -- Region/Language
    original_language VARCHAR(10),
    available_languages TEXT[],
    subtitle_languages TEXT[],
    available_regions TEXT[],
    
    -- Ratings
    maturity_rating VARCHAR(10),  -- 'G', 'PG', 'PG-13', 'R', 'NC-17', '13+', '17+'
    imdb_rating DECIMAL(3, 1),
    rating_avg DECIMAL(3, 2) DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    
    -- Access
    is_premium BOOLEAN DEFAULT false,
    is_original BOOLEAN DEFAULT false,  -- Platform original
    is_published BOOLEAN DEFAULT false,
    
    -- SEO
    slug VARCHAR(255) UNIQUE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_contents_type ON contents(type);
CREATE INDEX idx_contents_genres ON contents USING GIN(genres);
CREATE INDEX idx_contents_regions ON contents USING GIN(available_regions);

-- Series Seasons
CREATE TABLE seasons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    series_id UUID REFERENCES contents(id) ON DELETE CASCADE,
    season_number INTEGER NOT NULL,
    title VARCHAR(255),
    description TEXT,
    poster_url TEXT,
    release_date DATE,
    episode_count INTEGER DEFAULT 0,
    
    UNIQUE(series_id, season_number)
);

-- Episodes
CREATE TABLE episodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    season_id UUID REFERENCES seasons(id) ON DELETE CASCADE,
    episode_number INTEGER NOT NULL,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration_seconds INTEGER,
    thumbnail_url TEXT,
    
    -- Streaming
    hls_url TEXT,
    dash_url TEXT,
    drm_key_id VARCHAR(100),
    
    is_published BOOLEAN DEFAULT false,
    release_date DATE,
    
    UNIQUE(season_id, episode_number)
);

-- Genres
CREATE TABLE genres (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon_url TEXT,
    sort_order INTEGER DEFAULT 0
);
```

### 2.2 Multi-Profile System

```sql
-- User Profiles (Netflix-style)
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    name VARCHAR(50) NOT NULL,
    avatar_url TEXT,
    
    -- Settings
    is_kids BOOLEAN DEFAULT false,
    maturity_level VARCHAR(10) DEFAULT '17+',  -- Max rating allowed
    language VARCHAR(10) DEFAULT 'id',
    subtitle_language VARCHAR(10),
    autoplay_next BOOLEAN DEFAULT true,
    autoplay_previews BOOLEAN DEFAULT true,
    
    -- PIN lock
    pin_protected BOOLEAN DEFAULT false,
    pin_hash VARCHAR(255),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT max_profiles CHECK (
        (SELECT COUNT(*) FROM profiles WHERE account_id = account_id) <= 5
    )
);

CREATE INDEX idx_profiles_account ON profiles(account_id);

-- Watch History (per profile)
CREATE TABLE watch_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content_id UUID REFERENCES contents(id),
    episode_id UUID REFERENCES episodes(id),
    
    position_seconds INTEGER DEFAULT 0,
    duration_watched INTEGER DEFAULT 0,
    watch_percent DECIMAL(5, 2) DEFAULT 0,
    completed BOOLEAN DEFAULT false,
    
    last_watched_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(profile_id, content_id, episode_id)
);

CREATE INDEX idx_watch_history_profile ON watch_history(profile_id, last_watched_at DESC);

-- Watchlist / My List
CREATE TABLE watchlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content_id UUID REFERENCES contents(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(profile_id, content_id)
);

-- Likes/Dislikes (for recommendations)
CREATE TABLE content_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content_id UUID REFERENCES contents(id) ON DELETE CASCADE,
    rating VARCHAR(10) NOT NULL,  -- 'like', 'dislike', 'love'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(profile_id, content_id)
);
```

### 2.3 Subscription & Stream Control

```sql
-- Subscription Plans
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    
    -- Pricing
    price_monthly DECIMAL(10, 2) NOT NULL,
    price_yearly DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'IDR',
    
    -- Features
    max_profiles INTEGER DEFAULT 1,
    max_concurrent_streams INTEGER DEFAULT 1,
    max_video_quality VARCHAR(10) DEFAULT '1080p',  -- '480p', '720p', '1080p', '4k'
    download_enabled BOOLEAN DEFAULT false,
    ads_enabled BOOLEAN DEFAULT true,
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0
);

-- User Subscriptions
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    plan_id UUID REFERENCES subscription_plans(id),
    
    status VARCHAR(20) DEFAULT 'active',  -- 'active', 'cancelled', 'expired', 'paused'
    started_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    
    -- Payment
    payment_provider VARCHAR(50),
    external_subscription_id VARCHAR(255),
    auto_renew BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Active Stream Sessions (for concurrent limit)
CREATE TABLE active_streams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    profile_id UUID REFERENCES profiles(id),
    
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(100),
    device_type VARCHAR(50),  -- 'web', 'mobile', 'tv', 'tablet'
    
    content_id UUID REFERENCES contents(id),
    episode_id UUID REFERENCES episodes(id),
    
    started_at TIMESTAMPTZ DEFAULT NOW(),
    last_heartbeat TIMESTAMPTZ DEFAULT NOW(),
    
    ip_address INET,
    
    UNIQUE(user_id, device_id)
);

CREATE INDEX idx_active_streams_user ON active_streams(user_id);
```

---

## Part 3: Video Processing & DRM

### 3.1 Transcoding with DRM Packaging

```typescript
// services/transcoding.service.ts
import { exec } from 'child_process';

const QUALITY_PRESETS = [
  { name: '360p', width: 640, height: 360, bitrate: '800k', profile: 'main' },
  { name: '480p', width: 854, height: 480, bitrate: '1400k', profile: 'main' },
  { name: '720p', width: 1280, height: 720, bitrate: '2800k', profile: 'high' },
  { name: '1080p', width: 1920, height: 1080, bitrate: '5000k', profile: 'high' },
  { name: '4k', width: 3840, height: 2160, bitrate: '15000k', profile: 'high' },
];

export class TranscodingService {
  async processWithDRM(contentId: string, inputPath: string): Promise<void> {
    const outputDir = `/tmp/transcode/${contentId}`;
    await fs.mkdir(outputDir, { recursive: true });
    
    // 1. Transcode to multiple qualities
    for (const preset of QUALITY_PRESETS) {
      await this.transcodeQuality(inputPath, outputDir, preset);
    }
    
    // 2. Generate encryption keys
    const { keyId, key } = await this.generateDRMKeys();
    
    // 3. Package with DRM (using Shaka Packager)
    await this.packageWithDRM(outputDir, keyId, key);
    
    // 4. Upload to CDN
    const urls = await this.uploadToCDN(contentId, outputDir);
    
    // 5. Store key in license server
    await this.storeDRMKey(contentId, keyId, key);
    
    // 6. Update database
    await db.contents.update({
      where: { id: contentId },
      data: {
        hlsUrl: urls.hls,
        dashUrl: urls.dash,
        drmKeyId: keyId,
        status: 'ready',
      },
    });
  }
  
  private async packageWithDRM(
    outputDir: string,
    keyId: string,
    key: string
  ): Promise<void> {
    // Using Shaka Packager for DRM
    const command = `packager \
      'in=${outputDir}/1080p.mp4,stream=video,output=${outputDir}/video_1080p.mp4' \
      'in=${outputDir}/720p.mp4,stream=video,output=${outputDir}/video_720p.mp4' \
      'in=${outputDir}/480p.mp4,stream=video,output=${outputDir}/video_480p.mp4' \
      'in=${outputDir}/1080p.mp4,stream=audio,output=${outputDir}/audio.mp4' \
      --enable_widevine_encryption \
      --key_server_url https://license.yourplatform.com/request \
      --content_id ${keyId} \
      --signer yourplatform \
      --mpd_output ${outputDir}/manifest.mpd \
      --hls_master_playlist_output ${outputDir}/master.m3u8`;
    
    await this.execAsync(command);
  }
  
  private async generateDRMKeys(): Promise<{ keyId: string; key: string }> {
    const keyId = crypto.randomBytes(16).toString('hex');
    const key = crypto.randomBytes(16).toString('hex');
    return { keyId, key };
  }
}
```

### 3.2 License Server Integration

```typescript
// services/drm-license.service.ts
export class DRMLicenseService {
  // Widevine license proxy
  async getWidevineicense(
    userId: string,
    contentId: string,
    licenseRequest: Buffer
  ): Promise<Buffer> {
    // Verify user has access
    const hasAccess = await this.verifyAccess(userId, contentId);
    if (!hasAccess) {
      throw new Error('Access denied');
    }
    
    // Check concurrent stream limit
    await this.checkStreamLimit(userId);
    
    // Forward to Widevine license server
    const response = await fetch(process.env.WIDEVINE_LICENSE_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/octet-stream',
        'Authorization': `Bearer ${process.env.WIDEVINE_API_KEY}`,
      },
      body: licenseRequest,
    });
    
    return Buffer.from(await response.arrayBuffer());
  }
  
  // FairPlay certificate & license (for iOS/Safari)
  async getFairPlayLicense(
    userId: string,
    contentId: string,
    spc: Buffer  // Server Playback Context
  ): Promise<Buffer> {
    const hasAccess = await this.verifyAccess(userId, contentId);
    if (!hasAccess) throw new Error('Access denied');
    
    // Get content key
    const { key } = await this.getContentKey(contentId);
    
    // Generate CKC (Content Key Context)
    const ckc = await this.generateFairPlayCKC(spc, key);
    
    return ckc;
  }
}
```

---

## Part 4: Concurrent Stream Limiter

```typescript
// services/stream-limiter.service.ts
export class StreamLimiterService {
  private readonly HEARTBEAT_INTERVAL = 30000; // 30 seconds
  private readonly STREAM_TIMEOUT = 60000; // 1 minute without heartbeat
  
  async startStream(
    userId: string,
    profileId: string,
    contentId: string,
    deviceInfo: DeviceInfo
  ): Promise<{ streamToken: string }> {
    const subscription = await this.getActiveSubscription(userId);
    const maxStreams = subscription.plan.maxConcurrentStreams;
    
    // Clean up stale streams
    await this.cleanupStaleStreams(userId);
    
    // Count active streams
    const activeCount = await db.activeStreams.count({
      where: { userId },
    });
    
    if (activeCount >= maxStreams) {
      // Check if same device is reconnecting
      const existingStream = await db.activeStreams.findFirst({
        where: { userId, deviceId: deviceInfo.deviceId },
      });
      
      if (!existingStream) {
        throw new StreamLimitError(
          `Batas streaming tercapai (${maxStreams} perangkat). ` +
          'Hentikan streaming di perangkat lain untuk melanjutkan.'
        );
      }
    }
    
    // Create/update stream session
    const streamToken = crypto.randomUUID();
    
    await db.activeStreams.upsert({
      where: {
        userId_deviceId: { userId, deviceId: deviceInfo.deviceId },
      },
      create: {
        userId,
        profileId,
        deviceId: deviceInfo.deviceId,
        deviceName: deviceInfo.deviceName,
        deviceType: deviceInfo.deviceType,
        contentId,
        ipAddress: deviceInfo.ipAddress,
      },
      update: {
        profileId,
        contentId,
        lastHeartbeat: new Date(),
      },
    });
    
    return { streamToken };
  }
  
  async heartbeat(userId: string, deviceId: string): Promise<void> {
    await db.activeStreams.updateMany({
      where: { userId, deviceId },
      data: { lastHeartbeat: new Date() },
    });
  }
  
  async stopStream(userId: string, deviceId: string): Promise<void> {
    await db.activeStreams.deleteMany({
      where: { userId, deviceId },
    });
  }
  
  private async cleanupStaleStreams(userId: string): Promise<void> {
    const timeout = new Date(Date.now() - this.STREAM_TIMEOUT);
    
    await db.activeStreams.deleteMany({
      where: {
        userId,
        lastHeartbeat: { lt: timeout },
      },
    });
  }
  
  async getActiveDevices(userId: string): Promise<ActiveStream[]> {
    return db.activeStreams.findMany({
      where: { userId },
      orderBy: { startedAt: 'desc' },
    });
  }
  
  async forceStopDevice(userId: string, deviceId: string): Promise<void> {
    await db.activeStreams.deleteMany({
      where: { userId, deviceId },
    });
    
    // Notify device via WebSocket/Push
    await this.notifyDeviceKicked(deviceId);
  }
}
```

---

## Part 5: Recommendation Engine

```typescript
// services/recommendation.service.ts
export class RecommendationService {
  // Get personalized home page rows
  async getHomeRows(profileId: string): Promise<ContentRow[]> {
    const profile = await db.profiles.findUnique({
      where: { id: profileId },
      include: { watchHistory: true, ratings: true },
    });
    
    const rows: ContentRow[] = [];
    
    // 1. Continue Watching
    const continueWatching = await this.getContinueWatching(profileId);
    if (continueWatching.length > 0) {
      rows.push({
        id: 'continue-watching',
        title: 'Lanjutkan Menonton',
        type: 'continue_watching',
        contents: continueWatching,
      });
    }
    
    // 2. My List
    const myList = await this.getWatchlist(profileId);
    if (myList.length > 0) {
      rows.push({
        id: 'my-list',
        title: 'Daftar Saya',
        type: 'watchlist',
        contents: myList,
      });
    }
    
    // 3. Trending Now
    rows.push({
      id: 'trending',
      title: 'Sedang Trending',
      type: 'trending',
      contents: await this.getTrending(),
    });
    
    // 4. Personalized: Because you watched X
    const recentlyWatched = profile.watchHistory
      .filter(h => h.completed)
      .sort((a, b) => b.lastWatchedAt - a.lastWatchedAt)
      .slice(0, 3);
    
    for (const watched of recentlyWatched) {
      const similar = await this.getSimilarContent(watched.contentId);
      if (similar.length > 0) {
        const content = await db.contents.findUnique({ where: { id: watched.contentId } });
        rows.push({
          id: `because-${watched.contentId}`,
          title: `Karena Anda Menonton ${content.title}`,
          type: 'similar',
          contents: similar,
        });
      }
    }
    
    // 5. Top 10 in Indonesia
    rows.push({
      id: 'top-10',
      title: 'Top 10 di Indonesia',
      type: 'top_10',
      contents: await this.getTop10('ID'),
    });
    
    // 6. Genre-based rows
    const preferredGenres = await this.getPreferredGenres(profileId);
    for (const genre of preferredGenres.slice(0, 3)) {
      rows.push({
        id: `genre-${genre.id}`,
        title: genre.name,
        type: 'genre',
        genreId: genre.id,
        contents: await this.getByGenre(genre.id, profile.maturityLevel),
      });
    }
    
    // 7. New Releases
    rows.push({
      id: 'new-releases',
      title: 'Baru Ditambahkan',
      type: 'new',
      contents: await this.getNewReleases(),
    });
    
    // 8. Platform Originals
    rows.push({
      id: 'originals',
      title: 'Original Series',
      type: 'originals',
      contents: await this.getOriginals(),
    });
    
    return rows;
  }
  
  async getSimilarContent(contentId: string, limit = 20): Promise<Content[]> {
    const content = await db.contents.findUnique({
      where: { id: contentId },
    });
    
    // Find by same genres, cast, directors
    return db.contents.findMany({
      where: {
        id: { not: contentId },
        isPublished: true,
        OR: [
          { genres: { hasSome: content.genres } },
          { directors: { hasSome: content.directors } },
        ],
      },
      orderBy: [
        { ratingAvg: 'desc' },
        { releaseDate: 'desc' },
      ],
      take: limit,
    });
  }
  
  private async getPreferredGenres(profileId: string): Promise<Genre[]> {
    // Analyze watch history to find preferred genres
    const history = await db.watchHistory.findMany({
      where: { profileId, completed: true },
      include: { content: true },
      take: 50,
    });
    
    const genreCount = new Map<string, number>();
    
    for (const h of history) {
      for (const genreId of h.content.genres || []) {
        genreCount.set(genreId, (genreCount.get(genreId) || 0) + 1);
      }
    }
    
    const sortedGenres = [...genreCount.entries()]
      .sort((a, b) => b[1] - a[1])
      .map(([id]) => id);
    
    return db.genres.findMany({
      where: { id: { in: sortedGenres } },
    });
  }
  
  private async getContinueWatching(profileId: string): Promise<ContinueWatchingItem[]> {
    return db.watchHistory.findMany({
      where: {
        profileId,
        completed: false,
        watchPercent: { gte: 5, lt: 95 },  // Started but not finished
      },
      include: {
        content: true,
        episode: { include: { season: true } },
      },
      orderBy: { lastWatchedAt: 'desc' },
      take: 20,
    });
  }
}
```

---

## Part 6: Offline Download

```typescript
// services/download.service.ts
export class DownloadService {
  async requestDownload(
    userId: string,
    profileId: string,
    contentId: string,
    episodeId?: string,
    quality: string = '720p'
  ): Promise<DownloadToken> {
    // Verify subscription allows downloads
    const subscription = await this.getSubscription(userId);
    if (!subscription.plan.downloadEnabled) {
      throw new Error('Paket Anda tidak mendukung download');
    }
    
    // Check download limit (e.g., max 25 downloads)
    const downloadCount = await db.downloads.count({
      where: { profileId, status: 'completed' },
    });
    
    if (downloadCount >= 25) {
      throw new Error('Batas download tercapai (25 konten)');
    }
    
    // Generate download manifest with offline license
    const content = episodeId
      ? await db.episodes.findUnique({ where: { id: episodeId } })
      : await db.contents.findUnique({ where: { id: contentId } });
    
    // Get quality-specific URL
    const videoUrl = await this.getQualityUrl(content, quality);
    
    // Generate offline license (valid for 48 hours typically)
    const offlineLicense = await this.generateOfflineLicense(
      userId,
      content.drmKeyId,
      48 * 60 * 60  // 48 hours in seconds
    );
    
    // Create download record
    const download = await db.downloads.create({
      data: {
        profileId,
        contentId,
        episodeId,
        quality,
        expiresAt: addHours(new Date(), 48),
        status: 'pending',
      },
    });
    
    return {
      downloadId: download.id,
      manifestUrl: videoUrl,
      offlineLicense,
      expiresAt: download.expiresAt,
    };
  }
  
  async validateOfflinePlayback(
    downloadId: string,
    deviceId: string
  ): Promise<boolean> {
    const download = await db.downloads.findUnique({
      where: { id: downloadId },
    });
    
    if (!download) return false;
    if (download.expiresAt < new Date()) {
      // Expired - need to re-download or go online
      return false;
    }
    
    return true;
  }
}
```

---

## Part 7: Video Player

```typescript
// React Netflix-style player with all features
import Hls from 'hls.js';

function VideoPlayer({
  content,
  episode,
  profileId,
  onProgress,
  onComplete,
}: VideoPlayerProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [quality, setQuality] = useState('auto');
  const [showControls, setShowControls] = useState(true);
  const [subtitleTrack, setSubtitleTrack] = useState<number>(-1);
  const [audioTrack, setAudioTrack] = useState<number>(0);
  
  // Initialize HLS with DRM
  useEffect(() => {
    if (!videoRef.current) return;
    
    const video = videoRef.current;
    
    if (video.canPlayType('application/vnd.apple.mpegurl')) {
      // Safari - native HLS + FairPlay
      video.src = content.hlsUrl;
      setupFairPlay(video, content.id);
    } else if (Hls.isSupported()) {
      // Other browsers - HLS.js + Widevine
      const hls = new Hls({
        widevineLicenseUrl: `/api/drm/license?contentId=${content.id}`,
        emeEnabled: true,
      });
      
      hls.loadSource(content.hlsUrl);
      hls.attachMedia(video);
      
      return () => hls.destroy();
    }
  }, [content]);
  
  // Resume from last position
  useEffect(() => {
    if (episode?.resumePosition) {
      videoRef.current.currentTime = episode.resumePosition;
    }
  }, [episode]);
  
  // Save progress periodically
  useEffect(() => {
    const interval = setInterval(() => {
      if (videoRef.current && isPlaying) {
        saveProgress(profileId, content.id, episode?.id, videoRef.current.currentTime);
      }
    }, 10000);
    
    return () => clearInterval(interval);
  }, [isPlaying, content, episode, profileId]);
  
  // Auto-play next episode
  const handleEnded = () => {
    onComplete?.();
    
    if (episode && content.autoplayNext) {
      const nextEpisode = getNextEpisode(episode);
      if (nextEpisode) {
        // Show countdown overlay
        showNextEpisodeCountdown(nextEpisode);
      }
    }
  };
  
  return (
    <div className="video-player" onMouseMove={() => setShowControls(true)}>
      <video
        ref={videoRef}
        onTimeUpdate={(e) => setCurrentTime(e.target.currentTime)}
        onDurationChange={(e) => setDuration(e.target.duration)}
        onPlay={() => setIsPlaying(true)}
        onPause={() => setIsPlaying(false)}
        onEnded={handleEnded}
      />
      
      {showControls && (
        <div className="controls">
          {/* Progress bar */}
          <div className="progress">
            <input
              type="range"
              min={0}
              max={duration}
              value={currentTime}
              onChange={(e) => videoRef.current.currentTime = e.target.value}
            />
          </div>
          
          {/* Control buttons */}
          <div className="buttons">
            <button onClick={() => skip(-10)}>⏪ 10s</button>
            <button onClick={togglePlay}>{isPlaying ? '⏸' : '▶'}</button>
            <button onClick={() => skip(10)}>10s ⏩</button>
            
            {/* Volume */}
            <VolumeControl video={videoRef.current} />
            
            {/* Subtitles */}
            <SubtitleSelector
              tracks={getSubtitleTracks()}
              current={subtitleTrack}
              onChange={setSubtitleTrack}
            />
            
            {/* Quality */}
            <QualitySelector
              qualities={getQualities()}
              current={quality}
              onChange={setQuality}
            />
            
            {/* Fullscreen */}
            <button onClick={toggleFullscreen}>⛶</button>
          </div>
        </div>
      )}
      
      {/* Next episode overlay */}
      <NextEpisodeOverlay />
    </div>
  );
}
```

---

## Part 8: Content Discovery

```typescript
// services/search.service.ts
export class SearchService {
  async search(
    query: string,
    profileId: string,
    filters?: SearchFilters
  ): Promise<SearchResults> {
    const profile = await db.profiles.findUnique({ where: { id: profileId } });
    
    // Build search query with maturity filter
    const results = await db.contents.findMany({
      where: {
        isPublished: true,
        maturityRating: { in: this.getAllowedRatings(profile.maturityLevel) },
        OR: [
          { title: { contains: query, mode: 'insensitive' } },
          { originalTitle: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
          { tags: { hasSome: [query.toLowerCase()] } },
          { castMembers: { path: ['$[*].name'], string_contains: query } },
          { directors: { hasSome: [query] } },
        ],
        ...(filters?.genre && { genres: { has: filters.genre } }),
        ...(filters?.year && { releaseYear: filters.year }),
        ...(filters?.type && { type: filters.type }),
      },
      orderBy: { ratingAvg: 'desc' },
      take: 50,
    });
    
    // Log search for analytics
    await this.logSearch(profileId, query, results.length);
    
    return {
      query,
      results,
      totalCount: results.length,
    };
  }
}
```

---

## Part 9: Best Practices

### ✅ Do This

- ✅ **Multi-quality streaming** - Adaptive bitrate (ABR)
- ✅ **DRM protection** - Widevine + FairPlay for all devices
- ✅ **Concurrent limits** - Enforce based on subscription tier
- ✅ **Resume playback** - Save position every 10 seconds
- ✅ **Content preloading** - Preload next episode
- ✅ **Offline download** - With expiring licenses
- ✅ **Parental controls** - PIN + maturity ratings

### ❌ Avoid This

- ❌ **No DRM** - Content will be pirated
- ❌ **Single quality** - Bad UX on slow networks
- ❌ **Unlimited streams** - Account sharing abuse
- ❌ **No resume** - Users expect to continue
- ❌ **Centralized storage** - Use CDN edge servers

---

## Related Skills

- `@video-processing-specialist` - Advanced FFmpeg
- `@senior-cloud-architect` - Scalable infrastructure
- `@payment-integration-specialist` - Subscription billing
- `@senior-firebase-developer` - Realtime features
