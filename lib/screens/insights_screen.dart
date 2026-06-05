import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _loading = true;
  String _error = '';

  int _totalEntries = 0;
  String _mostFrequent = '—';
  Map<String, int> _emotionCounts = {};
  String _insight = '';

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Not logged in.';
          _loading = false;
        });
        return;
      }

      // --- Part 1: Fetch emotion history ---
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .orderBy('timestamp', descending: true)
          .get();

      final docs = snapshot.docs;
      _totalEntries = docs.length;

      // --- Part 2: Calculate statistics ---
      final Map<String, int> counts = {};
      for (final doc in docs) {
        final data = doc.data();
        final emotion = (data['emotion'] as String?)?.trim();
        if (emotion != null && emotion.isNotEmpty) {
          counts[emotion] = (counts[emotion] ?? 0) + 1;
        }
      }

      _emotionCounts = counts;

      if (counts.isNotEmpty) {
        _mostFrequent = counts.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;
      } else {
        _mostFrequent = '—';
      }

      // --- Part 3: Generate insight ---
      _insight = _generateInsight(counts);
    } catch (e) {
      _error = 'Failed to load insights. Please try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _generateInsight(Map<String, int> counts) {
    final stress = counts['Stress'] ?? 0;
    final sadness = counts['Sadness'] ?? 0;
    final anger = counts['Anger'] ?? 0;

    if (stress > 3) {
      return 'You have reported stress frequently this week.';
    }
    if (sadness > 3) {
      return 'You seem to be experiencing persistent sadness.';
    }
    if (anger > 3) {
      return 'You have reported frustration multiple times recently.';
    }
    return 'Your emotional patterns appear balanced.';
  }

  Color _emotionColor(String emotion) {
    switch (emotion) {
      case 'Stress':
        return Colors.orange;
      case 'Sadness':
        return Colors.blueGrey;
      case 'Anger':
        return Colors.red;
      case 'Confusion':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadInsights,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInsights,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // --- Summary card ---
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _statColumn(
                                  '$_totalEntries', 'Total Entries'),
                              const VerticalDivider(thickness: 1),
                              _statColumn(_mostFrequent, 'Top Emotion'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- Emotion breakdown ---
                      const Text(
                        'Emotion Breakdown',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      if (_emotionCounts.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No emotion data yet.',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      else
                        ..._emotionCounts.entries
                            .toList()
                            .sorted()
                            .map((entry) => _emotionCard(
                                entry.key, entry.value)),

                      const SizedBox(height: 16),

                      // --- Insight card ---
                      const Text(
                        'Your Insight',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        color: Colors.deepPurple.shade50,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  color: Colors.deepPurple),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _insight,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _emotionCard(String emotion, int count) {
    final color = _emotionColor(emotion);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                emotion,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              '$count ${count == 1 ? 'entry' : 'entries'}',
              style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple sort extension — highest count first
extension _SortEntries on List<MapEntry<String, int>> {
  List<MapEntry<String, int>> sorted() {
    return this..sort((a, b) => b.value.compareTo(a.value));
  }
}
