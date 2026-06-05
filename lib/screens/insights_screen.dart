import 'package:flutter/material.dart';
import '../models/emotion_stats.dart';
import '../services/emotion_analytics_service.dart';
import '../services/insight_generator.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _analytics = EmotionAnalyticsService();
  final _generator = const InsightGenerator();

  bool _loading = true;
  String _error = '';
  EmotionStats? _stats;
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
      final stats = await _analytics.fetchStats();
      final insight = _generator.generateInsight(
        stats.emotionCounts,
        stats.totalEntries,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _insight = insight;
        });
      }
    } on StateError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Failed to load insights. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _emotionColor(String emotion) {
    return switch (emotion) {
      'Stress' => Colors.orange,
      'Sadness' => Colors.blueGrey,
      'Anger' => Colors.red,
      'Confusion' => Colors.purple,
      _ => Colors.green,
    };
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
              ? _buildError()
              : _buildContent(_stats!),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadInsights,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(EmotionStats stats) {
    final sortedEmotions = stats.emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return RefreshIndicator(
      onRefresh: _loadInsights,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Summary card ──────────────────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statColumn('${stats.totalEntries}', 'Total Entries'),
                  const VerticalDivider(thickness: 1),
                  _statColumn(stats.mostFrequentEmotion, 'Top Emotion'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Emotion breakdown ─────────────────────────────────────────
          const Text(
            'Emotion Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (sortedEmotions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No emotion data yet.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...sortedEmotions
                .map((e) => _emotionCard(e.key, e.value)),

          const SizedBox(height: 20),

          // ── Insight card ──────────────────────────────────────────────
          const Text(
            'Your Insight',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _insight,
                      style: const TextStyle(
                          fontSize: 15, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
