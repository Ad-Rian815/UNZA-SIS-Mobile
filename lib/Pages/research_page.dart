import 'package:flutter/material.dart';

class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("My Research"),
      backgroundColor: Colors.green[700],
    ),
    body: Center(
      child: Text(
        "Research Content Here",
        style: TextStyle(fontSize: 18),
      ),
    ),
  );
}
}
