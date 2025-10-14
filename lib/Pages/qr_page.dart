import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'api_service.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  QRPageState createState() => QRPageState();
}

class QRPageState extends State<QRPage> {
  String studentId = "Loading...";
  String studentName = "";
  String qrData = "Loading...";
  bool isLoading = true;
  Map<String, dynamic> user = const {};

  @override
  void initState() {
    super.initState();
    _fetchStudentId();
  }

  Future<void> _fetchStudentId() async {
    try {
      final userData = await ApiService.getUserData();
      final username =
          (userData['username'] ?? userData['computerNo'] ?? "").toString();
      final name = (userData['studentName'] ?? "").toString();

      setState(() {
        user = userData;
        studentId = username.isEmpty ? "No ID available" : username;
        studentName = name;
        // Human-readable verification payload so any phone scanner shows a clear confirmation
        final school = (userData['school'] ?? '').toString();
        final program = (userData['program'] ?? '').toString();
        final nrc =
            (userData['studentNRC'] ?? userData['nrc'] ?? '').toString();
        final year = (userData['yearOfStudy'] ?? '').toString();
        qrData = [
          "UNIVERSITY OF ZAMBIA",
          "Student Verification",
          if (studentName.isNotEmpty) "Name: $studentName",
          if (studentId.isNotEmpty) "Student ID: $studentId",
          if (school.isNotEmpty) "School: $school",
          if (program.isNotEmpty) "Program: $program",
          if (nrc.isNotEmpty) "NRC: $nrc",
          if (year.isNotEmpty) "Year: $year",
          "Status: Enrolled"
        ].join("\n");
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        studentId = "Error fetching ID";
        qrData =
            "UNIVERSITY OF ZAMBIA\nStudent Verification\nError fetching ID";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student QR Code"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Scan this QR Code for Student Verification",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: QrImageView(
                      // Use QrImageView instead of QrImage
                      data: qrData,
                      version: QrVersions.auto,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildUnzaIdCard(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUnzaIdCard() {
    final school = (user['school'] ?? 'N/A').toString();
    final program = (user['program'] ?? 'N/A').toString();
    final nrc = (user['studentNRC'] ?? user['nrc'] ?? 'N/A').toString();
    final compNo = studentId.isEmpty ? 'N/A' : studentId;
    final accom = (user['accommodation'] ?? user['accom'] ?? 'N/A').toString();
    final clinicNo = (user['clinicNo'] ?? 'N/A').toString();
    final year = (user['yearOfStudy'] ?? 'N/A').toString();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top green bar with University name
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'THE UNIVERSITY OF ZAMBIA',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Academic year strip
          Container(
            width: double.infinity,
            color: Colors.amber[100],
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: const Text(
              'Academic Year: 2024/2025',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('Name:', studentName.isEmpty ? 'N/A' : studentName,
                    boldValue: true),
                _line('School:', school),
                _line('Program:', program),
                _line('NRC:', nrc),
                _line('Comp No:', compNo),
                _line('Accom.:', accom),
                _line('Clinic No:', clinicNo),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Year: ${year == 'N/A' ? '-' : year}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'UNDER-GRADUATE STUDENT ID (NOT TRANSFERABLE)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool boldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: boldValue ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
