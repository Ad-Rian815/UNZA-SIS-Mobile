import 'package:flutter/material.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Course Registration"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentInfo(),
            SizedBox(height: 20),
            _buildRegistrationStatus("AWAITING PAYMENT"),
            SizedBox(height: 20),
            _buildCourseList(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Print Confirmation Slip"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Student ID", "2021397963"),
            _infoRow("Student Name", "ADRIAN KAMBANI PHIRI"),
            _infoRow("Student NRC", "649516/10/1"),
            _infoRow("Gender", "MALE"),
            _infoRow("Category", "REGULAR"),
            _infoRow("Sub-Category", "FULL-TIME"),
            _infoRow("Program", "BACHELOR OF COMPUTER SCIENCE"),
            _infoRow("Major", "SOFTWARE ENGINEERING"),
            _infoRow("Intake Year", "2021"),
            _infoRow("Intake", "GER_2021_4YR_TERM_QTA"),
            _infoRow("Current Period", "GER 2024 Session"),
            _infoRow("Study Year", "4th Year"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildRegistrationStatus(String status) {
    Color statusColor = status == "REGISTERED" ? Colors.blue : Colors.yellow;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Registration Status", style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: statusColor,
          child: Text(
            status,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseList() {
    List<Map<String, String>> courses = [
      {"code": "CSC 4004", "name": "PROJECTS", "type": "CORE"},
      {"code": "CSC 4630", "name": "ADVANCED SOFTWARE ENGINEERING", "type": "CORE"},
      {"code": "CSC 4631", "name": "SOFTWARE TESTING AND MAINTENANCE", "type": "CORE"},
      {"code": "CSC 4035", "name": "WEB PROGRAMMING AND TECHNOLOGIES", "type": "CORE"},
      {"code": "CSC 4642", "name": "SOFTWARE AND QUALITY ASSURANCE", "type": "CORE"},
      {"code": "CSC 4505", "name": "GRAPHICS AND VISUAL COMPUTING", "type": "CORE"},
      {"code": "CSC 4792", "name": "DATA MINING AND WAREHOUSING", "type": "CORE"},
      {"code": "CSC 3009", "name": "INDUSTRIAL TRAINING COURSE", "type": "CORE"},
    ];

    return Expanded(
      child: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.check, color: Colors.orange),
            title: Text("${courses[index]['code']} - ${courses[index]['name']}"),
            trailing: Text(courses[index]['type']!, style: TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
}
