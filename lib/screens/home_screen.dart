import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mood_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> _fetchLatestMood() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'No mood logged yet';

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return 'No mood logged yet';

    final score = snapshot.docs.first.data()['score'];
    return 'Your last mood: $score/10';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: _fetchLatestMood(),
              builder: (context, snapshot) {
                final text = snapshot.connectionState == ConnectionState.waiting
                    ? 'Loading...'
                    : (snapshot.data ?? 'No mood logged yet');
                return Text(
                  text,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MoodScreen()),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Log Mood'),
            ),
          ],
        ),
      ),
    );
  }
}
