import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../DB/db.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int? userId;
  int _totalScore = 0;
  List<Map<String, dynamic>> _quizResults = [];
  List<Map<String, dynamic>> _wrongAnswers = [];

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
    await _loadQuizResults();
    await _loadWrongAnswers();
  }

  Future<void> _loadQuizResults() async {
    if (userId == null) return;

    final Database db = await DB.getDB();
    final today = DateTime.now();
    final sevenDaysAgo = today.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];

    // Fetch quiz results for the last 7 days
    final results = await db.query(
      'user_quizzes',
      where: 'user_id = ? AND date >= ?',
      whereArgs: [userId, sevenDaysAgo],
    );

    setState(() {
      _quizResults = results;
      _totalScore = results.fold(0, (sum, result) => sum + (result['correct_count'] as int));
    });
  }

  Future<void> _loadWrongAnswers() async {
    if (userId == null) return;

    final Database db = await DB.getDB();

    // Fetch the most recent 3 to 5 wrong answers
    final wrongAnswers = await db.query(
        'wrong_answers',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 5,
    );

    setState(() {
      _wrongAnswers = wrongAnswers;
    });
  }

  List<FlSpot> _generateChartData(String type) {
    final data = <FlSpot>[];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i)).toIso8601String().split('T')[0];
      final result = _quizResults.firstWhere(
            (result) => result['date'] == date,
        orElse: () => {'correct_count': 0, 'wrong_count': 0},
      );

      data.add(FlSpot(
        i.toDouble(),
        type == 'correct' ? result['correct_count'].toDouble() : result['wrong_count'].toDouble(),
      ));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Screen', style: TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Score
            Text(
              'Total Answered Right Questions: $_totalScore',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Line Chart for Correct Answers
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: const Text(
                      'Weekly Performance: Correct Answers',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];
                                return Text(days[value.toInt()], style: const TextStyle(color: Colors.blue));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(), style: const TextStyle(color: Colors.red));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _generateChartData('correct'),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: const Text(
                      'Weekly Performance: Wrong Answers',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];
                                return Text(days[value.toInt()], style: const TextStyle(color: Colors.blue));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(), style: const TextStyle(color: Colors.red));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _generateChartData('wrong'),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 4,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

// Recent Wrong Answers
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Recent Wrong Answers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  if (_wrongAnswers.isEmpty)
                    const Text(
                      'No wrong answers found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )
                  else
                    Column(
                      children: _wrongAnswers.map((answer) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.redAccent, width: 1),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Question Number: ${answer['question_id']}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Selected: ${answer['selected_answer']}',
                                style: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                              Text(
                                'Correct: ${answer['correct_answer']}',
                                style: TextStyle(color: Colors.green, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}