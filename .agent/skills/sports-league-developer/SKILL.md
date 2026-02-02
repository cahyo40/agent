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

## How It Works

### Step 1: Core Components

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

### Step 2: Data Models

```dart
// Core entities
class Team {
  final String id;
  final String name;
  final String logoUrl;
  final String homeVenue;
  final List<String> playerIds;
  final String managerId;
}

class Player {
  final String id;
  final String name;
  final String teamId;
  final int jerseyNumber;
  final PlayerPosition position;
  final DateTime dateOfBirth;
}

class Match {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final DateTime scheduledDate;
  final String venueId;
  final MatchStatus status; // scheduled, live, completed, postponed
  final int? homeScore;
  final int? awayScore;
  final List<MatchEvent> events;
  final int? attendance;
  final String? refereeId;
  
  String? get winnerId {
    if (homeScore == null || awayScore == null) return null;
    if (homeScore! > awayScore!) return homeTeamId;
    if (awayScore! > homeScore!) return awayTeamId;
    return null; // draw
  }
}

class MatchEvent {
  final String id;
  final String matchId;
  final EventType type; // goal, yellowCard, redCard, substitution
  final int minute;
  final String playerId;
  final String? assistPlayerId;
  final String teamId;
}

class Season {
  final String id;
  final String leagueId;
  final String name; // "2025/2026"
  final DateTime startDate;
  final DateTime endDate;
  final SeasonFormat format; // league, knockout, groupStage
}

class Standing {
  final String teamId;
  final String seasonId;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  
  int get goalDifference => goalsFor - goalsAgainst;
  
  double get pointsPerGame => played > 0 ? points / played : 0;
}
```

### Step 3: Fixture Generation

```dart
class FixtureGenerator {
  // Round-robin algorithm (berger tables)
  List<Matchday> generateRoundRobin(List<Team> teams, {bool doubleRound = true}) {
    final matchdays = <Matchday>[];
    var teamList = [...teams];
    
    // Add dummy team if odd number
    if (teamList.length % 2 != 0) {
      teamList.add(Team.bye());
    }
    
    final n = teamList.length;
    final rounds = n - 1;
    final matchesPerRound = n ~/ 2;
    
    for (int round = 0; round < rounds; round++) {
      final matches = <Match>[];
      
      for (int match = 0; match < matchesPerRound; match++) {
        final home = (round + match) % (n - 1);
        var away = (n - 1 - match + round) % (n - 1);
        
        // Last team stays fixed
        if (match == 0) {
          away = n - 1;
        }
        
        // Skip bye matches
        if (!teamList[home].isBye && !teamList[away].isBye) {
          matches.add(Match(
            homeTeamId: teamList[home].id,
            awayTeamId: teamList[away].id,
            matchday: round + 1,
          ));
        }
      }
      
      matchdays.add(Matchday(round: round + 1, matches: matches));
    }
    
    // Generate second leg (reverse home/away)
    if (doubleRound) {
      final secondLeg = matchdays.map((md) => Matchday(
        round: md.round + rounds,
        matches: md.matches.map((m) => Match(
          homeTeamId: m.awayTeamId,
          awayTeamId: m.homeTeamId,
          matchday: md.round + rounds,
        )).toList(),
      )).toList();
      
      matchdays.addAll(secondLeg);
    }
    
    return matchdays;
  }
  
  // Knockout bracket generation
  Bracket generateKnockoutBracket(List<Team> teams, {bool seeded = true}) {
    var seededTeams = [...teams];
    
    if (seeded) {
      seededTeams.sort((a, b) => b.ranking.compareTo(a.ranking));
    } else {
      seededTeams.shuffle();
    }
    
    // Pad to power of 2
    final bracketSize = _nextPowerOf2(seededTeams.length);
    final byes = bracketSize - seededTeams.length;
    
    final rounds = <BracketRound>[];
    var currentMatches = <BracketMatch>[];
    
    // First round with byes
    for (int i = 0; i < bracketSize ~/ 2; i++) {
      final team1 = i < seededTeams.length ? seededTeams[i] : null;
      final team2Index = bracketSize - 1 - i;
      final team2 = team2Index < seededTeams.length ? seededTeams[team2Index] : null;
      
      currentMatches.add(BracketMatch(
        position: i,
        team1Id: team1?.id,
        team2Id: team2?.id,
        // Auto-advance if bye
        winnerId: team2 == null ? team1?.id : null,
      ));
    }
    
    rounds.add(BracketRound(name: 'Round of ${bracketSize}', matches: currentMatches));
    
    // Generate subsequent rounds
    while (currentMatches.length > 1) {
      final nextMatches = <BracketMatch>[];
      for (int i = 0; i < currentMatches.length ~/ 2; i++) {
        nextMatches.add(BracketMatch(
          position: i,
          feedsFrom: [currentMatches[i * 2], currentMatches[i * 2 + 1]],
        ));
      }
      
      final roundName = switch (nextMatches.length) {
        1 => 'Final',
        2 => 'Semi-finals',
        4 => 'Quarter-finals',
        _ => 'Round of ${nextMatches.length * 2}',
      };
      
      rounds.add(BracketRound(name: roundName, matches: nextMatches));
      currentMatches = nextMatches;
    }
    
    return Bracket(rounds: rounds);
  }
  
  int _nextPowerOf2(int n) {
    int power = 1;
    while (power < n) power *= 2;
    return power;
  }
}
```

### Step 4: Standings Calculation

```dart
class StandingsService {
  // Calculate standings with tiebreakers
  Future<List<Standing>> calculateStandings(String seasonId) async {
    final matches = await _matchRepo.getCompletedMatches(seasonId);
    final standings = <String, Standing>{};
    
    for (final match in matches) {
      // Update home team
      standings.putIfAbsent(match.homeTeamId, () => Standing.empty(match.homeTeamId));
      standings.putIfAbsent(match.awayTeamId, () => Standing.empty(match.awayTeamId));
      
      final home = standings[match.homeTeamId]!;
      final away = standings[match.awayTeamId]!;
      
      // Update stats
      home.played++;
      away.played++;
      home.goalsFor += match.homeScore!;
      home.goalsAgainst += match.awayScore!;
      away.goalsFor += match.awayScore!;
      away.goalsAgainst += match.homeScore!;
      
      // Points (3-1-0 system)
      if (match.homeScore! > match.awayScore!) {
        home.won++;
        home.points += 3;
        away.lost++;
      } else if (match.homeScore! < match.awayScore!) {
        away.won++;
        away.points += 3;
        home.lost++;
      } else {
        home.drawn++;
        away.drawn++;
        home.points += 1;
        away.points += 1;
      }
    }
    
    // Sort with tiebreakers
    final sortedStandings = standings.values.toList();
    sortedStandings.sort((a, b) {
      // 1. Points
      if (a.points != b.points) return b.points.compareTo(a.points);
      // 2. Goal difference
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      // 3. Goals scored
      if (a.goalsFor != b.goalsFor) return b.goalsFor.compareTo(a.goalsFor);
      // 4. Head-to-head (simplified)
      return _headToHead(a.teamId, b.teamId, matches);
    });
    
    return sortedStandings;
  }
  
  int _headToHead(String teamA, String teamB, List<Match> matches) {
    int pointsA = 0;
    int pointsB = 0;
    
    for (final match in matches) {
      if ((match.homeTeamId == teamA && match.awayTeamId == teamB) ||
          (match.homeTeamId == teamB && match.awayTeamId == teamA)) {
        final scoreA = match.homeTeamId == teamA ? match.homeScore! : match.awayScore!;
        final scoreB = match.homeTeamId == teamB ? match.homeScore! : match.awayScore!;
        
        if (scoreA > scoreB) pointsA += 3;
        else if (scoreB > scoreA) pointsB += 3;
        else { pointsA++; pointsB++; }
      }
    }
    
    return pointsB.compareTo(pointsA);
  }
}
```

### Step 5: Player Statistics

```dart
class PlayerStatsService {
  Future<PlayerSeasonStats> getPlayerStats(String playerId, String seasonId) async {
    final events = await _eventRepo.getPlayerEvents(playerId, seasonId);
    final matches = await _matchRepo.getPlayerMatches(playerId, seasonId);
    
    int goals = 0;
    int assists = 0;
    int yellowCards = 0;
    int redCards = 0;
    int minutesPlayed = 0;
    
    for (final event in events) {
      switch (event.type) {
        case EventType.goal:
          goals++;
          break;
        case EventType.assist:
          assists++;
          break;
        case EventType.yellowCard:
          yellowCards++;
          break;
        case EventType.redCard:
          redCards++;
          break;
        default:
          break;
      }
    }
    
    return PlayerSeasonStats(
      playerId: playerId,
      seasonId: seasonId,
      appearances: matches.length,
      goals: goals,
      assists: assists,
      yellowCards: yellowCards,
      redCards: redCards,
      minutesPlayed: minutesPlayed,
      goalsPerGame: matches.isNotEmpty ? goals / matches.length : 0,
    );
  }
  
  // Top scorers leaderboard
  Future<List<PlayerSeasonStats>> getTopScorers(String seasonId, {int limit = 10}) async {
    final allStats = await _getAllPlayerStats(seasonId);
    allStats.sort((a, b) => b.goals.compareTo(a.goals));
    return allStats.take(limit).toList();
  }
}
```

### Step 6: UI Components

```dart
// Standings table widget
class StandingsTableWidget extends StatelessWidget {
  final List<Standing> standings;
  
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('#')),
        DataColumn(label: Text('Team')),
        DataColumn(label: Text('P'), numeric: true),
        DataColumn(label: Text('W'), numeric: true),
        DataColumn(label: Text('D'), numeric: true),
        DataColumn(label: Text('L'), numeric: true),
        DataColumn(label: Text('GF'), numeric: true),
        DataColumn(label: Text('GA'), numeric: true),
        DataColumn(label: Text('GD'), numeric: true),
        DataColumn(label: Text('Pts'), numeric: true),
      ],
      rows: standings.asMap().entries.map((entry) {
        final position = entry.key + 1;
        final s = entry.value;
        return DataRow(
          color: MaterialStateProperty.resolveWith((states) {
            if (position <= 4) return Colors.green.withOpacity(0.1); // CL
            if (position >= standings.length - 2) return Colors.red.withOpacity(0.1); // Relegation
            return null;
          }),
          cells: [
            DataCell(Text('$position')),
            DataCell(_TeamCell(teamId: s.teamId)),
            DataCell(Text('${s.played}')),
            DataCell(Text('${s.won}')),
            DataCell(Text('${s.drawn}')),
            DataCell(Text('${s.lost}')),
            DataCell(Text('${s.goalsFor}')),
            DataCell(Text('${s.goalsAgainst}')),
            DataCell(Text('${s.goalDifference}')),
            DataCell(Text('${s.points}', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        );
      }).toList(),
    );
  }
}

// Knockout bracket widget
class BracketWidget extends StatelessWidget {
  final Bracket bracket;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: bracket.rounds.map((round) => 
          _BracketRoundColumn(round: round)
        ).toList(),
      ),
    );
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Support multiple tournament formats (league, knockout, groups)
- ✅ Implement proper tiebreaker rules per competition
- ✅ Handle postponed and rescheduled matches gracefully
- ✅ Provide real-time updates via WebSockets
- ✅ Support historical data and season archives

### ❌ Avoid This

- ❌ Don't hardcode point systems (different for different sports)
- ❌ Don't forget extra-time and penalties for knockout matches
- ❌ Don't ignore timezone handling for international leagues
- ❌ Don't skip validation when recording match events
- ❌ Don't make standings recalculation expensive

## Related Skills

- `@senior-flutter-developer` - Mobile app development
- `@senior-firebase-developer` - Real-time database
- `@senior-backend-developer` - API development
- `@analytics-engineer` - Sports analytics
- `@senior-ui-ux-designer` - Dashboard design
