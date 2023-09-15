import 'package:flutter/material.dart';
import 'video_call_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.video_call),
          label: const Text('JOIN CALL CHANNEL'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VideoCallScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
