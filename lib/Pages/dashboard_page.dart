import 'package:flutter/material.dart';
import 'bio_data_page.dart';
import 'accommodation_page.dart';
import 'finances_page.dart';
import 'registration_page.dart';
import 'results_page.dart';
import 'research_page.dart';
import 'elearning_page.dart';
import 'exam_slip_page.dart';
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
  String announcements = "Loading announcements...";

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
        announcements = "No new announcements.";
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
                MaterialPageRoute(builder: (context) => const UserProfilePage()),
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
              Card(
                elevation: 4,
                color: Colors.orange[100],
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Text(
                    announcements,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
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
                            title: Text("${course['code']} - ${course['name']}"),
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
          _buildDrawerItem("My Accommodation", Icons.house, const AccommodationPage()),
          _buildDrawerItem("My Finances", Icons.money, const FinancesPage()),
          _buildDrawerItem("My Registration", Icons.check_box, const RegistrationPage()),
          _buildDrawerItem("My Results", Icons.bar_chart, const ResultsPage()),
          _buildDrawerItem("My Research", Icons.search, const ResearchPage()),
          _buildDrawerItem("My E-Learning", Icons.laptop, const ELearningPage()),
          _buildDrawerItem("My Exam Slip", Icons.assignment, const ExamSlipPage()),
          _buildDrawerItem("QR Code", Icons.qr_code, const QRPage()),
          _buildDrawerItem("Assignments", Icons.assignment_turned_in, const AssignmentsPage()),

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
}
