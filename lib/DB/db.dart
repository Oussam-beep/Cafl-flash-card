import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DB {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) {
      return _db!;
    } else {
      // Initialize databaseFactory for non-mobile platforms (e.g., desktop or testing)
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      _db = await openDatabase(
        join(await databaseFactory.getDatabasesPath(), "Cafl.db"),
        version: 10,
        onCreate: (db, version) async {
          // Create the `users` table
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              first_name TEXT NOT NULL,
              last_name TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL,
              score INTEGER DEFAULT 0
            )
          ''');

          // Create the `decks` table
          await db.execute('''
            CREATE TABLE decks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              color TEXT NOT NULL,
              FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');

          // Create the `cards` table
          await db.execute('''
            CREATE TABLE cards (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              deck_id INTEGER NOT NULL,
              question TEXT NOT NULL,
              answer_1 TEXT NOT NULL,
              answer_2 TEXT NOT NULL,
              answer_3 TEXT NOT NULL,
              answer_4 TEXT NOT NULL,
              FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE
            )
          ''');
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 10) {
            await db.execute('''
          CREATE TABLE IF NOT EXISTS user_quizzes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            date TEXT NOT NULL, -- Stores quiz date (YYYY-MM-DD)
            completed INTEGER DEFAULT 0, -- 0 = Not finished, 1 = Finished
            correct_count INTEGER DEFAULT 0, -- Number of correct answers
            wrong_count INTEGER DEFAULT 0, -- Number of incorrect answers
            FOREIGN KEY(user_id) REFERENCES users(id)
          );
        ''');

            await db.execute('''
          CREATE TABLE IF NOT EXISTS wrong_answers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            question_id INTEGER NOT NULL,
            selected_answer TEXT NOT NULL,
            correct_answer TEXT NOT NULL,
            date TEXT NOT NULL, -- Stores the date of the quiz
            FOREIGN KEY(user_id) REFERENCES users(id),
            FOREIGN KEY(question_id) REFERENCES cards(id)
          );
        ''');
          }
        },
      );
      return _db!;
    }
  }
}
