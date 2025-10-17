import 'package:flutter/material.dart';
import 'bio_data_page.dart';
import 'accommodation_page.dart';
import 'finances_page.dart';
import 'registration_page.dart';
import 'results_page.dart';
import 'research_page.dart';
import 'elearning_page.dart';
import 'user_profile_page.dart';
import 'login_page.dart';
import 'qr_page.dart';
import 'assignments_page.dart';
import 'api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> studentInfo = {};
  List<dynamic> studentCourses = [];
  bool isLoading = true;
  List<Map<String, dynamic>> announcements = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadStudentData();
    _fetchAnnouncements();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await ApiService.checkLoginStatus();
    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _loadStudentData() async {
    try {
      final userData = await ApiService.getUserData();

      if (mounted) {
        setState(() {
          isLoading = false;
          studentInfo = {
            "computerNo": userData['username'] ?? "N/A",
            "studentName": userData['studentName'] ?? "N/A",
            "studentNRC": userData['studentNRC'] ?? "N/A",
            "yearOfStudy": userData['yearOfStudy'] ?? "N/A",
            "program": userData['program'] ?? "N/A",
            "school": userData['school'] ?? "N/A",
            "campus": userData['campus'] ?? "N/A",
            "major": userData['major'] ?? "N/A",
            "intake": userData['intake'] ?? "N/A",
            // New fields
            "sex": userData['sex'] ?? "N/A",
            "nationality": userData['nationality'] ?? "N/A",
            "sponsor": userData['sponsor'] ?? "N/A",
          };

          studentCourses = userData['courses'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          studentInfo = {"error": "An error occurred: $e"};
        });
      }
    }
  }

  Future<void> _fetchAnnouncements() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        announcements = _getPersonalizedAnnouncements();
      });
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            iconSize: 30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserProfilePage()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAnnouncementsSection(),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: isLoading
                        ? [const Center(child: CircularProgressIndicator())]
                        : _buildStudentDetails(),
                  ),
                ),
              ),
              if (studentCourses.isNotEmpty) ...[
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Registered Courses:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...studentCourses.map((course) {
                          return ListTile(
                            leading: const Icon(Icons.book,
                                color: Colors.green, size: 28),
                            title:
                                Text("${course['code']} - ${course['name']}"),
                            subtitle: Text(
                                "Type: ${course['half_or_full_course'] == '1' ? "Full" : "Half"}"),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[800]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Student Portal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem("My Bio Data", Icons.person, const BioDataPage()),
          _buildDrawerItem(
              "My Accommodation", Icons.house, const AccommodationPage()),
          _buildDrawerItem("My Finances", Icons.money, const FinancesPage()),
          _buildDrawerItem(
              "My Registration", Icons.check_box, const RegistrationPage()),
          _buildDrawerItem("My Results", Icons.bar_chart, const ResultsPage()),
          _buildDrawerItem("My Research", Icons.search, const ResearchPage()),
          _buildDrawerItem(
              "My E-Learning", Icons.laptop, const ELearningPage()),
          _buildDrawerItem("QR Code", Icons.qr_code, const QRPage()),
          _buildDrawerItem("Assignments", Icons.assignment_turned_in,
              const AssignmentsPage()),

          const Divider(),

          // 🔹 Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String text, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[800]),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  List<Widget> _buildStudentDetails() {
    if (studentInfo.containsKey("error")) {
      return [
        Text(
          studentInfo["error"],
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      ];
    }

    return [
      _buildDetailRow("Student Name:", studentInfo["studentName"]),
      _buildDetailRow("Computer No:", studentInfo["computerNo"]),
      _buildDetailRow("NRC:", studentInfo["studentNRC"]),
      _buildDetailRow("Year of Study:", studentInfo["yearOfStudy"]),
      _buildDetailRow("Program:", studentInfo["program"]),
      _buildDetailRow("School:", studentInfo["school"]),
      _buildDetailRow("Campus:", studentInfo["campus"]),
      _buildDetailRow("Major:", studentInfo["major"]),
      _buildDetailRow("Intake:", studentInfo["intake"]),
      // New details
      _buildDetailRow("Sex:", studentInfo["sex"]),
      _buildDetailRow("Nationality:", studentInfo["nationality"]),
      _buildDetailRow("Sponsor:", studentInfo["sponsor"]),
    ];
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    if (announcements.isEmpty) {
      return Card(
        elevation: 4,
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Text(
            "No new announcements.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📢 Announcements",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...announcements
            .map((announcement) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAnnouncementCard(announcement),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final type = announcement['type'] ?? 'general';
    final priority = announcement['priority'] ?? 'normal';

    Color cardColor;
    IconData icon;

    switch (type) {
      case 'academic':
        cardColor =
            priority == 'critical' ? Colors.red[100]! : Colors.blue[100]!;
        icon = Icons.school;
        break;
      case 'financial':
        cardColor = Colors.orange[100]!;
        icon = Icons.money;
        break;
      case 'campus':
        cardColor = Colors.green[100]!;
        icon = Icons.location_city;
        break;
      case 'research':
        cardColor = Colors.purple[100]!;
        icon = Icons.science;
        break;
      case 'emergency':
        cardColor = Colors.red[200]!;
        icon = Icons.warning;
        break;
      default:
        cardColor = Colors.grey[100]!;
        icon = Icons.info;
    }

    return Card(
      elevation: 4,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    announcement['title'] ?? 'Announcement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: priority == 'critical'
                          ? Colors.red[800]
                          : Colors.grey[800],
                    ),
                  ),
                ),
                if (priority == 'critical')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              announcement['content'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  announcement['timeAgo'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (announcement['action'] != null)
                  TextButton(
                    onPressed: () {
                      // Handle action
                    },
                    child: Text(
                      announcement['action']!,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getPersonalizedAnnouncements() {
    final program = studentInfo['program'] ?? '';
    final yearOfStudy = studentInfo['yearOfStudy'] ?? '';
    final campus = studentInfo['campus'] ?? '';
    final sponsor = studentInfo['sponsor'] ?? '';

    List<Map<String, dynamic>> personalizedAnnouncements = [];

    // Academic announcements based on program
    if (program.toLowerCase().contains('computer') ||
        program.toLowerCase().contains('software')) {
      personalizedAnnouncements.addAll([
        {
          'type': 'academic',
          'priority': 'high',
          'title': 'Software Engineering Final Year Project Guidelines',
          'content':
              'Final year CS students: Project proposals are due by December 20th. Please submit your project ideas to your supervisors.',
          'timeAgo': '2 hours ago',
          'action': 'View Guidelines',
        },
        {
          'type': 'research',
          'priority': 'normal',
          'title': 'Tech Innovation Expo 2025',
          'content':
              'Showcase your software projects at the annual Tech Innovation Expo. Registration opens January 15th.',
          'timeAgo': '1 day ago',
          'action': 'Register',
        },
      ]);
    } else if (program.toLowerCase().contains('medicine') ||
        program.toLowerCase().contains('medical')) {
      personalizedAnnouncements.addAll([
        {
          'type': 'academic',
          'priority': 'critical',
          'title': 'Clinical Rotation Schedule Update',
          'content':
              'Important: Clinical rotation schedules for Medicine students have been updated. Check your new assignments.',
          'timeAgo': '30 minutes ago',
          'action': 'View Schedule',
        },
        {
          'type': 'research',
          'priority': 'normal',
          'title': 'Medical Research Symposium',
          'content':
              'Submit your research abstracts for the 2025 Medical Research Symposium. Deadline: February 1st.',
          'timeAgo': '3 days ago',
          'action': 'Submit Abstract',
        },
      ]);
    } else if (program.toLowerCase().contains('economics')) {
      personalizedAnnouncements.addAll([
        {
          'type': 'academic',
          'priority': 'high',
          'title': 'Economic Policy Analysis Workshop',
          'content':
              'Economics students: Join the Economic Policy Analysis Workshop on December 18th. Limited seats available.',
          'timeAgo': '4 hours ago',
          'action': 'Register',
        },
        {
          'type': 'research',
          'priority': 'normal',
          'title': 'Zambian Economic Development Conference',
          'content':
              'Call for papers: Zambian Economic Development Conference 2025. Submit your research by March 1st.',
          'timeAgo': '1 week ago',
          'action': 'Submit Paper',
        },
      ]);
    }

    // Year-specific announcements
    if (yearOfStudy == '4') {
      personalizedAnnouncements.add({
        'type': 'academic',
        'priority': 'critical',
        'title': 'Graduation Application Deadline',
        'content':
            'Final year students: Graduation applications are due by January 15th. Don\'t miss this important deadline!',
        'timeAgo': '1 day ago',
        'action': 'Apply Now',
      });
    } else if (yearOfStudy == '1') {
      personalizedAnnouncements.add({
        'type': 'campus',
        'priority': 'normal',
        'title': 'First Year Orientation Week',
        'content':
            'Welcome to UNZA! Join us for orientation activities and campus tours throughout the week.',
        'timeAgo': '2 days ago',
        'action': 'View Schedule',
      });
    }

    // Financial announcements based on sponsor
    if (sponsor.toLowerCase().contains('self')) {
      personalizedAnnouncements.add({
        'type': 'financial',
        'priority': 'high',
        'title': 'Tuition Fee Payment Reminder',
        'content':
            'Self-sponsored students: Second semester fees are due by December 31st. Late payment penalties apply.',
        'timeAgo': '6 hours ago',
        'action': 'Pay Now',
      });
    } else if (sponsor.toLowerCase().contains('grz')) {
      personalizedAnnouncements.add({
        'type': 'financial',
        'priority': 'normal',
        'title': 'GRZ Sponsorship Update',
        'content':
            'GRZ sponsored students: Your sponsorship status has been confirmed for the current academic year.',
        'timeAgo': '1 day ago',
        'action': 'View Details',
      });
    }

    // Campus-specific announcements
    if (campus.toLowerCase().contains('main')) {
      personalizedAnnouncements.add({
        'type': 'campus',
        'priority': 'normal',
        'title': 'Main Campus Library Extended Hours',
        'content':
            'The main campus library will have extended hours during exam period: 6 AM - 11 PM daily.',
        'timeAgo': '2 days ago',
        'action': 'View Hours',
      });
    } else if (campus.toLowerCase().contains('ridgeway')) {
      personalizedAnnouncements.add({
        'type': 'campus',
        'priority': 'normal',
        'title': 'Ridgeway Campus Shuttle Service',
        'content':
            'New shuttle service between Ridgeway and Main Campus starts Monday. Free for all students.',
        'timeAgo': '3 days ago',
        'action': 'View Schedule',
      });
    }

    // General announcements
    personalizedAnnouncements.addAll([
      {
        'type': 'academic',
        'priority': 'normal',
        'title': 'Exam Schedule Released',
        'content':
            'The examination schedule for the current semester has been published. Check your specific exam dates.',
        'timeAgo': '1 day ago',
        'action': 'View Schedule',
      },
      {
        'type': 'campus',
        'priority': 'normal',
        'title': 'Student ID Card Renewal',
        'content':
            'All students are required to renew their ID cards by the end of the semester. Visit the registrar\'s office.',
        'timeAgo': '4 days ago',
        'action': 'Renew Now',
      },
    ]);

    // Sort by priority and time
    personalizedAnnouncements.sort((a, b) {
      final priorityOrder = {'critical': 0, 'high': 1, 'normal': 2, 'low': 3};
      final aPriority = priorityOrder[a['priority']] ?? 2;
      final bPriority = priorityOrder[b['priority']] ?? 2;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      // If same priority, sort by time (most recent first)
      return b['timeAgo'].compareTo(a['timeAgo']);
    });

    return personalizedAnnouncements
        .take(5)
        .toList(); // Show top 5 announcements
  }
}
