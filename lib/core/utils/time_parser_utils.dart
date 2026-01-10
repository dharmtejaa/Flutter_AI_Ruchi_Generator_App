/// Utility class for parsing time durations from instruction text
class TimeParserUtils {
  /// Regular expressions to match various time formats
  static final List<RegExp> _timePatterns = [
    // Match "X hours and Y minutes" or "X hour and Y mins"
    RegExp(
      r'(\d+)\s*(?:hours?|hrs?)\s*(?:and)?\s*(\d+)\s*(?:minutes?|mins?)',
      caseSensitive: false,
    ),
    // Match "X minutes" or "X mins" or "X min"
    RegExp(r'(\d+)\s*(?:minutes?|mins?)', caseSensitive: false),
    // Match "X hours" or "X hrs" or "X hr"
    RegExp(r'(\d+)\s*(?:hours?|hrs?)', caseSensitive: false),
    // Match "X seconds" or "X secs" or "X sec"
    RegExp(r'(\d+)\s*(?:seconds?|secs?)', caseSensitive: false),
    // Match "X-Y minutes" (range - use the higher value)
    RegExp(r'(\d+)\s*-\s*(\d+)\s*(?:minutes?|mins?)', caseSensitive: false),
    // Match "X to Y minutes" (range - use the higher value)
    RegExp(r'(\d+)\s*to\s*(\d+)\s*(?:minutes?|mins?)', caseSensitive: false),
  ];

  /// Parse time duration from instruction text
  /// Returns null if no time is found
  static Duration? parseTimeFromText(String text) {
    // Check for hours and minutes pattern first
    final hoursMinutesMatch = _timePatterns[0].firstMatch(text);
    if (hoursMinutesMatch != null) {
      final hours = int.tryParse(hoursMinutesMatch.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(hoursMinutesMatch.group(2) ?? '0') ?? 0;
      return Duration(hours: hours, minutes: minutes);
    }

    // Check for range patterns (use higher value)
    for (int i = 4; i <= 5; i++) {
      final rangeMatch = _timePatterns[i].firstMatch(text);
      if (rangeMatch != null) {
        final higherValue = int.tryParse(rangeMatch.group(2) ?? '0') ?? 0;
        return Duration(minutes: higherValue);
      }
    }

    // Check for minutes pattern
    final minutesMatch = _timePatterns[1].firstMatch(text);
    if (minutesMatch != null) {
      final minutes = int.tryParse(minutesMatch.group(1) ?? '0') ?? 0;
      return Duration(minutes: minutes);
    }

    // Check for hours pattern
    final hoursMatch = _timePatterns[2].firstMatch(text);
    if (hoursMatch != null) {
      final hours = int.tryParse(hoursMatch.group(1) ?? '0') ?? 0;
      return Duration(hours: hours);
    }

    // Check for seconds pattern
    final secondsMatch = _timePatterns[3].firstMatch(text);
    if (secondsMatch != null) {
      final seconds = int.tryParse(secondsMatch.group(1) ?? '0') ?? 0;
      return Duration(seconds: seconds);
    }

    return null;
  }

  /// Check if instruction text contains a time mention
  static bool containsTime(String text) {
    return parseTimeFromText(text) != null;
  }

  /// Format duration to display string
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0 && seconds > 0) {
      return '${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  /// Format remaining time for countdown display (MM:SS or HH:MM:SS)
  static String formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }
}
