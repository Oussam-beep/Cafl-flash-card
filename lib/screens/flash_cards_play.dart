import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DB/db.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class FlashCardsPlay extends StatefulWidget {
  const FlashCardsPlay({Key? key}) : super(key: key);

  @override
  _FlashCardsPlayState createState() => _FlashCardsPlayState();
}

class _FlashCardsPlayState extends State<FlashCardsPlay> {
  int? userId;
  List<Map<String, dynamic>> wrongAnswersQuestions = [];
  List<Map<String, dynamic>> remainingCardsQuestions = [];
  int currentQuestionIndex = 0;
  TextEditingController answerController = TextEditingController();
  String currentQuestion = '';
  String correctAnswer = '';
  bool showResult = false;
  double result = 0;
  String feedBack = "";
  var db;

  @override
  void initState() {
    super.initState();
    _initializeDatabaseAndLoadQuestions();
  }

  Future<String> callOpenAIChatGPT(String prompt) async {
    const apiKey = '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';
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to load response from OpenAI: ${response.body}');
    }
  }


  Future<String> feedBackToUser(String userAnswer, String correctAnswer) async {
    const apiKey = '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';
    const apiUrl = 'https://api-inference.huggingface.co/models/tiiuae/falcon-7b-instruct';

    final prompt = "Evaluate the answer from 0 to 1. "
        "The correct answer is '$correctAnswer'. The user's answer is '$userAnswer'. "
        "Provide an advice to me to improve the my answering";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': prompt}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is List && responseData.isNotEmpty && responseData[0]['generated_text'] != null) {
          String generatedText = responseData[0]['generated_text'].toString();
          print("AI Raw Response: $generatedText");

          String cleanedResponse = generatedText.replaceFirst(prompt, "").trim();

          return cleanedResponse.isNotEmpty ? cleanedResponse : "Try reviewing this concept for better understanding.";
        } else {
          print("Unexpected response format: ${response.body}");
          return "AI response format error.";
        }
      } else {
        print("API Request Failed: ${response.statusCode}, ${response.body}");
        return "AI service is unavailable. Try again later.";
      }
    } catch (e) {
      print("Error: $e");
      return "⚠An error occurred while processing your request.";
    }
  }


  Future<void> _initializeDatabaseAndLoadQuestions() async {
    db = await DB.getDB();

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id');

    if (userId != null && db != null) {
      wrongAnswersQuestions = [];
      final remainingCardsResult = await db!.rawQuery('''
            SELECT cards.* 
            FROM cards
            INNER JOIN decks ON cards.deck_id = decks.id
            WHERE cards.deck_id IS NOT NULL
            ORDER BY RANDOM()
          ''');

      remainingCardsQuestions = List.from(remainingCardsResult)
          .where((question) =>
      question['question'] != null && question['answer_1'] != null)
          .toList()
          .cast<Map<String, dynamic>>();

      wrongAnswersQuestions.addAll(remainingCardsQuestions);
      if (remainingCardsQuestions.isNotEmpty) {
        _loadQuestion(currentQuestionIndex);
      }
    }
  }

  void _loadQuestion(int index) {
    setState(() {
      // Ensure non-null values for currentQuestion and correctAnswer
      currentQuestion = wrongAnswersQuestions[index]['question'] ?? '';
      correctAnswer = wrongAnswersQuestions[index]['answer_1'] ?? '';
      showResult = false;
      answerController.clear();
    });
  }

  Future<double> evaluateWithHuggingFace(String userAnswer, String correctAnswer) async {
    const apiKey = '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';
    const apiUrl = 'https://api-inference.huggingface.co/models/sentence-transformers/all-MiniLM-L6-v2';

    final requestBody = {
      "inputs": {
        "source_sentence": correctAnswer,
        "sentences": [userAnswer]
      }
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("Response Data: $responseData"); // Debugging output

        // Since responseData is a list, access the first element
        if (responseData is List && responseData.isNotEmpty) {
          final similarityScore = (responseData[0] as num).toDouble();
          print("Similarity Score: $similarityScore");
          return similarityScore;
        } else {
          throw Exception('Unexpected response format: $responseData');
        }
      } else {
        throw Exception('Failed to get response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      return 0.0;
    }
  }


  void _evaluateAnswer(String userAnswer) async {
    try {
      final score = await evaluateWithHuggingFace(userAnswer, correctAnswer);
      final feedBackResult = await feedBackToUser(userAnswer, correctAnswer);
      setState(() {
        result = score;
        feedBack = feedBackResult;
        showResult = true;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        result = (userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) ? 1 : 0;
        feedBack = "";
        showResult = true;
      });
    }
  }


  void _nextQuestion() {
    if (currentQuestionIndex < wrongAnswersQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _loadQuestion(currentQuestionIndex);
      });
    } else {
      // No more questions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more questions!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash Cards Play'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wrongAnswersQuestions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1}: $currentQuestion',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: answerController,
                    decoration: const InputDecoration(
                      labelText: 'Your Answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _evaluateAnswer(answerController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A1B7D), // Change to your preferred color
                          padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Answer',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A1B7D), // Change to your preferred color
                          padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (showResult)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        result > 0.6 ? 'Correct!' : 'Incorrect!',
                        style: TextStyle(
                          color: result > 0.6 ? Colors.green : Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if(showResult)
                    Visibility(
                      visible: true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "The Correct Answer is : $correctAnswer\n$feedBack",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            else
              const Center(
                child: Text('No questions available.'),
              ),
          ],
        ),
      ),
    );
  }
}