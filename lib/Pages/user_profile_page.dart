import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'login_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  bool isDarkMode = false;
  File? _image;
  final picker = ImagePicker();
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userData = await ApiService.getUserData();
      print("User Data: $userData"); // Debugging

      final computerNo = userData['computerNo'];
      if (computerNo == null) {
        setState(() {
          userInfo = {"Error": "No student ID available"};
          isLoading = false;
        });
        return;
      }

      final result = await ApiService.fetchStudentData(computerNo);
      print("API Response: $result"); // Debugging

      if (mounted) {
        setState(() {
          isLoading = false;
          if (result['success']) {
            userInfo = {
              "computerNo": userData['computerNo'] ?? "N/A",
              "studentName": result['data']['studentName'] ?? "N/A",
              "studentNRC": result['data']['studentNRC'] ?? "N/A",
            };
          } else {
            userInfo = {"Error": result['message'] ?? "Unknown error"};
          }
        });
      }
    } catch (e) {
      print("Fetch error: $e"); // Debugging
      if (mounted) {
        setState(() {
          userInfo = {"Error": "Failed to load data"};
          isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _viewImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Profile Picture"),
        content: _image != null
            ? Image.file(_image!)
            : const Icon(Icons.camera_alt, size: 100),
        actions: <Widget>[
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullName = userInfo['studentName'] ?? "N/A";
    String studentID = userInfo['computerNo'] ?? "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        backgroundColor: Colors.green[700],
      ),
      backgroundColor: Colors.green[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _viewImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.green[200],
                                backgroundImage: _image != null ? FileImage(_image!) : null,
                                child: _image == null
                                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.black)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text("Full Name: $fullName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Student ID: $studentID", style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text("Change Password", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionTile(Icons.share, "Share with friends"),
                  _buildOptionTile(Icons.reviews, "Review"),
                  const Divider(),
                  SwitchListTile(
                    title: const Text("Dark Mode"),
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: const Text("Log Out", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700], size: 30),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
