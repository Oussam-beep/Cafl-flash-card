import 'package:flutter/material.dart';
import 'package:mobile_dev_project/screens/decks_screen.dart';
import 'package:mobile_dev_project/screens/cards_screen.dart';
import 'package:mobile_dev_project/screens/score_screen.dart';
import 'package:mobile_dev_project/screens/profile_screen.dart'; // Update the path based on your file structure
import 'package:mobile_dev_project/screens/settingspage.dart'; // Import the SettingsPage

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final int score = 12; // Example score
  final int totalScore = 20; // Example total score

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            Expanded(child: _buildContent(context)),
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Cafl',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.notifications),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Content Section
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Cafl your learning app",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildMenuList(context),
              ),
              Expanded(
                flex: 3,
                child: _buildStudyProgress(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Menu List
  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      {'title': 'Quiz Mode', 'destination': const DecksScreen()},
      {'title': 'Flash Cards', 'destination': const CardsScreen()},
      {'title': 'Score', 'destination': ScoreScreen(score: score, totalScore: totalScore)},
      {'title': 'Grade', 'destination': null}, // You can implement this screen later
      {'title': 'Settings', 'destination': const SettingsPage()}, // Link to SettingsPage
    ];

    return Column(
      children: menuItems
          .map((item) => _buildMenuItem(
        context,
        item['title'] as String, // Cast 'title' to String explicitly
        item['destination'] as Widget?, // Cast 'destination' to Widget?
      ))
          .toList(),
    );
  }

  // Menu Item
  Widget _buildMenuItem(BuildContext context, String title, Widget? destination) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1B7D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // Study Progress
  Widget _buildStudyProgress() {
    final double progressPercentage = (score / totalScore);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B7D),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Study Progress",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 200, // Increased size for a larger circle
                width: 200,
                child: CircularProgressIndicator(
                  value: progressPercentage,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: Colors.white,
                ),
              ),
              Text(
                '${(progressPercentage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF2A1B7D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.bar_chart, color: Colors.white),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.play_arrow, color: Color(0xFF2A1B7D)),
          ),
          Icon(Icons.book, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
      ),
    );
  }
}
