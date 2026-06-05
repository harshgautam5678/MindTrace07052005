/// Converts emotion statistics into a human-readable insight string.
class InsightGenerator {
  const InsightGenerator();

  /// Returns a plain-English insight based on [emotionCounts] and [totalEntries].
  ///
  /// Rules (in priority order):
  /// 1. No entries → prompt the user to write more.
  /// 2. Most frequent emotion → tailored advice.
  /// 3. Fallback → balanced pattern message.
  ///
  /// Always appends a summary line with the total entry count.
  String generateInsight(
    Map<String, int> emotionCounts,
    int totalEntries,
  ) {
    if (totalEntries == 0) {
      return 'Not enough journal entries to generate insights.';
    }

    final String body;

    if (emotionCounts.isEmpty) {
      body = 'Your emotional patterns appear balanced.';
    } else {
      final topEmotion = emotionCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;

      body = switch (topEmotion) {
        'Stress' =>
          'You have reported stress most frequently. Consider monitoring '
              'workload, deadlines, and recovery time.',
        'Sadness' =>
          'Sadness appears often in your recent entries. Reflect on recurring '
              'situations that may be affecting your mood.',
        'Anger' =>
          'You have reported frustration several times. Identifying triggers '
              'may help improve emotional control.',
        'Confusion' =>
          'You seem to be facing uncertainty. Breaking large decisions into '
              'smaller steps may help.',
        _ => 'Your emotional patterns appear balanced.',
      };
    }

    return '$body\n\nTotal journal entries analyzed: $totalEntries';
  }
}
