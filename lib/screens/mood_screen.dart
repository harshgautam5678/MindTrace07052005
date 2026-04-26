import 'package:flutter/material.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood')),
      body: const Center(
        child: Text('Mood Screen', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
