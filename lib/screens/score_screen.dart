import 'package:flutter/material.dart';

class ScoreScreen extends StatelessWidget {
  final int score;
  final int totalScore;

  const ScoreScreen({super.key, required this.score, required this.totalScore});

  @override
  Widget build(BuildContext context) {
    final double progressPercentage = score / totalScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Screen'),
        backgroundColor: const Color(0xFF2A1B7D),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProgressCircle(progressPercentage),
            const SizedBox(height: 20),
            Text(
              'You scored $score out of $totalScore',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A1B7D),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(double progressPercentage) {
    return SizedBox(
      height: 250, // Increased height to make the circle bigger
      width: 250,  // Increased width to make the circle bigger
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progressPercentage, // Dynamic progress value
            strokeWidth: 15,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
          Text(
            '${(progressPercentage * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 30, // Increased font size for the percentage text inside the circle
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

