import 'package:flutter/material.dart';
import 'package:mobile_dev_project/screens/login_screen.dart'; // Import the LoginScreen

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1B7D),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              _buildSectionTitle('Account Settings'),
              _buildSettingsItem(
                context,
                icon: Icons.account_circle_outlined,
                title: 'Profile',
                onTap: () {
                  // Navigate to profile page
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  // Navigate to password change page
                },
              ),
              const Divider(),

              _buildSectionTitle('Preferences'),
              _buildSettingsItem(
                context,
                icon: Icons.palette_outlined,
                title: 'Theme',
                onTap: () {
                  // Theme selection action
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.language_outlined,
                title: 'Language',
                onTap: () {
                  // Language selection action
                },
              ),
              const Divider(),

              _buildSectionTitle('Notifications'),
              _buildSwitchSetting(
                context,
                icon: Icons.notifications,
                title: 'Enable Notifications',
                value: true,
                onChanged: (bool value) {},
              ),
              _buildSwitchSetting(
                context,
                icon: Icons.notifications_active,
                title: 'Sound Notifications',
                value: false,
                onChanged: (bool value) {},
              ),
              const Divider(),

              _buildSectionTitle('Help & Support'),
              _buildSettingsItem(
                context,
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {
                  // Navigate to Help page
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                onTap: () {
                  // Navigate to feedback page
                },
              ),
              const Divider(),

              _buildSectionTitle('Logout'),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Log out action: navigate to login screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false, // Prevent back navigation to the SettingsPage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2A1B7D),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: const Color(0xFF2A1B7D),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFF2A1B7D),
        size: 16,
      ),
    );
  }

  Widget _buildSwitchSetting(BuildContext context, {required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF2A1B7D),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2A1B7D),
      ),
    );
  }
}
