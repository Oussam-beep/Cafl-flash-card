import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_dev_project/screens/cards_screen.dart';
import 'package:mobile_dev_project/screens/score_screen.dart';
import 'package:mobile_dev_project/screens/profile_screen.dart'; // Update the path based on your file structure
import 'package:mobile_dev_project/screens/quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DB/MySQL.dart';
import 'flash_cards_play.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>?> _loadUser () async
  {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = pref.getInt('id')!;
    return MYSQL.getUserById(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadUser(), // Waits for _loadUser to complete
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Show error message
        } else {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildContent(
                        context,
                        snapshot.data!['score'],
                        (snapshot.data!['total_correct_answers'] + snapshot.data!['total_wrong_answers']) == 0
                            ? 0
                            : double.parse(
                            ((snapshot.data!['total_correct_answers'].toDouble() /
                                (snapshot.data!['total_correct_answers'].toDouble() +
                                    snapshot.data!['total_wrong_answers'].toDouble()))
                            ).toStringAsFixed(2)
                        )
                    ),
                  ),
                  _buildBottomNavigationBar(context),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // Header Section
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cafl',
            style: GoogleFonts.lobster(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Row(
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  // Content Section
  Widget _buildContent(BuildContext context, int score, double? answerRightPercentageQuestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Cafl is an AI-powered learning app with smart flashcards, quizzes, and personalized feedback for effective studying. 🚀📚",
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
                flex: 3,
                child: _buildStudyProgress(context, score, answerRightPercentageQuestions),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Menu List
  Widget _buildMenuList(BuildContext context, int index) {
    final menuItems = [
      {'title': 'Quiz Mode', 'destination': const QuizScreen()},
      {'title': 'Decks & Cards', 'destination': const CardsScreen()},
      {'title': 'Score', 'destination': const ScoreScreen()},
      {'title': 'Flash Cards', 'destination': const FlashCardsPlay()}, // You can implement this screen later
      {'title': 'Settings', 'destination': const ProfileScreen()}, // Link to SettingsPage
    ];

    // Check if the index is within the range of the menuItems list
    if (index >= 0 && index < menuItems.length) {
      final item = menuItems[index];
      return _buildMenuItem(
        context,
        item['title'] as String, // Cast 'title' to String explicitly
        item['destination'] as Widget?, // Cast 'destination' to Widget?
      );
    } else {
      // Return an empty widget or an error message if index is out of range
      return const SizedBox();
    }
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
  Widget _buildStudyProgress(BuildContext context, int score, double? answerRightPercentageQuestions) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Stack(
        children: [
          // Half-circle with text
          Align(
            alignment: Alignment.centerRight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double circleSize = constraints.maxWidth * 0.6; // 60% of the width
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize * 2, // Keep the height proportional
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A1B7D),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10000),
                          bottomLeft: Radius.circular(10000),
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(40, 0), // Adjust these values to move the column
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Daily Progress:', // Title text
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20), // Space between the circle and the texts
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: circleSize * 0.5, // Adjust CircularProgressIndicator size
                                    height: circleSize * 0.5,
                                    child: CircularProgressIndicator(
                                      value: answerRightPercentageQuestions, // Example progress value
                                      strokeWidth: 8.0,
                                      backgroundColor: Colors.grey.withOpacity(0.3),
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${(answerRightPercentageQuestions!*100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: circleSize * 0.1, // Text size proportional to the circle
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 50), // Space between the circle and the texts
                              const Text(
                                'Score:', // Title text
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$score', // Replace with the actual score value
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Lines extending to the left with text and varying width
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  5, // Number of lines
                      (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: index < 2 ? 6 - index : index + 3,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A1B7D),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: _buildMenuList(context, index),
                              ),
                            ),
                          ),
                          // Empty space to ensure it doesn't extend past the center
                          const Spacer(flex: 4),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2A1B7D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => (),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScoreScreen())),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizScreen())),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.play_arrow, color: Color(0xFF2A1B7D)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.book, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CardsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
        ],
      ),
    );
  }
}
