---
name: sports-league-developer
description: "Expert sports league management system development including fixtures, brackets, standings, match statistics, and tournament management"
---

# Sports League Developer

## Overview

This skill transforms you into a **Sports League Management Expert**. You will master **League Structures**, **Fixture Generation**, **Standings Calculation**, **Tournament Brackets**, and **Match Statistics** for building production-ready sports management platforms.

## When to Use This Skill

- Use when building league management systems
- Use when implementing fixture scheduling
- Use when creating tournament brackets
- Use when calculating standings
- Use when tracking match statistics

---

## Part 1: Sports League Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                 Sports League Platform                       │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Leagues    │ Teams       │ Fixtures    │ Standings          │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Match Events & Statistics                      │
├─────────────────────────────────────────────────────────────┤
│              Players & Transfers                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Season** | Playing year/period |
| **Fixture** | Scheduled match |
| **Matchday** | Round of games |
| **Standings** | League table |
| **Goal Difference** | Goals for minus against |
| **Head-to-Head** | Tiebreaker comparison |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Leagues
CREATE TABLE leagues (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    sport VARCHAR(50),  -- 'football', 'basketball', 'tennis'
    country VARCHAR(100),
    format VARCHAR(50),  -- 'round_robin', 'knockout', 'group_knockout', 'double_round_robin'
    logo_url VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seasons
CREATE TABLE seasons (
    id UUID PRIMARY KEY,
    league_id UUID REFERENCES leagues(id),
    name VARCHAR(100),  -- '2024-2025'
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT FALSE,
    status VARCHAR(50) DEFAULT 'upcoming',  -- 'upcoming', 'in_progress', 'completed'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Teams
CREATE TABLE teams (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    short_name VARCHAR(10),
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    venue VARCHAR(100),
    city VARCHAR(100),
    founded_year INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Season Teams (teams in a season)
CREATE TABLE season_teams (
    id UUID PRIMARY KEY,
    season_id UUID REFERENCES seasons(id),
    team_id UUID REFERENCES teams(id),
    group_name VARCHAR(20),  -- For group stage
    seed INTEGER,  -- For knockout seeding
    UNIQUE(season_id, team_id)
);

-- Players
CREATE TABLE players (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    date_of_birth DATE,
    nationality VARCHAR(100),
    position VARCHAR(50),
    jersey_number INTEGER,
    photo_url VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Team Players (squad)
CREATE TABLE team_players (
    id UUID PRIMARY KEY,
    team_id UUID REFERENCES teams(id),
    player_id UUID REFERENCES players(id),
    season_id UUID REFERENCES seasons(id),
    jersey_number INTEGER,
    position VARCHAR(50),
    is_captain BOOLEAN DEFAULT FALSE,
    joined_at DATE,
    left_at DATE,
    UNIQUE(team_id, player_id, season_id)
);

-- Fixtures
CREATE TABLE fixtures (
    id UUID PRIMARY KEY,
    season_id UUID REFERENCES seasons(id),
    home_team_id UUID REFERENCES teams(id),
    away_team_id UUID REFERENCES teams(id),
    matchday INTEGER,
    round VARCHAR(50),  -- 'group_a', 'round_of_16', 'quarterfinal', 'semifinal', 'final'
    scheduled_at TIMESTAMPTZ,
    venue VARCHAR(100),
    status VARCHAR(50) DEFAULT 'scheduled',  -- 'scheduled', 'live', 'completed', 'postponed', 'cancelled'
    
    -- Score
    home_score INTEGER,
    away_score INTEGER,
    home_score_ht INTEGER,  -- Half-time
    away_score_ht INTEGER,
    home_score_et INTEGER,  -- Extra time (for knockouts)
    away_score_et INTEGER,
    home_score_pen INTEGER,  -- Penalties
    away_score_pen INTEGER,
    
    -- Timing
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    current_minute INTEGER,
    
    winner_id UUID REFERENCES teams(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Match Events
CREATE TABLE match_events (
    id UUID PRIMARY KEY,
    fixture_id UUID REFERENCES fixtures(id),
    team_id UUID REFERENCES teams(id),
    player_id UUID REFERENCES players(id),
    type VARCHAR(50),  -- 'goal', 'assist', 'yellow_card', 'red_card', 'substitution', 'penalty_scored', 'penalty_missed', 'own_goal'
    minute INTEGER,
    added_time INTEGER,
    related_player_id UUID REFERENCES players(id),  -- For substitution (player_out)
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Standings
CREATE TABLE standings (
    id UUID PRIMARY KEY,
    season_id UUID REFERENCES seasons(id),
    team_id UUID REFERENCES teams(id),
    group_name VARCHAR(20),
    position INTEGER,
    played INTEGER DEFAULT 0,
    won INTEGER DEFAULT 0,
    drawn INTEGER DEFAULT 0,
    lost INTEGER DEFAULT 0,
    goals_for INTEGER DEFAULT 0,
    goals_against INTEGER DEFAULT 0,
    goal_difference INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    form VARCHAR(10),  -- 'WWDLW'
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(season_id, team_id, group_name)
);

-- Player Statistics
CREATE TABLE player_statistics (
    id UUID PRIMARY KEY,
    player_id UUID REFERENCES players(id),
    season_id UUID REFERENCES seasons(id),
    team_id UUID REFERENCES teams(id),
    appearances INTEGER DEFAULT 0,
    minutes_played INTEGER DEFAULT 0,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    clean_sheets INTEGER DEFAULT 0,  -- For goalkeepers
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(player_id, season_id, team_id)
);
```

---

## Part 3: Fixture Generation

### 3.1 Round Robin Generator

```typescript
async function generateRoundRobinFixtures(
  seasonId: string,
  startDate: Date,
  matchesPerWeek = 1,
  homeAndAway = true
): Promise<Fixture[]> {
  const teams = await db.seasonTeams.findMany({
    where: { seasonId },
    include: { team: true },
  });
  
  const teamIds = teams.map(t => t.teamId);
  const n = teamIds.length;
  
  // Use round robin algorithm
  const rounds: [string, string][][] = [];
  
  // Create first half of season
  for (let round = 0; round < n - 1; round++) {
    const matches: [string, string][] = [];
    
    for (let match = 0; match < n / 2; match++) {
      const home = (round + match) % (n - 1);
      let away = (n - 1 - match + round) % (n - 1);
      
      if (match === 0) {
        away = n - 1;
      }
      
      // Alternate home/away
      if (round % 2 === 0) {
        matches.push([teamIds[home], teamIds[away]]);
      } else {
        matches.push([teamIds[away], teamIds[home]]);
      }
    }
    
    rounds.push(matches);
  }
  
  // Create fixtures
  const fixtures: Fixture[] = [];
  let currentDate = startDate;
  let matchday = 1;
  
  const createFixturesForRounds = async (roundsList: [string, string][][], startMatchday: number) => {
    let md = startMatchday;
    
    for (const round of roundsList) {
      for (const [homeTeamId, awayTeamId] of round) {
        const fixture = await db.fixtures.create({
          data: {
            seasonId,
            homeTeamId,
            awayTeamId,
            matchday: md,
            scheduledAt: currentDate,
            status: 'scheduled',
          },
        });
        fixtures.push(fixture);
      }
      
      currentDate = addDays(currentDate, 7 / matchesPerWeek);
      md++;
    }
    
    return md;
  };
  
  // First half
  matchday = await createFixturesForRounds(rounds, matchday);
  
  // Second half (home and away reversed)
  if (homeAndAway) {
    const reversedRounds = rounds.map(round =>
      round.map(([home, away]) => [away, home] as [string, string])
    );
    await createFixturesForRounds(reversedRounds, matchday);
  }
  
  return fixtures;
}
```

### 3.2 Knockout Bracket Generator

```typescript
async function generateKnockoutBracket(
  seasonId: string,
  teams: string[],
  startDate: Date
): Promise<Fixture[]> {
  // Teams should be power of 2 (8, 16, 32, etc.)
  const numTeams = teams.length;
  const numRounds = Math.log2(numTeams);
  
  const roundNames = {
    1: 'final',
    2: 'semifinal',
    3: 'quarterfinal',
    4: 'round_of_16',
    5: 'round_of_32',
    6: 'round_of_64',
  };
  
  const fixtures: Fixture[] = [];
  let currentDate = startDate;
  
  // Create all rounds
  for (let round = numRounds; round >= 1; round--) {
    const matchesInRound = Math.pow(2, round - 1);
    const roundName = roundNames[numRounds - round + 1] || `round_${round}`;
    
    for (let match = 0; match < matchesInRound; match++) {
      // For first round, assign teams
      const isFirstRound = round === numRounds;
      const homeTeamId = isFirstRound ? teams[match * 2] : null;
      const awayTeamId = isFirstRound ? teams[match * 2 + 1] : null;
      
      const fixture = await db.fixtures.create({
        data: {
          seasonId,
          homeTeamId,
          awayTeamId,
          round: roundName,
          scheduledAt: currentDate,
          status: 'scheduled',
        },
      });
      
      fixtures.push(fixture);
    }
    
    currentDate = addDays(currentDate, 7);
  }
  
  return fixtures;
}
```

---

## Part 4: Standings Calculation

### 4.1 Update Standings

```typescript
interface StandingRow {
  teamId: string;
  position: number;
  played: number;
  won: number;
  drawn: number;
  lost: number;
  goalsFor: number;
  goalsAgainst: number;
  goalDifference: number;
  points: number;
  form: string;
}

async function updateStandings(fixtureId: string) {
  const fixture = await db.fixtures.findUnique({
    where: { id: fixtureId },
    include: { season: { include: { league: true } } },
  });
  
  if (fixture.status !== 'completed') return;
  
  const { homeTeamId, awayTeamId, homeScore, awayScore, seasonId } = fixture;
  
  // Determine result
  const homeResult = homeScore > awayScore ? 'W' : homeScore < awayScore ? 'L' : 'D';
  const awayResult = awayScore > homeScore ? 'W' : awayScore < homeScore ? 'L' : 'D';
  
  // Update home team standing
  await updateTeamStanding(seasonId, homeTeamId, {
    goalsFor: homeScore,
    goalsAgainst: awayScore,
    result: homeResult,
  });
  
  // Update away team standing
  await updateTeamStanding(seasonId, awayTeamId, {
    goalsFor: awayScore,
    goalsAgainst: homeScore,
    result: awayResult,
  });
  
  // Recalculate positions
  await recalculatePositions(seasonId);
}

async function updateTeamStanding(
  seasonId: string,
  teamId: string,
  result: { goalsFor: number; goalsAgainst: number; result: 'W' | 'D' | 'L' }
) {
  const points = result.result === 'W' ? 3 : result.result === 'D' ? 1 : 0;
  
  await db.standings.upsert({
    where: { seasonId_teamId_groupName: { seasonId, teamId, groupName: 'league' } },
    create: {
      seasonId,
      teamId,
      groupName: 'league',
      played: 1,
      won: result.result === 'W' ? 1 : 0,
      drawn: result.result === 'D' ? 1 : 0,
      lost: result.result === 'L' ? 1 : 0,
      goalsFor: result.goalsFor,
      goalsAgainst: result.goalsAgainst,
      goalDifference: result.goalsFor - result.goalsAgainst,
      points,
      form: result.result,
    },
    update: {
      played: { increment: 1 },
      won: { increment: result.result === 'W' ? 1 : 0 },
      drawn: { increment: result.result === 'D' ? 1 : 0 },
      lost: { increment: result.result === 'L' ? 1 : 0 },
      goalsFor: { increment: result.goalsFor },
      goalsAgainst: { increment: result.goalsAgainst },
      goalDifference: { increment: result.goalsFor - result.goalsAgainst },
      points: { increment: points },
      form: db.raw(`right(form || '${result.result}', 5)`),  // Keep last 5 results
    },
  });
}

async function recalculatePositions(seasonId: string) {
  const standings = await db.standings.findMany({
    where: { seasonId },
    orderBy: [
      { points: 'desc' },
      { goalDifference: 'desc' },
      { goalsFor: 'desc' },
    ],
  });
  
  for (let i = 0; i < standings.length; i++) {
    await db.standings.update({
      where: { id: standings[i].id },
      data: { position: i + 1 },
    });
  }
}
```

---

## Part 5: Live Match Updates

### 5.1 Record Match Event

```typescript
async function recordMatchEvent(
  fixtureId: string,
  event: {
    type: string;
    teamId: string;
    playerId: string;
    minute: number;
    addedTime?: number;
    relatedPlayerId?: string;
  }
) {
  const matchEvent = await db.matchEvents.create({ data: { fixtureId, ...event } });
  
  // Update fixture score if goal
  if (['goal', 'penalty_scored'].includes(event.type)) {
    const fixture = await db.fixtures.findUnique({ where: { id: fixtureId } });
    
    const isHomeTeam = event.teamId === fixture.homeTeamId;
    await db.fixtures.update({
      where: { id: fixtureId },
      data: {
        [isHomeTeam ? 'homeScore' : 'awayScore']: { increment: 1 },
        currentMinute: event.minute,
      },
    });
  }
  
  // Update player statistics
  await updatePlayerStats(event.playerId, event.type);
  
  // Broadcast real-time update
  broadcastMatchUpdate(fixtureId, matchEvent);
  
  return matchEvent;
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Atomic Updates**: Transaction for score + standings.
- ✅ **Real-Time Sync**: WebSocket for live matches.
- ✅ **Tiebreakers**: Implement head-to-head rules.

### ❌ Avoid This

- ❌ **Manual Standings**: Always auto-calculate.
- ❌ **Hardcode Rules**: Make points configurable.
- ❌ **Ignore Timezones**: Store UTC, display local.

---

## Related Skills

- `@ticketing-system-developer` - Match tickets
- `@betting-platform-developer` - Odds and bets
- `@real-time-collaboration` - Live updates
