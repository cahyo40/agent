---
name: sports-league-developer
description: "Expert sports league management system development including fixtures, brackets, standings, match statistics, and tournament management"
---

# Sports League Developer

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis pengembangan sistem manajemen liga dan turnamen olahraga. Agent akan mampu membangun fitur fixture generation, bracket tournaments, standings calculation, match statistics, dan real-time scoring untuk berbagai jenis olahraga.

## When to Use This Skill

- Use when building sports league management systems
- Use when implementing tournament brackets
- Use when calculating standings and statistics
- Use when the user asks about fixture generation algorithms
- Use when building live scoring applications

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           SPORTS LEAGUE MANAGEMENT SYSTEM               │
├─────────────────────────────────────────────────────────┤
│ 📅 Fixture Generation  - Round-robin, knockout, groups  │
│ 🏆 Bracket System      - Single/double elimination      │
│ 📊 Standings Table     - Points, GD, head-to-head       │
│ 📈 Statistics          - Player/team stats tracking     │
│ ⚽ Live Scoring        - Real-time match updates        │
│ 🗓️ Season Management   - Multi-season support           │
│ 🏅 Awards & Rankings   - Top scorer, MVP, form          │
└─────────────────────────────────────────────────────────┘
```

### Data Schema (ERD)

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    LEAGUE    │     │    SEASON    │     │    TEAM      │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ id           │     │ id           │
│ name         │     │ league_id    │◄────│ name         │
│ sport_type   │     │ name         │     │ logo_url     │
│ country      │     │ start_date   │     │ home_venue   │
└──────────────┘     │ end_date     │     │ founded_year │
                     │ format       │     └──────────────┘
                     └──────────────┘            │
                            │                   │
                            ▼                   ▼
                     ┌──────────────┐     ┌──────────────┐
                     │    MATCH     │     │   PLAYER     │
                     ├──────────────┤     ├──────────────┤
                     │ id           │     │ id           │
                     │ season_id    │     │ team_id      │
                     │ home_team_id │     │ name         │
                     │ away_team_id │     │ position     │
                     │ matchday     │     │ jersey_num   │
                     │ scheduled_at │     │ nationality  │
                     │ venue_id     │     └──────────────┘
                     │ status       │            │
                     │ home_score   │            │
                     │ away_score   │            ▼
                     └──────────────┘     ┌──────────────┐
                            │            │ MATCH_EVENT  │
                            │            ├──────────────┤
                            └───────────►│ id           │
                                         │ match_id     │
                                         │ player_id    │
                                         │ event_type   │
                                         │ minute       │
                                         │ details      │
                                         └──────────────┘
```

## Tournament Formats

### 1. Round-Robin (Liga)

```text
ROUND-ROBIN FORMULA:
─────────────────────
Teams: N
Rounds: N - 1 (single) or 2(N-1) (double/home-away)
Matches per round: N / 2
Total matches: N(N-1) / 2 (single) or N(N-1) (double)

Example: 8 teams, double round-robin
- Rounds: 14 (7 + 7)
- Matches per round: 4
- Total matches: 56

BERGER TABLE ALGORITHM:
1. If N is odd, add dummy team (bye)
2. Fix last team in position
3. Rotate other teams clockwise each round
4. Match: position[i] vs position[N-1-i]

Round 1:  1-8  2-7  3-6  4-5
Round 2:  8-5  6-4  7-3  1-2
Round 3:  2-8  3-1  4-7  5-6
...
```

### 2. Knockout Bracket

```text
SINGLE ELIMINATION:
                    ┌─── Team A ───┐
              ┌─────┤              ├─────┐
              │     └─── Team B ───┘     │
        ┌─────┤                          ├─────┐
        │     │     ┌─── Team C ───┐     │     │
        │     └─────┤              ├─────┘     │
        │           └─── Team D ───┘           │
  ┌─────┤                                      ├─────┐ FINAL
        │           ┌─── Team E ───┐           │
        │     ┌─────┤              ├─────┐     │
        │     │     └─── Team F ───┘     │     │
        └─────┤                          ├─────┘
              │     ┌─── Team G ───┐     │
              └─────┤              ├─────┘
                    └─── Team H ───┘

BRACKET SIZE: Must be power of 2 (4, 8, 16, 32, 64)
If teams < bracket size, add BYEs

SEEDING: Top seeds avoid each other until later rounds
  Seed 1 vs Seed 16
  Seed 8 vs Seed 9
  ...etc

DOUBLE ELIMINATION: Losers get second chance in losers bracket
```

### 3. Group Stage + Knockout

```text
GROUP STAGE:
┌───────────────────────────────────────────────┐
│ Group A      │ Group B      │ Group C        │
├──────────────┼──────────────┼────────────────┤
│ Team 1       │ Team 5       │ Team 9         │
│ Team 2       │ Team 6       │ Team 10        │
│ Team 3       │ Team 7       │ Team 11        │
│ Team 4       │ Team 8       │ Team 12        │
└──────────────┴──────────────┴────────────────┘

Within each group: Round-robin
Top N teams advance to knockout phase

ADVANCEMENT CRITERIA:
1. Points
2. Goal difference
3. Goals scored
4. Head-to-head
5. Fair play points
6. Drawing of lots
```

## Standings Calculation

### Point Systems

```text
FOOTBALL/SOCCER (3-1-0):
- Win:  3 points
- Draw: 1 point
- Loss: 0 points

HOCKEY (3-2-1-0):
- Win:           3 points
- OT/SO Win:     2 points
- OT/SO Loss:    1 point
- Regulation Loss: 0 points

BASKETBALL (2-1-0):
- Win:  2 points (or 1)
- Loss: 1 point (or 0)
```

### Standings Table Structure

```text
┌───┬──────────────┬────┬───┬───┬───┬────┬────┬─────┬─────┐
│ # │ Team         │ P  │ W │ D │ L │ GF │ GA │ GD  │ Pts │
├───┼──────────────┼────┼───┼───┼───┼────┼────┼─────┼─────┤
│ 1 │ Team A       │ 10 │ 8 │ 1 │ 1 │ 25 │ 8  │ +17 │ 25  │
│ 2 │ Team B       │ 10 │ 7 │ 2 │ 1 │ 20 │ 10 │ +10 │ 23  │
│ 3 │ Team C       │ 10 │ 6 │ 2 │ 2 │ 18 │ 12 │ +6  │ 20  │
│...│ ...          │... │...│...│...│... │... │ ... │ ... │
└───┴──────────────┴────┴───┴───┴───┴────┴────┴─────┴─────┘

LEGEND:
P = Played, W = Won, D = Drawn, L = Lost
GF = Goals For, GA = Goals Against
GD = Goal Difference (GF - GA)
Pts = Points
```

### Tiebreaker Rules

```text
TIEBREAKER HIERARCHY (FIFA/UEFA Style):
1. Points
2. Goal Difference
3. Goals Scored
4. Head-to-Head Points
5. Head-to-Head Goal Difference
6. Head-to-Head Goals Scored
7. Away Goals (if applicable)
8. Fair Play Points
9. Drawing of Lots

HEAD-TO-HEAD CALCULATION:
- Only matches between tied teams
- Create mini-table with same criteria
```

## Statistics Tracking

### Player Statistics

```text
OFFENSIVE STATS:
├── Goals
├── Assists
├── Shots (on target / off target)
├── Conversion Rate (goals / shots)
├── Minutes Per Goal
└── Hat-tricks

DEFENSIVE STATS:
├── Tackles
├── Interceptions
├── Clearances
├── Blocks
└── Clean Sheets (goalkeepers)

DISCIPLINE:
├── Yellow Cards
├── Red Cards
├── Fouls Committed
└── Fouls Suffered

GENERAL:
├── Appearances
├── Minutes Played
├── Starts vs Substitute
└── Man of the Match Awards
```

### Team Statistics

```text
PERFORMANCE:
├── Win Rate %
├── Draw Rate %
├── Home Record vs Away Record
├── Form (last 5 matches: WWDLW)
├── Longest Win Streak
└── Clean Sheet %

SCORING:
├── Goals Scored (total, home, away)
├── Goals Conceded
├── Average Goals Per Game
├── First Half vs Second Half Goals
└── Scoring Minutes Distribution
```

## API Design

### Endpoints Structure

```text
/api/v1/
├── /leagues
│   ├── GET    /                    - List leagues
│   └── GET    /:id/standings       - Current standings
│
├── /seasons
│   ├── GET    /:id/fixtures        - Season fixtures
│   ├── GET    /:id/results         - Completed matches
│   └── POST   /:id/generate        - Generate fixtures
│
├── /matches
│   ├── GET    /:id                 - Match details
│   ├── PUT    /:id/score           - Update score
│   ├── POST   /:id/events          - Add match event
│   └── GET    /:id/timeline        - Match timeline
│
├── /teams
│   ├── GET    /:id/stats           - Team statistics
│   ├── GET    /:id/fixtures        - Team fixtures
│   └── GET    /:id/players         - Team roster
│
├── /players
│   ├── GET    /:id/stats           - Player statistics
│   └── GET    /top-scorers         - Leaderboard
│
└── /brackets
    ├── GET    /:tournament_id      - Get bracket
    └── PUT    /:match_id/advance   - Advance winner
```

## Real-Time Features

```text
LIVE SCORING WEBSOCKET EVENTS:
─────────────────────────────
Event: match.started
Data: { match_id, kickoff_time }

Event: match.goal
Data: { match_id, team, player, minute, score }

Event: match.card
Data: { match_id, player, card_type, minute }

Event: match.substitution
Data: { match_id, player_out, player_in, minute }

Event: match.ended
Data: { match_id, final_score, stats }

Event: standings.updated
Data: { league_id, standings[] }
```

## Best Practices

### ✅ Do This

- ✅ Support multiple tournament formats (league, knockout, groups)
- ✅ Implement proper tiebreaker rules per competition
- ✅ Handle postponed and rescheduled matches gracefully
- ✅ Provide real-time updates via WebSockets
- ✅ Support historical data and season archives
- ✅ Allow custom point systems per sport

### ❌ Avoid This

- ❌ Don't hardcode point systems (different for different sports)
- ❌ Don't forget extra-time and penalties for knockout matches
- ❌ Don't ignore timezone handling for international leagues
- ❌ Don't skip validation when recording match events
- ❌ Don't make standings recalculation expensive (cache!)

## Related Skills

- `@senior-backend-developer` - API development
- `@senior-database-engineer-sql` - Database design
- `@senior-software-architect` - System design
- `@analytics-engineer` - Sports analytics
- `@senior-ui-ux-designer` - Dashboard design
