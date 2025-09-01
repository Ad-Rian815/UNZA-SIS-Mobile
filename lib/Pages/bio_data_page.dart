import 'package:flutter/material.dart';
import 'api_service.dart';

class BioDataPage extends StatefulWidget {
  const BioDataPage({super.key});

  @override
  BioDataPageState createState() => BioDataPageState();
}

class BioDataPageState extends State<BioDataPage> {
  Map<String, dynamic> bioData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBioData();
  }

  Future<void> _fetchBioData() async {
    try {
      final userData = await ApiService.getUserData();

      if (mounted) {
        setState(() {
          isLoading = false;
          bioData = {
            "school": userData['school'] ?? "N/A",
            "campus": userData['campus'] ?? "N/A",
            "programme": userData['program'] ?? "N/A", // 👈 fixed key
            "major": userData['major'] ?? "N/A",
            "computerNo": userData['username'] ?? "N/A",
            "studentName": userData['studentName'] ?? "N/A",
            "studentNRC": userData['studentNRC'] ?? "N/A",
            "yearOfStudy": userData['yearOfStudy'] ?? "N/A",
            "intake": userData['intake'] ?? "N/A",
            // you can add more if backend provides them later
          };
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          bioData = {"Error": "Failed to load data"};
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bio Data"),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Programme Details"),
                  _buildContainer([
                    _buildDetailRow("School", bioData['school'] ?? "N/A"),
                    _buildDetailRow("Campus", bioData['campus'] ?? "N/A"),
                    _buildDetailRow("Programme", bioData['programme'] ?? "N/A"),
                    _buildDetailRow("Major", bioData['major'] ?? "N/A"),
                  ]),
                  _buildSectionTitle("Personal Information"),
                  _buildContainer([
                    _buildDetailRow("Student ID", bioData['computerNo'] ?? "N/A"),
                    _buildDetailRow("Full Name", bioData['studentName'] ?? "N/A"),
                    _buildDetailRow("NRC", bioData['studentNRC'] ?? "N/A"),
                    _buildDetailRow("Year of Study", bioData['yearOfStudy'] ?? "N/A"),
                    _buildDetailRow("Intake", bioData['intake'] ?? "N/A"),
                    // optional changeable fields
                    _buildDetailRow("Phone Number", bioData['phone'] ?? "N/A", changeable: true),
                    _buildDetailRow("Residential Address", bioData['residentialAddress'] ?? "N/A", changeable: true),
                    _buildDetailRow("Postal Address", bioData['postalAddress'] ?? "N/A", changeable: true),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.green[700],
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool changeable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$title: ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (changeable) _buildButton("Change", () {}),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        backgroundColor: Colors.green[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
