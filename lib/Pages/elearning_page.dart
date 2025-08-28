import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ELearningPage extends StatelessWidget {
  const ELearningPage({super.key});

  final String moodleUrl = "https://moodle.unza.zm/login/index.php";

  void _launchURL() async {
    final Uri url = Uri.parse(moodleUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $moodleUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("E-Learning Portal"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchURL,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text("Go to E-Learning Portal"),
        ),
      ),
    );
  }
}
