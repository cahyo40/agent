---
name: streaming-app-developer
description: "Expert streaming platform development including video/audio streaming, HLS/DASH, live streaming, content delivery, and OTT applications"
---

# Streaming App Developer

## Overview

Expert in building **video/audio streaming platforms** like Netflix, Spotify, or YouTube. Covers **HLS/DASH streaming**, **live broadcasts**, **content protection (DRM)**, **adaptive bitrate**, and **CDN integration**.

## When to Use This Skill

- Building video-on-demand (VOD) platforms
- Implementing live streaming features
- Creating music/podcast streaming apps
- Integrating video players with adaptive quality
- Setting up content delivery and transcoding

---

## Part 1: Streaming Architecture

```
┌───────────────────────────────────────────────────────────────────────┐
│                      Streaming Platform                                │
├───────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   Ingest    │  │  Transcode  │  │    CDN      │  │   Player    │  │
│  │  (Upload/   │→ │  (FFmpeg/   │→ │  Delivery   │→ │  (HLS.js/   │  │
│  │   RTMP)     │  │   Cloud)    │  │             │  │   Video.js) │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘  │
├───────────────────────────────────────────────────────────────────────┤
│       Content Management  │  User Auth  │  Subscriptions  │  Analytics│
└───────────────────────────────────────────────────────────────────────┘
```

### Streaming Protocols

| Protocol | Use Case | Latency |
|----------|----------|---------|
| **HLS** | VOD, most compatible | 10-30s |
| **DASH** | VOD, adaptive | 10-30s |
| **RTMP** | Ingest/broadcast | 2-5s |
| **WebRTC** | Real-time/interactive | <1s |
| **LL-HLS** | Low-latency live | 2-5s |

---

## Part 2: Database Schema

```sql
-- Videos/Content
CREATE TABLE contents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(20) NOT NULL,  -- 'movie', 'series', 'live', 'music', 'podcast'
    
    -- Media
    duration_seconds INTEGER,
    thumbnail_url TEXT,
    poster_url TEXT,
    trailer_url TEXT,
    
    -- Streaming URLs
    hls_url TEXT,
    dash_url TEXT,
    
    -- Metadata
    release_date DATE,
    genre_ids UUID[],
    tags TEXT[],
    language VARCHAR(10),
    country VARCHAR(50),
    
    -- Ratings
    rating_avg DECIMAL(3, 2),
    rating_count INTEGER DEFAULT 0,
    
    -- Access
    is_premium BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT false,
    
    -- Processing
    status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'processing', 'ready', 'failed'
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Video Qualities
CREATE TABLE video_qualities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_id UUID REFERENCES contents(id) ON DELETE CASCADE,
    
    quality VARCHAR(20) NOT NULL,  -- '360p', '480p', '720p', '1080p', '4k'
    width INTEGER,
    height INTEGER,
    bitrate_kbps INTEGER,
    
    url TEXT NOT NULL,
    file_size_bytes BIGINT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Series/Episodes
CREATE TABLE episodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    series_id UUID REFERENCES contents(id),
    season_number INTEGER NOT NULL,
    episode_number INTEGER NOT NULL,
    
    title VARCHAR(255),
    description TEXT,
    duration_seconds INTEGER,
    thumbnail_url TEXT,
    
    hls_url TEXT,
    
    release_date DATE,
    is_published BOOLEAN DEFAULT false,
    
    UNIQUE(series_id, season_number, episode_number)
);

-- Watch History
CREATE TABLE watch_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    content_id UUID REFERENCES contents(id),
    episode_id UUID REFERENCES episodes(id),
    
    position_seconds INTEGER DEFAULT 0,
    duration_watched INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT false,
    
    last_watched_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, content_id, episode_id)
);

-- Subscriptions
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    plan_id UUID REFERENCES subscription_plans(id),
    
    status VARCHAR(20) DEFAULT 'active',
    started_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    
    payment_method VARCHAR(50),
    auto_renew BOOLEAN DEFAULT true
);

-- Live Streams
CREATE TABLE live_streams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    streamer_id UUID REFERENCES users(id),
    
    title VARCHAR(255),
    description TEXT,
    thumbnail_url TEXT,
    
    stream_key VARCHAR(100) UNIQUE,
    rtmp_url TEXT,
    playback_url TEXT,
    
    status VARCHAR(20) DEFAULT 'offline',  -- 'offline', 'live', 'ended'
    viewer_count INTEGER DEFAULT 0,
    
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ
);
```

---

## Part 3: Video Processing

### 3.1 Transcoding Pipeline

```typescript
// services/transcoding.service.ts
import ffmpeg from 'fluent-ffmpeg';

interface TranscodeJob {
  contentId: string;
  inputPath: string;
  outputDir: string;
}

const QUALITY_PRESETS = [
  { name: '360p', width: 640, height: 360, bitrate: '800k' },
  { name: '480p', width: 854, height: 480, bitrate: '1400k' },
  { name: '720p', width: 1280, height: 720, bitrate: '2800k' },
  { name: '1080p', width: 1920, height: 1080, bitrate: '5000k' },
];

export class TranscodingService {
  async processVideo(job: TranscodeJob): Promise<void> {
    // Update status
    await db.contents.update({
      where: { id: job.contentId },
      data: { status: 'processing' },
    });
    
    try {
      // Generate thumbnail
      await this.generateThumbnail(job.inputPath, `${job.outputDir}/thumbnail.jpg`);
      
      // Transcode to multiple qualities
      for (const preset of QUALITY_PRESETS) {
        await this.transcodeQuality(job, preset);
      }
      
      // Generate HLS master playlist
      await this.generateHLSPlaylist(job);
      
      // Upload to CDN
      const hlsUrl = await this.uploadToCDN(job.outputDir, job.contentId);
      
      // Update database
      await db.contents.update({
        where: { id: job.contentId },
        data: { 
          status: 'ready',
          hlsUrl,
        },
      });
    } catch (error) {
      await db.contents.update({
        where: { id: job.contentId },
        data: { status: 'failed' },
      });
      throw error;
    }
  }
  
  private transcodeQuality(job: TranscodeJob, preset: QualityPreset): Promise<void> {
    return new Promise((resolve, reject) => {
      ffmpeg(job.inputPath)
        .outputOptions([
          `-vf scale=${preset.width}:${preset.height}`,
          `-b:v ${preset.bitrate}`,
          '-c:v libx264',
          '-preset fast',
          '-c:a aac',
          '-b:a 128k',
          '-f hls',
          '-hls_time 10',
          '-hls_list_size 0',
          '-hls_segment_filename', `${job.outputDir}/${preset.name}_%03d.ts`,
        ])
        .output(`${job.outputDir}/${preset.name}.m3u8`)
        .on('end', resolve)
        .on('error', reject)
        .run();
    });
  }
  
  private async generateHLSPlaylist(job: TranscodeJob): Promise<void> {
    const master = QUALITY_PRESETS.map(p => 
      `#EXT-X-STREAM-INF:BANDWIDTH=${parseInt(p.bitrate) * 1000},RESOLUTION=${p.width}x${p.height}\n${p.name}.m3u8`
    ).join('\n');
    
    await fs.writeFile(`${job.outputDir}/master.m3u8`, `#EXTM3U\n#EXT-X-VERSION:3\n${master}`);
  }
}
```

### 3.2 Video Player Integration

```typescript
// React video player with resume & quality selection
import Hls from 'hls.js';

function VideoPlayer({ contentId, hlsUrl, startPosition = 0 }) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const hlsRef = useRef<Hls>();
  const [quality, setQuality] = useState('auto');
  const [qualities, setQualities] = useState<string[]>([]);
  
  useEffect(() => {
    if (!videoRef.current || !Hls.isSupported()) return;
    
    const hls = new Hls({
      startPosition,
      maxBufferLength: 30,
      maxMaxBufferLength: 60,
    });
    
    hls.loadSource(hlsUrl);
    hls.attachMedia(videoRef.current);
    
    hls.on(Hls.Events.MANIFEST_PARSED, (_, data) => {
      const levels = data.levels.map(l => `${l.height}p`);
      setQualities(['auto', ...levels]);
      videoRef.current?.play();
    });
    
    hlsRef.current = hls;
    
    return () => hls.destroy();
  }, [hlsUrl, startPosition]);
  
  // Save progress periodically
  useEffect(() => {
    const interval = setInterval(() => {
      if (videoRef.current) {
        saveProgress(contentId, Math.floor(videoRef.current.currentTime));
      }
    }, 10000);
    
    return () => clearInterval(interval);
  }, [contentId]);
  
  const handleQualityChange = (newQuality: string) => {
    if (!hlsRef.current) return;
    
    if (newQuality === 'auto') {
      hlsRef.current.currentLevel = -1;
    } else {
      const level = hlsRef.current.levels.findIndex(
        l => `${l.height}p` === newQuality
      );
      hlsRef.current.currentLevel = level;
    }
    setQuality(newQuality);
  };
  
  return (
    <div className="video-container">
      <video ref={videoRef} controls />
      <select value={quality} onChange={e => handleQualityChange(e.target.value)}>
        {qualities.map(q => <option key={q} value={q}>{q}</option>)}
      </select>
    </div>
  );
}
```

---

## Part 4: Live Streaming

### 4.1 RTMP Ingest

```typescript
// Live stream management
class LiveStreamService {
  async startStream(userId: string): Promise<LiveStream> {
    const streamKey = crypto.randomBytes(16).toString('hex');
    
    const stream = await db.liveStreams.create({
      data: {
        streamerId: userId,
        streamKey,
        rtmpUrl: `rtmp://ingest.streaming.com/live/${streamKey}`,
        status: 'offline',
      },
    });
    
    return stream;
  }
  
  async handleStreamStart(streamKey: string): Promise<void> {
    const stream = await db.liveStreams.findUnique({
      where: { streamKey },
    });
    
    if (!stream) throw new Error('Invalid stream key');
    
    // Start transcoding pipeline for live
    await this.startLiveTranscoder(stream);
    
    await db.liveStreams.update({
      where: { id: stream.id },
      data: {
        status: 'live',
        startedAt: new Date(),
        playbackUrl: `https://cdn.streaming.com/live/${stream.id}/master.m3u8`,
      },
    });
    
    // Notify followers
    await this.notifyFollowers(stream.streamerId, stream);
  }
  
  async updateViewerCount(streamId: string, count: number): Promise<void> {
    await db.liveStreams.update({
      where: { id: streamId },
      data: { viewerCount: count },
    });
  }
}
```

---

## Part 5: Best Practices

### ✅ Do This

- ✅ Use adaptive bitrate streaming (HLS/DASH)
- ✅ Implement resume playback with saved positions
- ✅ Use CDN for content delivery
- ✅ Transcode to multiple qualities
- ✅ Add DRM for premium content (Widevine, FairPlay)
- ✅ Implement offline download for mobile

### ❌ Avoid This

- ❌ Single quality only - always provide options
- ❌ Hosting video files directly without CDN
- ❌ Ignoring buffering metrics and errors
- ❌ No resume - users expect to continue watching

---

## Related Skills

- `@video-processing-specialist` - Advanced FFmpeg and video manipulation
- `@livestream-producer` - OBS and broadcast production
- `@senior-firebase-developer` - Realtime features
- `@pwa-developer` - Offline video download
