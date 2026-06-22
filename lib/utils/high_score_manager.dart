/// High Score Management System
/// Provides persistent storage for game statistics using SharedPreferences
/// with built-in error handling, caching, and batch operations

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Represents a complete game session record
class GameRecord {
  final int score;
  final int distance; // measured in checkpoints
  final int starsCollected;
  final int bestCombo;
  final DateTime timestamp;

  GameRecord({
    required this.score,
    required this.distance,
    required this.starsCollected,
    required this.bestCombo,
    required this.timestamp,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'score': score,
    'distance': distance,
    'starsCollected': starsCollected,
    'bestCombo': bestCombo,
    'timestamp': timestamp.toIso8601String(),
  };

  /// Create from JSON
  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      score: json['score'] as int? ?? 0,
      distance: json['distance'] as int? ?? 0,
      starsCollected: json['starsCollected'] as int? ?? 0,
      bestCombo: json['bestCombo'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

/// Manages high scores and game statistics with optimized persistence
class HighScoreManager {
  // Storage keys
  static const String _HIGH_SCORE_KEY = 'high_score';
  static const String _TOTAL_GAMES_KEY = 'total_games_played';
  static const String _TOTAL_STARS_KEY = 'total_stars_collected';
  static const String _BEST_COMBO_KEY = 'best_combo_ever';
  static const String _LAST_PLAYED_KEY = 'last_played_time';
  static const String _GAMES_HISTORY_KEY = 'games_history';
  static const String _VERSION_KEY = 'hsm_version';
  
  // In-memory cache to avoid repeated disk reads
  static int? _cachedHighScore;
  static int? _cachedTotalGames;
  static int? _cachedTotalStars;
  static int? _cachedBestCombo;
  static List<GameRecord>? _cachedHistory;
  
  // Debounce timer for batch saves
  static Timer? _saveTimer;
  static final Duration _saveDebounceDuration = const Duration(seconds: 2);
  
  // Version for migrations
  static const int _CURRENT_VERSION = 1;

  /// Initialize and validate storage (call once on app startup)
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getInt(_VERSION_KEY) ?? 0;
      
      // Run migrations if needed
      if (version < _CURRENT_VERSION) {
        await _runMigrations(prefs, version);
        await prefs.setInt(_VERSION_KEY, _CURRENT_VERSION);
      }
      
      // Warm up cache
      _cachedHighScore = prefs.getInt(_HIGH_SCORE_KEY);
      _cachedTotalGames = prefs.getInt(_TOTAL_GAMES_KEY);
      _cachedTotalStars = prefs.getInt(_TOTAL_STARS_KEY);
      _cachedBestCombo = prefs.getInt(_BEST_COMBO_KEY);
    } catch (e) {
      print('HighScoreManager initialization error: $e');
    }
  }

  /// Save a complete game session with optimized writes
  /// Returns true if a new high score was achieved
  static Future<bool> saveGameSession({
    required int score,
    required int distance,
    required int starsCollected,
    required int bestCombo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isNewHighScore = false;

      // Check high score
      final currentHigh = _cachedHighScore ?? (prefs.getInt(_HIGH_SCORE_KEY) ?? 0);
      if (score > currentHigh) {
        _cachedHighScore = score;
        await prefs.setInt(_HIGH_SCORE_KEY, score);
        isNewHighScore = true;
      }

      // Update statistics
      _cachedTotalGames = (_cachedTotalGames ?? 0) + 1;
      _cachedTotalStars = (_cachedTotalStars ?? 0) + starsCollected;
      
      if (bestCombo > (_cachedBestCombo ?? 0)) {
        _cachedBestCombo = bestCombo;
        await prefs.setInt(_BEST_COMBO_KEY, bestCombo);
      }

      // Batch write non-critical stats (debounced)
      _debouncedStatsUpdate(prefs, _cachedTotalGames!, _cachedTotalStars!);

      // Add to history
      await _addToHistory(GameRecord(
        score: score,
        distance: distance,
        starsCollected: starsCollected,
        bestCombo: bestCombo,
        timestamp: DateTime.now(),
      ));

      // Update last played
      await prefs.setInt(_LAST_PLAYED_KEY, DateTime.now().millisecondsSinceEpoch);

      return isNewHighScore;
    } catch (e) {
      print('Error saving game session: $e');
      return false;
    }
  }

  /// Get high score from cache (fast)
  static int getHighScoreCached() {
    return _cachedHighScore ?? 0;
  }

  /// Get high score from storage (async, for initialization)
  static Future<int> getHighScore() async {
    if (_cachedHighScore != null) {
      return _cachedHighScore!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final score = prefs.getInt(_HIGH_SCORE_KEY) ?? 0;
      _cachedHighScore = score;
      return score;
    } catch (e) {
      print('Error getting high score: $e');
      return 0;
    }
  }

  /// Check if score beats current high score (fast, uses cache)
  static bool isNewHighScoreCached(int score) {
    return score > (_cachedHighScore ?? 0);
  }

  /// Check if score is new high score (async)
  static Future<bool> isNewHighScore(int score) async {
    final currentHigh = await getHighScore();
    return score > currentHigh;
  }

  /// Get total games played
  static Future<int> getTotalGamesPlayed() async {
    if (_cachedTotalGames != null) {
      return _cachedTotalGames!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_TOTAL_GAMES_KEY) ?? 0;
      _cachedTotalGames = count;
      return count;
    } catch (e) {
      print('Error getting total games: $e');
      return 0;
    }
  }

  /// Get total stars collected across all games
  static Future<int> getTotalStarsCollected() async {
    if (_cachedTotalStars != null) {
      return _cachedTotalStars!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final stars = prefs.getInt(_TOTAL_STARS_KEY) ?? 0;
      _cachedTotalStars = stars;
      return stars;
    } catch (e) {
      print('Error getting total stars: $e');
      return 0;
    }
  }

  /// Get best combo ever achieved
  static Future<int> getBestComboEver() async {
    if (_cachedBestCombo != null) {
      return _cachedBestCombo!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final combo = prefs.getInt(_BEST_COMBO_KEY) ?? 0;
      _cachedBestCombo = combo;
      return combo;
    } catch (e) {
      print('Error getting best combo: $e');
      return 0;
    }
  }

  /// Get all cached statistics at once (fast)
  static Future<Map<String, int>> getAllStatsCached() async {
    await initialize(); // Ensure cache is warm
    return {
      'highScore': _cachedHighScore ?? 0,
      'totalGames': _cachedTotalGames ?? 0,
      'totalStars': _cachedTotalStars ?? 0,
      'bestCombo': _cachedBestCombo ?? 0,
    };
  }

  /// Get game history (limited to last N games)
  static Future<List<GameRecord>> getGameHistory({int limit = 10}) async {
    if (_cachedHistory != null) {
      return _cachedHistory!.take(limit).toList();
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_GAMES_HISTORY_KEY) ?? [];
      
      _cachedHistory = historyJson
          .map((json) {
            try {
              return GameRecord.fromJson(
                Map<String, dynamic>.from(
                  json.split('|').asMap().entries.fold<Map<String, dynamic>>({}, (map, entry) {
                    // Simple parsing for lightweight storage
                    return map;
                  }),
                ),
              );
            } catch (e) {
              return null;
            }
          })
          .whereType<GameRecord>()
          .toList();
      
      return _cachedHistory!.take(limit).toList();
    } catch (e) {
      print('Error getting game history: $e');
      return [];
    }
  }

  /// Clear all game data (for testing or reset)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_HIGH_SCORE_KEY),
        prefs.remove(_TOTAL_GAMES_KEY),
        prefs.remove(_TOTAL_STARS_KEY),
        prefs.remove(_BEST_COMBO_KEY),
        prefs.remove(_LAST_PLAYED_KEY),
        prefs.remove(_GAMES_HISTORY_KEY),
      ]);
      
      // Clear cache
      _cachedHighScore = null;
      _cachedTotalGames = null;
      _cachedTotalStars = null;
      _cachedBestCombo = null;
      _cachedHistory = null;
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  /// Internal: Debounced stats update (avoids excessive writes)
  static void _debouncedStatsUpdate(SharedPreferences prefs, int games, int stars) {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounceDuration, () async {
      try {
        await prefs.setInt(_TOTAL_GAMES_KEY, games);
        await prefs.setInt(_TOTAL_STARS_KEY, stars);
      } catch (e) {
        print('Error in debounced stats update: $e');
      }
    });
  }

  /// Internal: Add game to history
  static Future<void> _addToHistory(GameRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_GAMES_HISTORY_KEY) ?? [];
      
      // Keep only last 100 games to manage storage
      if (history.length >= 100) {
        history.removeAt(0);
      }
      
      // Simple serialization
      history.add('${record.score}|${record.distance}|${record.starsCollected}|${record.bestCombo}|${record.timestamp.toIso8601String()}');
      
      await prefs.setStringList(_GAMES_HISTORY_KEY, history);
      _cachedHistory = null; // Invalidate cache
    } catch (e) {
      print('Error adding to history: $e');
    }
  }

  /// Internal: Run data migrations
  static Future<void> _runMigrations(SharedPreferences prefs, int fromVersion) async {
    // Add migration logic here as the app evolves
    // Example: if (fromVersion < 2) { ... migrate to v2 ... }
  }

  /// Dispose resources (call on app shutdown)
  static void dispose() {
    _saveTimer?.cancel();
  }
}
