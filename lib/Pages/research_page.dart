import 'package:flutter/material.dart';
import 'api_service.dart';

class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Research"),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load data: ${snapshot.error}'));
          }

          final userData = snapshot.data ?? {};
          final program = userData['program'] ?? '';
          final yearOfStudy = userData['yearOfStudy'] ?? '';
          final studentName = userData['studentName'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(studentName, program),
                const SizedBox(height: 20),
                _buildQuickStats(program),
                const SizedBox(height: 20),
                _buildCurrentProjects(program, yearOfStudy),
                const SizedBox(height: 20),
                _buildResearchResources(program),
                const SizedBox(height: 20),
                _buildUpcomingEvents(program),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(String studentName, String program) {
    final programIcon = _getProgramIcon(program);
    final programDescription = _getProgramDescription(program);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                programIcon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Research Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (studentName.isNotEmpty)
                      Text(
                        "Welcome, $studentName",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            programDescription,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(String program) {
    final stats = _getProgramStats(program);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard("Active Projects", stats['projects'] ?? '0',
              Icons.science, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard("Publications", stats['publications'] ?? '0',
              Icons.article, Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard("Deadlines", stats['deadlines'] ?? '0',
              Icons.schedule, Colors.red),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentProjects(String program, String yearOfStudy) {
    final projects = _getProgramProjects(program, yearOfStudy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🚀 Current Research Projects",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...projects
            .map((project) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProjectCard(
                    project['title'],
                    project['supervisor'],
                    project['status'],
                    project['color'],
                    project['progress'],
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildProjectCard(String title, String supervisor, String status,
      Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Supervisor: $supervisor",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            "${(progress * 100).toInt()}% Complete",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchResources(String program) {
    final resources = _getProgramResources(program);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📚 Research Resources",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...resources
            .map((resourceRow) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: resourceRow
                        .map((resource) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: _buildResourceButton(
                                  resource['title'],
                                  resource['icon'],
                                  resource['color'],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildResourceButton(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(String program) {
    final events = _getProgramEvents(program);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📅 Upcoming Research Events",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...events
            .map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildEventCard(
                    event['title'],
                    event['date'],
                    event['icon'],
                    event['color'],
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildEventCard(
      String title, String date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for program-specific data
  String _getProgramIcon(String program) {
    if (program.toLowerCase().contains('computer') ||
        program.toLowerCase().contains('software')) {
      return '💻';
    } else if (program.toLowerCase().contains('medicine') ||
        program.toLowerCase().contains('medical')) {
      return '🏥';
    } else if (program.toLowerCase().contains('economics')) {
      return '📊';
    } else if (program.toLowerCase().contains('engineering')) {
      return '⚙️';
    } else if (program.toLowerCase().contains('science')) {
      return '🔬';
    } else {
      return '🎓';
    }
  }

  String _getProgramDescription(String program) {
    if (program.toLowerCase().contains('computer') ||
        program.toLowerCase().contains('software')) {
      return "Explore cutting-edge technology research and software development projects";
    } else if (program.toLowerCase().contains('medicine') ||
        program.toLowerCase().contains('medical')) {
      return "Advance medical knowledge through clinical research and healthcare innovation";
    } else if (program.toLowerCase().contains('economics')) {
      return "Analyze economic trends and contribute to policy research and development";
    } else if (program.toLowerCase().contains('engineering')) {
      return "Design innovative solutions and conduct engineering research projects";
    } else if (program.toLowerCase().contains('science')) {
      return "Investigate scientific phenomena and contribute to research discoveries";
    } else {
      return "Track your research progress and access academic resources";
    }
  }

  Map<String, String> _getProgramStats(String program) {
    if (program.toLowerCase().contains('computer') ||
        program.toLowerCase().contains('software')) {
      return {'projects': '3', 'publications': '2', 'deadlines': '4'};
    } else if (program.toLowerCase().contains('medicine') ||
        program.toLowerCase().contains('medical')) {
      return {'projects': '2', 'publications': '1', 'deadlines': '3'};
    } else if (program.toLowerCase().contains('economics')) {
      return {'projects': '1', 'publications': '0', 'deadlines': '2'};
    } else if (program.toLowerCase().contains('engineering')) {
      return {'projects': '2', 'publications': '1', 'deadlines': '3'};
    } else {
      return {'projects': '1', 'publications': '0', 'deadlines': '2'};
    }
  }

  List<Map<String, dynamic>> _getProgramProjects(
      String program, String yearOfStudy) {
    if (program.toLowerCase().contains('computer') ||
        program.toLowerCase().contains('software')) {
      return [
        {
          'title': 'AI-Powered Healthcare Diagnostics',
          'supervisor': 'Dr. Mwamba',
          'status': 'In Progress',
          'color': Colors.green,
          'progress': 0.7,
        },
        {
          'title': 'Blockchain Security Framework',
          'supervisor': 'Prof. Banda',
          'status': 'Data Collection',
          'color': Colors.blue,
          'progress': 0.4,
        },
        if (yearOfStudy == '4')
          {
            'title': 'Final Year Project: Smart Campus System',
            'supervisor': 'Dr. Phiri',
            'status': 'Planning',
            'color': Colors.orange,
            'progress': 0.2,
          },
      ];
    } else if (program.toLowerCase().contains('medicine') ||
        program.toLowerCase().contains('medical')) {
      return [
        {
          'title': 'Malaria Prevention Strategies',
          'supervisor': 'Dr. Mwamba',
          'status': 'In Progress',
          'color': Colors.green,
          'progress': 0.6,
        },
        {
          'title': 'Telemedicine Implementation',
          'supervisor': 'Prof. Banda',
          'status': 'Literature Review',
          'color': Colors.blue,
          'progress': 0.3,
        },
      ];
    } else if (program.toLowerCase().contains('economics')) {
      return [
        {
          'title': 'Zambian Economic Growth Analysis',
          'supervisor': 'Dr. Mwamba',
          'status': 'Data Collection',
          'color': Colors.blue,
          'progress': 0.5,
        },
      ];
    } else if (program.toLowerCase().contains('engineering')) {
      return [
        {
          'title': 'Renewable Energy Solutions',
          'supervisor': 'Dr. Mwamba',
          'status': 'In Progress',
          'color': Colors.green,
          'progress': 0.6,
        },
        {
          'title': 'Water Treatment Systems',
          'supervisor': 'Prof. Banda',
          'status': 'Testing',
          'color': Colors.orange,
          'progress': 0.8,
        },
      ];
    } else {
      return [
        {
          'title': 'General Research Project',
          'supervisor': 'Dr. Mwamba',
          'status': 'Planning',
          'color': Colors.blue,
          'progress': 0.3,
        },
      ];
    }
  }

  List<List<Map<String, dynamic>>> _getProgramResources(String program) {
    if (program.toLowerCase().contains('computer') ||
        program.toLowerCase().contains('software')) {
      return [
        [
          {
            'title': 'IEEE Xplore',
            'icon': Icons.library_books,
            'color': Colors.blue
          },
          {
            'title': 'ACM Digital Library',
            'icon': Icons.computer,
            'color': Colors.green
          },
        ],
        [
          {
            'title': 'GitHub Research',
            'icon': Icons.code,
            'color': Colors.orange
          },
          {
            'title': 'Stack Overflow',
            'icon': Icons.help,
            'color': Colors.purple
          },
        ],
        [
          {
            'title': 'Research Templates',
            'icon': Icons.description,
            'color': Colors.teal
          },
          {
            'title': 'Citation Tools',
            'icon': Icons.format_quote,
            'color': Colors.indigo
          },
        ],
      ];
    } else if (program.toLowerCase().contains('medicine') ||
        program.toLowerCase().contains('medical')) {
      return [
        [
          {
            'title': 'PubMed',
            'icon': Icons.medical_services,
            'color': Colors.red
          },
          {'title': 'WHO Database', 'icon': Icons.public, 'color': Colors.blue},
        ],
        [
          {
            'title': 'Clinical Guidelines',
            'icon': Icons.assignment,
            'color': Colors.green
          },
          {
            'title': 'Medical Journals',
            'icon': Icons.article,
            'color': Colors.orange
          },
        ],
        [
          {
            'title': 'Research Ethics',
            'icon': Icons.verified_user,
            'color': Colors.purple
          },
          {
            'title': 'Case Study Templates',
            'icon': Icons.folder,
            'color': Colors.teal
          },
        ],
      ];
    } else if (program.toLowerCase().contains('economics')) {
      return [
        [
          {
            'title': 'World Bank Data',
            'icon': Icons.public,
            'color': Colors.blue
          },
          {
            'title': 'IMF Research',
            'icon': Icons.trending_up,
            'color': Colors.green
          },
        ],
        [
          {
            'title': 'Economic Indicators',
            'icon': Icons.analytics,
            'color': Colors.orange
          },
          {
            'title': 'Policy Papers',
            'icon': Icons.description,
            'color': Colors.purple
          },
        ],
        [
          {
            'title': 'Statistical Tools',
            'icon': Icons.calculate,
            'color': Colors.teal
          },
          {
            'title': 'Research Methods',
            'icon': Icons.school,
            'color': Colors.indigo
          },
        ],
      ];
    } else if (program.toLowerCase().contains('engineering')) {
      return [
        [
          {
            'title': 'Engineering Standards',
            'icon': Icons.build,
            'color': Colors.blue
          },
          {
            'title': 'Technical Journals',
            'icon': Icons.article,
            'color': Colors.green
          },
        ],
        [
          {
            'title': 'CAD Resources',
            'icon': Icons.design_services,
            'color': Colors.orange
          },
          {
            'title': 'Simulation Tools',
            'icon': Icons.science,
            'color': Colors.purple
          },
        ],
        [
          {
            'title': 'Project Templates',
            'icon': Icons.folder,
            'color': Colors.teal
          },
          {
            'title': 'Safety Guidelines',
            'icon': Icons.security,
            'color': Colors.red
          },
        ],
      ];
    } else {
      return [
        [
          {
            'title': 'Library Database',
            'icon': Icons.library_books,
            'color': Colors.blue
          },
          {
            'title': 'Citation Tools',
            'icon': Icons.format_quote,
            'color': Colors.green
          },
        ],
        [
          {
            'title': 'Research Templates',
            'icon': Icons.description,
            'color': Colors.orange
          },
          {
            'title': 'Writing Guidelines',
            'icon': Icons.edit,
            'color': Colors.purple
          },
        ],
      ];
    }
  }

  List<Map<String, dynamic>> _getProgramEvents(String program) {
    if (program.toLowerCase().contains('computer') ||
        program.toLowerCase().contains('software')) {
      return [
        {
          'title': 'Software Engineering Conference',
          'date': 'Dec 15, 2024',
          'icon': Icons.computer,
          'color': Colors.blue,
        },
        {
          'title': 'Final Year Project Defense',
          'date': 'Jan 20, 2025',
          'icon': Icons.school,
          'color': Colors.green,
        },
        {
          'title': 'Tech Innovation Expo',
          'date': 'Mar 10, 2025',
          'icon': Icons.lightbulb,
          'color': Colors.orange,
        },
      ];
    } else if (program.toLowerCase().contains('medicine') ||
        program.toLowerCase().contains('medical')) {
      return [
        {
          'title': 'Clinical Research Symposium',
          'date': 'Dec 15, 2024',
          'icon': Icons.medical_services,
          'color': Colors.red,
        },
        {
          'title': 'Medical Ethics Workshop',
          'date': 'Jan 20, 2025',
          'icon': Icons.verified_user,
          'color': Colors.blue,
        },
        {
          'title': 'Healthcare Innovation Summit',
          'date': 'Mar 10, 2025',
          'icon': Icons.health_and_safety,
          'color': Colors.green,
        },
      ];
    } else if (program.toLowerCase().contains('economics')) {
      return [
        {
          'title': 'Economic Policy Forum',
          'date': 'Dec 15, 2024',
          'icon': Icons.trending_up,
          'color': Colors.blue,
        },
        {
          'title': 'Research Proposal Defense',
          'date': 'Jan 20, 2025',
          'icon': Icons.assignment,
          'color': Colors.green,
        },
      ];
    } else if (program.toLowerCase().contains('engineering')) {
      return [
        {
          'title': 'Engineering Design Expo',
          'date': 'Dec 15, 2024',
          'icon': Icons.build,
          'color': Colors.blue,
        },
        {
          'title': 'Technical Paper Presentation',
          'date': 'Jan 20, 2025',
          'icon': Icons.present_to_all,
          'color': Colors.green,
        },
        {
          'title': 'Innovation Challenge',
          'date': 'Mar 10, 2025',
          'icon': Icons.emoji_events,
          'color': Colors.orange,
        },
      ];
    } else {
      return [
        {
          'title': 'Research Proposal Deadline',
          'date': 'Dec 15, 2024',
          'icon': Icons.assignment,
          'color': Colors.red,
        },
        {
          'title': 'Academic Conference',
          'date': 'Jan 20, 2025',
          'icon': Icons.event,
          'color': Colors.blue,
        },
        {
          'title': 'Thesis Defense',
          'date': 'Mar 10, 2025',
          'icon': Icons.school,
          'color': Colors.green,
        },
      ];
    }
  }
}
