import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../DB/db.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _topUsersFuture;

  @override
  void initState() {
    super.initState();
    _topUsersFuture = _fetchTopUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchTopUsers() async {
    final Database db = await DB.getDB();
    return await db.query(
      'users',
      columns: ['first_name', 'last_name', 'score'],
      orderBy: 'score DESC',
      limit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Color(0xFF2A1B7D),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _topUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF2A1B7D),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text('${user['first_name']} ${user['last_name']}'),
                trailing: Text(
                  '${user['score']} points',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}