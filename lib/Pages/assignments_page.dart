import 'package:flutter/material.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  AssignmentsPageState createState() => AssignmentsPageState();
}

class AssignmentsPageState extends State<AssignmentsPage> {
  List<Map<String, String>> assignments = [
    {"title": "Software Engineering Report", "dueDate": "March 10, 2025"},
    {"title": "Database Optimization", "dueDate": "March 15, 2025"},
    {"title": "AI Research Paper", "dueDate": "March 20, 2025"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Assignments"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Assignments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    color: Colors.orange[100],
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        assignments[index]['title']!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Due Date: ${assignments[index]['dueDate']}"),
                      trailing: Icon(Icons.assignment, color: Colors.green[800]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
