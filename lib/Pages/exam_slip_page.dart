import 'package:flutter/material.dart';

class ExamSlipPage extends StatelessWidget {
  const ExamSlipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Exam Slip"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Text(
          "Exam Slip Content Here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
