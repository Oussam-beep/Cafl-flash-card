import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'db.dart';

class MYSQL
{
  static Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final db = await DB.getDB();

    try {
      await db.insert(
        'users',
        {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'score': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true; // Registration successful
    } catch (e) {
      print("Error during registration: $e");
      return false; // Registration failed (e.g., duplicate email)
    }
  }

  static Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await DB.getDB();

    try {
      // Query the 'users' table for the given email and password
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first; // Login successful, return user data
      } else {
        return null; // Login failed (no user found)
      }
    } catch (e) {
      print("Error during login: $e");
      return null; // Error occurred
    }
  }


  static Future<List<Map<String, dynamic>>> loadDecksFromDatabase() async {
    final db = await DB.getDB();

    try {
      // Retrieve user_id from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('id'); // Assuming 'id' is stored as an integer

      if (userId == null) {
        print("User ID not found in SharedPreferences.");
        return [];
      }

      // Fetch decks belonging to the user
      final List<Map<String, dynamic>> decks = await db.query(
        'decks',
        where: 'user_id = ?',  // Assuming 'decks' table has a 'user_id' column
        whereArgs: [userId],
      );

      // Create a new list to store decks with their cards
      final List<Map<String, dynamic>> result = [];

      for (var deck in decks) {
        final int deckId = deck['id']; // Assuming the primary key of the decks table is 'id'

        // Fetch cards for the current deck
        final List<Map<String, dynamic>> cards = await db.query(
          'cards',
          where: 'deck_id = ?',
          whereArgs: [deckId],
        );

        // Create a new map for the deck and add the cards
        result.add({
          ...deck, // Copy all existing deck fields
          'cards': cards, // Add the list of cards
        });
      }

      return result;
    } catch (e) {
      print("Error loading decks and cards from database: $e");
      return [];
    }
  }



  static Future<void> addDeckToDatabase({
    required int? userId,
    required String name,
    required String color,
  }) async {
    final db = await DB.getDB();

    try {
      // Insert the new deck into the 'decks' table
      await db.insert(
        'decks',
        {
          'user_id': userId,
          'name': name,
          'color': color,
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Handles duplicate entries
      );
      print("Deck added successfully: $name");
    } catch (e) {
      print("Error adding deck to database: $e");
    }
  }

  static Future<void> addCardToDatabase({
    required String deckName,
    required int userId,
    required Map<String, String> result,
  }) async {
    final db = await DB.getDB();
    try {
      final deckQueryResult = await db.rawQuery('''
      SELECT id AS deck_id
      FROM decks
      WHERE name = ? AND user_id = ?
      LIMIT 1
    ''', [deckName, userId]);

      if (deckQueryResult.isEmpty) {
        print("No deck found with the name: $deckName for user ID: $userId");
        return;
      }

      final deckId = deckQueryResult.first['deck_id'] as int;

      // Insert the card into the 'cards' table
      await db.insert(
        'cards',
        {
          'deck_id': deckId,
          'question': result['question'],
          'answer_1': result['answer1'],
          'answer_2': result['answer2'],
          'answer_3': result['answer3'],
          'answer_4': result['answer4'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Handles duplicate entries
      );

      print("Card added successfully to deck: $deckName");
    } catch (e) {
      print("Error adding card to database: $e");
    }
  }

  static Future<Map<String, dynamic>?> getUserById({required int userId}) async {
    final db = await DB.getDB();

    try {
      // Query the users table for the row with the matching userId
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1, // Limit to 1 result
      );

      // Check if a user was found
      if (result.isNotEmpty) {
        final user = result.first;

        // Query the number of cards associated with the user (through decks)
        final List<Map<String, dynamic>> cardCountResult = await db.rawQuery('''
        SELECT COUNT(cards.id) AS num_of_cards
        FROM cards
        JOIN decks ON cards.deck_id = decks.id
        WHERE decks.user_id = ?
      ''', [userId]);

        // Prepare the result as a new map combining user and num_of_cards
        final Map<String, dynamic> resultWithCardCount = {
          ...user, // Spread the user data
          'num_of_cards': cardCountResult.isNotEmpty ? cardCountResult.first['num_of_cards'] ?? 0 : 0
        };



        final List<Map<String, dynamic>> quizesCountResult= await db.rawQuery('''
        SELECT COUNT(user_quizzes.id) AS num_of_quizez
        FROM user_quizzes
        WHERE user_id = ?
      ''', [userId]);

        final Map<String, dynamic> resultFinalAll = {
          ...resultWithCardCount,
          'num_of_quizez': quizesCountResult.isNotEmpty ? quizesCountResult.first['num_of_quizez'] ?? 0 : 0
        };


        final List<Map<String, dynamic>> correctAnswersResult = await db.rawQuery('''
        SELECT SUM(correct_count) AS total_correct_answers
        FROM user_quizzes
        WHERE user_id = ?
      ''', [userId]);

        final Map<String, dynamic> resultFinalAll1 = {
          ...resultFinalAll,
          'total_correct_answers': correctAnswersResult.isNotEmpty ? correctAnswersResult.first['total_correct_answers'] ?? 0 : 0
        };

        final List<Map<String, dynamic>> wrongAnswersResult = await db.rawQuery('''
        SELECT SUM(wrong_count) AS total_wrong_answers
        FROM user_quizzes
        WHERE user_id = ?
      ''', [userId]);


        final Map<String, dynamic> resultFinalAll2 = {
          ...resultFinalAll1,
          'total_wrong_answers': wrongAnswersResult.isNotEmpty ? wrongAnswersResult.first['total_wrong_answers'] ?? 0 : 0
        };


        return resultFinalAll2;
      } else {
        print("No user found with ID: $userId");
        return null;
      }
    } catch (e) {
      print("Error retrieving user from database: $e");
      return null;
    }
  }




}
