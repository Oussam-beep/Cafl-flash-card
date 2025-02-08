import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Color(0xFF2A1B7D),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16, height: 1.5),
                  children: [
                    TextSpan(
                      text: '1. Information Collection\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'We collect personal information you provide, such as your name, email, and other details when you register and use our services.\n\n',
                    ),
                    TextSpan(
                      text: '2. Use of Information\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Your information helps us improve our services, communicate with you, and provide a personalized experience.\n\n',
                    ),
                    TextSpan(
                      text: '3. Data Security\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'We implement reasonable security measures to protect your personal data and ensure its safety.\n\n',
                    ),
                    TextSpan(
                      text: '4. Your Rights\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'You have the right to access, update, or delete your personal information. Contact us to exercise these rights.\n\n',
                    ),
                    TextSpan(
                      text: '5. Changes to This Policy\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'We may update this Privacy Policy periodically. Any changes will be posted here with an updated effective date.\n\n',
                    ),
                    TextSpan(
                      text: '6. Third-Party Services\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Our app may contain links to third-party services. We are not responsible for the privacy practices of these external platforms. '
                          'Please review their policies before sharing any personal information.\n\n',
                    ),
                    TextSpan(
                      text: '7. Cookies and Tracking Technologies\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'We may use cookies or similar tracking technologies to enhance your experience and analyze app usage. '
                          'You can manage your preferences through your device settings.\n\n',
                    ),
                    TextSpan(
                      text: '8. Children\'s Privacy\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Our services are not intended for children under 13. We do not knowingly collect personal information from children. '
                          'If you believe a child has provided us with data, please contact us for its removal.\n\n',
                    ),
                    TextSpan(
                      text: '9. Contact Us\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'If you have any questions or concerns about this Privacy Policy, feel free to reach out to us at [Your Contact Info].',
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
