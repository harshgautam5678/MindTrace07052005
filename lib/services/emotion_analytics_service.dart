import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emotion_stats.dart';

class EmotionAnalyticsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EmotionAnalyticsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Fetches all journal entries for the current user, calculates emotion
  /// statistics, and returns an [EmotionStats] result.
  ///
  /// Throws a [StateError] if no user is currently signed in.
  Future<EmotionStats> fetchStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user found.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .get();

    final docs = snapshot.docs;
    final int totalEntries = docs.length;

    // Count occurrences of each emotion label.
    final Map<String, int> emotionCounts = {};
    for (final doc in docs) {
      final emotion = (doc.data()['emotion'] as String?)?.trim();
      if (emotion != null && emotion.isNotEmpty) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }

    // Determine the most frequent emotion, or '—' if no data.
    final String mostFrequent = emotionCounts.isEmpty
        ? '—'
        : emotionCounts.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;

    return EmotionStats(
      totalEntries: totalEntries,
      emotionCounts: emotionCounts,
      mostFrequentEmotion: mostFrequent,
    );
  }
}
