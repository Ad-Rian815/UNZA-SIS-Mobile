import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("My Results"),
      backgroundColor: Colors.green[700],
    ),
    body: Center(
      child: Text(
        "Results Content Here",
        style: TextStyle(fontSize: 18),
      ),
    ),
  );
}
}
