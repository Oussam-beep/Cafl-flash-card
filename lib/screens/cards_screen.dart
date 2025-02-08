import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DB/MySQL.dart';
import '../DB/db.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardsScreen extends StatefulWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<Map<String, dynamic>> decks = [];
  final TextEditingController deckNameController = TextEditingController();

  final List<Color> deckColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
  Future<void> _createDeck() async {
    if (deckNameController.text.isNotEmpty) {
      bool doesExist = decks.any((deck) => deck['name'] == deckNameController.text);
      if(!doesExist){
          SharedPreferences pref = await SharedPreferences.getInstance();
          int? userid = pref.getInt("id");
          await MYSQL.addDeckToDatabase(userId:userid, name:deckNameController.text, color:colorToHex(deckColors[decks.length % deckColors.length]));
          deckNameController.clear();
          setState(() {});
      }
    }
    Navigator.of(context).pop();
  }

  Color hexToColor(String hexColor) {
    // Remove the '#' if it's present
    hexColor = hexColor.replaceAll('#', '');

    // Parse the hex string to an integer and return a Color
    return Color(int.parse('0xFF$hexColor'));
  }

  Future<void> generateCardsUsingAi(String deckName) async {
    const apiKey = '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';
    const apiUrl = 'https://api-inference.huggingface.co/models/tiiuae/falcon-7b-instruct';

    // Introduce randomness in the prompt
    final randomSeed = Random().nextInt(10000);
    final prompt = "Generate a multiple-choice question with only 4 choices from the field of $deckName."
        "Ensure the question is different each time. (Seed: $randomSeed)";

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
        final generatedText = responseData[0]['generated_text']?.toString() ?? '';
        print("AI Response: $generatedText");

        // Extract the question (find first sentence ending with '?')
        final questionMatch = RegExp(r'(.+?\?)').firstMatch(generatedText);
        final question = questionMatch?.group(1)?.trim() ?? '';

        // Extract answers (handles missing spaces using lookbehind)
        final answerMatches = RegExp(r'(?<=[A-D][).])\s*([^A-D]+)').allMatches(generatedText);
        final answers = answerMatches.map((m) => m.group(1)?.trim() ?? '').toList();

        if (question.isNotEmpty && answers.length == 4) {
          final correctAnswer = answers[0]; // Assuming first option is correct
          final otherAnswers = answers.sublist(1);

          final db = await DB.getDB();
          final deckQuery = await db.query('decks', where: 'name = ?', whereArgs: [deckName]);
          if (deckQuery.isNotEmpty) {
            final deckId = deckQuery.first['id'];
            await db.insert('cards', {
              'deck_id': deckId,
              'question': question,
              'answer_1': correctAnswer,
              'answer_2': otherAnswers[0],
              'answer_3': otherAnswers[1],
              'answer_4': otherAnswers[2],
            });
            print("Question added successfully!");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Deck not found.",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            print("Error: Deck not found.");
          }
        } else {
        }
      } else {
        print("Failed to get response: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  void _showCreateDeckDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.indigo.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create New Deck',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: deckNameController,
                decoration: InputDecoration(
                  hintText: 'Enter deck name',
                  prefixIcon: const Icon(Icons.folder, color: Colors.indigo),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _createDeck,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<Map<String, String>?> _showAddCardDialog(BuildContext context) async {
      final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
      final TextEditingController questionController = TextEditingController();
      final TextEditingController answer1Controller = TextEditingController();
      final TextEditingController answer2Controller = TextEditingController();
      final TextEditingController answer3Controller = TextEditingController();
      final TextEditingController answer4Controller = TextEditingController();

      Map<String, String>? result;

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Card'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Question Field
                    TextFormField(
                      controller: questionController,
                      decoration: InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Question is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.0),

                    // Answer 1 Field
                    TextFormField(
                      controller: answer1Controller,
                      decoration: InputDecoration(
                        labelText: 'Answer 1',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Answer 1 is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    // Answer 2 Field
                    TextFormField(
                      controller: answer2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Answer 2',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Answer 2 is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    // Answer 3 Field
                    TextFormField(
                      controller: answer3Controller,
                      decoration: const InputDecoration(
                        labelText: 'Answer 3',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Answer 3 is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    // Answer 4 Field
                    TextFormField(
                      controller: answer4Controller,
                      decoration: const InputDecoration(
                        labelText: 'Answer 4',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Answer 4 is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    result = {
                      'question': questionController.text,
                      'answer1': answer1Controller.text,
                      'answer2': answer2Controller.text,
                      'answer3': answer3Controller.text,
                      'answer4': answer4Controller.text,
                    };

                    Navigator.pop(context); // Close the dialog
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );

      return result; // Return the map if successful, otherwise null
    }

    Future<void> showEnterDeckDialog() async {
      TextEditingController deckController = TextEditingController();
      TextEditingController questionCountController = TextEditingController();

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Generate Cards Using AI Tools"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: deckController,
                    decoration: const InputDecoration(
                      hintText: "Deck name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing between fields
                  TextField(
                    controller: questionCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter number of Questions",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  String deckName = deckController.text.trim();
                  if (deckName.isNotEmpty) {
                    print("Deck Name: $deckName");

                    int a = int.tryParse(questionCountController.text) ?? 0;

                    if (a > 0) {
                      for (int i = 0; i < a; i++) {
                        await generateCardsUsingAi(deckName);
                      }
                    }
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }

    Future<void> _deleteDeck(String deckName) async {
      final db = await DB.getDB();
      await db.delete(
        'decks',
        where: 'name = ?',
        whereArgs: [deckName],
      );
    }
    void showDeleteDeckDialog() {
      TextEditingController deckNameController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Deck"),
            content: TextField(
              controller: deckNameController,
              decoration: const InputDecoration(
                hintText: "Enter deck name",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  String deckName = deckNameController.text.trim();
                  if (deckName.isNotEmpty) {
                    await _deleteDeck(deckName);
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards', style: TextStyle(
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MYSQL.loadDecksFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Decks Created Yet.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }
          decks = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: decks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              final deck = decks[index];
              return GestureDetector(
                onTap: () async {
                  final result = await _showAddCardDialog(context);
                  if (result != null) {
                    SharedPreferences pref = await SharedPreferences.getInstance();
                    int userId = pref.getInt("id") as int;
                    await MYSQL.addCardToDatabase(deckName: deck['name'], userId: userId, result: result);
                    setState(() {});
                  }
                },
                child: DeckCardTemplate(
                  title: deck['name'],
                  color: hexToColor(deck['color']),
                  cardCount: deck['cards']?.length ?? 0,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showCreateDeckDialog,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16), // Space between buttons
          FloatingActionButton(
            onPressed: showDeleteDeckDialog,
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: showEnterDeckDialog,
            backgroundColor: Colors.greenAccent,
            child: const Icon(Icons.psychology),
          ),
        ],
      ),
    );
  }
}

class DeckCardTemplate extends StatelessWidget {
  final String title;
  final Color color;
  final int cardCount;

  const DeckCardTemplate({
    required this.title,
    required this.color,
    required this.cardCount,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_rounded,
            color: Colors.white.withOpacity(0.9),
            size: 50,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "$cardCount Cards",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
