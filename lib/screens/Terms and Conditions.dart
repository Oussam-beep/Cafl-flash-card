import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
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
                      text: '1. Acceptance of Terms\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'By accessing and using our services, you agree to be bound by these Terms and Conditions.\n\n',
                    ),
                    TextSpan(
                      text: '2. Use of Service\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'You agree to use our services for lawful purposes only and not to engage in any illegal activities.\n\n',
                    ),
                    TextSpan(
                      text: '3. Account Responsibilities\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'You are responsible for maintaining the confidentiality of your account information and for all activities under your account.\n\n',
                    ),
                    TextSpan(
                      text: '4. Limitations of Liability\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'We are not responsible for any direct or indirect damages resulting from the use of our app or services.\n\n',
                    ),
                    TextSpan(
                      text: '5. Termination\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'We may suspend or terminate your access to our services at any time for violations of these Terms and Conditions.\n\n',
                    ),
                    TextSpan(
                      text: '6. Changes to These Terms\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'We reserve the right to modify or update these Terms and Conditions at any time. Changes will be posted on this page.\n\n',
                    ),
                    TextSpan(
                      text: '7. Contact Us\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'If you have any questions about these terms, please contact us.',
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
