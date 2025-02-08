import 'package:flutter/material.dart';
import 'package:mobile_dev_project/Screens/cards_screen.dart';
import 'package:mobile_dev_project/screens/profile_screen.dart';
import 'package:mobile_dev_project/screens/score_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../DB/db.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Map<String, dynamic>>> _questionsFuture;
  int? userId;
  bool _quizCompleted = false;
  bool _isLoading = true; // Track if data is still loading
  int _correctCount = 0;
  int _wrongCount = 0;
  List<Map<String, dynamic>> _incorrectAnswers = [];
  List<Map<String, dynamic>> _questions = [];
  Map<int, String?> _selectedAnswers = {}; // Track selected answers for each question

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('id');
    });
    await _checkQuizCompletion();
    _questionsFuture = _fetchQuestions();
  }

  Future<void> _checkQuizCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final lastQuizDate = prefs.getString('lastQuizDate');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastQuizDate == today) {
      setState(() {
        _quizCompleted = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchQuestions() async {
    final Database db = await DB.getDB();
    final List<Map<String, dynamic>> result = await db.rawQuery('''
          SELECT cards.id, cards.question, cards.answer_1, cards.answer_2, cards.answer_3, cards.answer_4
          FROM cards
          INNER JOIN decks ON cards.deck_id = decks.id
          ORDER BY RANDOM()
          LIMIT 20
        ''');
    return result;
  }

  Future<void> _updateUserScore(int scoreIncrement) async {
    if (userId == null) return;
    final Database db = await DB.getDB();
    await db.rawUpdate(
      'UPDATE users SET score = score + ? WHERE id = ?',
      [scoreIncrement, userId],
    );
  }

  Future<void> _recordQuizResults() async {
    if (userId == null) return;

    final Database db = await DB.getDB();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Update the user's score based on the number of correct answers
    await _updateUserScore(_correctCount); // Add this line

    // Insert quiz results into `user_quizzes` table
    await db.insert(
      'user_quizzes',
      {
        'user_id': userId,
        'date': today,
        'completed': 1,
        'correct_count': _correctCount,
        'wrong_count': _wrongCount,
      },
    );

    // Insert incorrect answers into `wrong_answers` table
    for (final answer in _incorrectAnswers) {
      await db.insert(
        'wrong_answers',
        {
          'user_id': userId,
          'question_id': answer['question_id'],
          'selected_answer': answer['selected_answer'],
          'correct_answer': answer['correct_answer'],
          'date': today,
        },
      );
    }

    // Update SharedPreferences to mark quiz as completed for today
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastQuizDate', today);

    // Navigate to the home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _onAnswerSelected(int questionId, String selectedAnswer, String correctAnswer) {
    if (_selectedAnswers[questionId] != null) return; // Prevent re-answering

    setState(() {
      _selectedAnswers[questionId] = selectedAnswer;
      if (selectedAnswer == correctAnswer) {
        _correctCount++;
      } else {
        _wrongCount++;
        _incorrectAnswers.add({
          'question_id': questionId,
          'selected_answer': selectedAnswer,
          'correct_answer': correctAnswer,
        });
      }

      // Check if all questions are answered
      if (_selectedAnswers.length == _questions.length) {
        _recordQuizResults();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Mode', style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2A1B7D),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _quizCompleted
            ? const Center(child: Text('You have already completed the quiz today.'))
            : FutureBuilder<List<Map<String, dynamic>>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No questions available'));
            }

            // Save questions for later use (only once)
            if (_questions.isEmpty) {
              _questions = snapshot.data!;
            }

            return ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                final questionId = question['id'];
                final correctAnswer = question['answer_1'];
                final selectedAnswer = _selectedAnswers[questionId];

                return _buildQuizResult(
                  question['question'],
                  [
                    question['answer_1'],
                    question['answer_2'],
                    question['answer_3'],
                    question['answer_4'],
                  ],
                  correctAnswer,
                  questionId,
                  selectedAnswer,
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScoreScreen())),
          ),
          GestureDetector(
            onTap: () => (),
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

  Widget _buildQuizResult(
      String title,
      List<String> choices,
      String correctAnswer,
      int questionId,
      String? selectedAnswer,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: choices.map((choice) {
              Color? color;
              if (selectedAnswer != null) {
                color = (choice == selectedAnswer)
                    ? (choice == correctAnswer ? Colors.green : Colors.red)
                    : Colors.transparent;
              }

              return GestureDetector(
                onTap: () {
                  if (selectedAnswer == null) {
                    _onAnswerSelected(questionId, choice, correctAnswer);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '• $choice',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}