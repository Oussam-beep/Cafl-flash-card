import 'package:flutter/material.dart';
import 'package:mobile_dev_project/screens/home_screen.dart';
import 'package:mobile_dev_project/screens/login_screen.dart';
import 'package:mobile_dev_project/screens/privacy%20policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DB/MySQL.dart';
import 'Terms and Conditions.dart';
import 'edit_profile_info.dart';
import 'leader_board.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<Map<String, dynamic>?> _loadUser () async
  {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = pref.getInt('id')!;
    return MYSQL.getUserById(userId: userId);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ).then((_) {
              setState(() {}); // Refresh UI when back
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _loadUser(), // Your function to load user data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(), // Show loading indicator
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('No data available'),
              );
            }

            final user = snapshot.data!; // Get user data from the snapshot

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(user['first_name'], user['last_name'], user['email']), // Pass user data to the header
                  const SizedBox(height: 20),
                  _buildStatCards(user['score'], user['num_of_cards'], user['num_of_quizez']), // Pass user data to the stat cards
                  const SizedBox(height: 30),
                  _buildActionButtons(context),
                  const SizedBox(height: 30),
                  _buildAdditionalOptions(context), // Pass context here
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String fname, String lname, String email) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/9100/9100612.png'), // Replace with actual image URL
        ),
        const SizedBox(height: 20),
        Text(
          fname +" "+ lname,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          email,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
          icon: const Icon(Icons.edit, size: 18, color: Colors.white),
          label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2A1B7D), // Corrected here
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(int score, int numOfCards, int numOfQuizez) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard('Quizzes', '$numOfQuizez', Icons.quiz),
          _buildStatCard('Flashcards', '$numOfCards', Icons.style),
          _buildStatCard('Score', '$score', Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Color(0xFF2A1B7D)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionButton(
            title: 'Leader Board',
            icon: Icons.leaderboard,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
              );
            },
          ),
          _buildActionButton(
            title: 'Change Password',
            icon: Icons.lock,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF2A1B7D)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildAdditionalOption(
            title: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
              );
            },
          ),
          _buildAdditionalOption(
            title: 'Terms & Conditions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsAndConditionsPage()),
              );
            },
          ),
          _buildAdditionalOption(
            title: 'Logout',
            onTap: () {
              // Handle logout
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false, // Prevent back navigation to the ProfileScreen
              );
            },
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOption({required String title, required VoidCallback onTap, bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isDanger ? Colors.red : Color(0xFF2A1B7D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
