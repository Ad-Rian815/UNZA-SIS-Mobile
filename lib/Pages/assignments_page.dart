import 'package:flutter/material.dart';
import 'api_service.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  AssignmentsPageState createState() => AssignmentsPageState();
}

class AssignmentsPageState extends State<AssignmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Assignments"),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load assignments: ${snapshot.error}'));
          }

          final user = snapshot.data ?? {};
          final String program = (user['program'] ?? '').toString();
          final String yearOfStudy = (user['yearOfStudy'] ?? '').toString();
          final String campus = (user['campus'] ?? '').toString();

          final assignments = _getProgramAssignments(
            program: program,
            yearOfStudy: yearOfStudy,
            campus: campus,
          );

          return Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upcoming Assignments",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (program.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          program,
                          style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (assignments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "No assignments due.",
                      style: TextStyle(
                          color: Colors.grey[700], fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final item = assignments[index];
                        return Card(
                          elevation: 4,
                          color: Colors.orange[100],
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: Icon(
                                item['icon'] as IconData? ?? Icons.assignment,
                                color: Colors.green[800]),
                            title: Text(
                              (item['title'] ?? '').toString(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((item['course'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Text((item['course'] ?? '').toString()),
                                if ((item['dueDate'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Text(
                                      "Due Date: ${(item['dueDate'] ?? '').toString()}",
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                              ],
                            ),
                            trailing: (item['action'] != null)
                                ? TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      (item['action'] ?? '').toString(),
                                      style: TextStyle(
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getProgramAssignments({
    required String program,
    required String yearOfStudy,
    required String campus,
  }) {
    final lowerProgram = program.toLowerCase();

    if (lowerProgram.contains('medicine') || lowerProgram.contains('medical')) {
      return [
        {
          'title': 'Clinical Rotation Logbook Submission',
          'course': 'MED 5610 - Internal Medicine Subspecialties',
          'dueDate': 'Dec 12, 2025',
          'icon': Icons.medical_services,
          'action': 'Upload',
        },
        {
          'title': 'Case Study: Pediatric Assessment',
          'course': 'PED 4701 - Pediatrics',
          'dueDate': 'Dec 18, 2025',
          'icon': Icons.child_care,
        },
        if (yearOfStudy == '5')
          {
            'title': 'Clinical Competency Evaluation (Final Year)',
            'course': 'Hospital Assessment',
            'dueDate': 'Jan 05, 2026',
            'icon': Icons.assignment_turned_in,
            'action': 'View Rubric',
          },
      ];
    }

    if (lowerProgram.contains('computer') ||
        lowerProgram.contains('software')) {
      return [
        {
          'title': 'Software Engineering Report',
          'course': 'CSC 4630 - Advanced Software Engineering',
          'dueDate': 'Dec 15, 2025',
          'icon': Icons.code,
        },
        {
          'title': 'Web App Final Project',
          'course': 'CSC 4035 - Web Programming & Technologies',
          'dueDate': 'Dec 20, 2025',
          'icon': Icons.web,
          'action': 'Submit',
        },
        if (yearOfStudy == '4')
          {
            'title': 'Final Year Project Progress Report',
            'course': 'CSC 4004 - Projects',
            'dueDate': 'Jan 10, 2026',
            'icon': Icons.timeline,
          },
      ];
    }

    if (lowerProgram.contains('economics')) {
      return [
        {
          'title': 'Economic Policy Analysis Paper',
          'course': 'ECN 2215 - Microeconomics',
          'dueDate': 'Dec 16, 2025',
          'icon': Icons.trending_up,
        },
        {
          'title': 'Statistics Problem Set',
          'course': 'ECN 2331 - Statistics for Economics',
          'dueDate': 'Dec 19, 2025',
          'icon': Icons.calculate,
        },
      ];
    }

    // Generic fallback
    return [
      {
        'title': 'Research Methods Essay',
        'course': 'RES 2100 - Research Methods',
        'dueDate': 'Dec 22, 2025',
        'icon': Icons.menu_book,
      },
    ];
  }
}
