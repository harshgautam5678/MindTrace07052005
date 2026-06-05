class EmotionStats {
  final int totalEntries;
  final Map<String, int> emotionCounts;
  final String mostFrequentEmotion;

  const EmotionStats({
    required this.totalEntries,
    required this.emotionCounts,
    required this.mostFrequentEmotion,
  });
}
