import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager with optimized settings for memory efficiency
class MyCustomCacheManager {
  static CacheManager instance = CacheManager(
    Config(
      'myCustomCacheKey',
      stalePeriod: const Duration(
        days: 7,
      ), // Reduced from 30 days for better memory
      maxNrOfCacheObjects: 50, // Reduced from 100 for better memory
    ),
  );

  /// Clear all cached data to free up storage
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }

  /// Remove old cache entries that exceed the stale period
  static Future<void> pruneCache() async {
    await instance.emptyCache();
  }
}
