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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentId();
  }

  Future<void> _fetchStudentId() async {
    try {
      final userData = await ApiService.getUserData();
      setState(() {
        studentId = userData['computerNo'] ?? "No ID available";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        studentId = "Error fetching ID";
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
                    child: QrImageView( // Use QrImageView instead of QrImage
                      data: studentId,
                      version: QrVersions.auto,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Student ID: $studentId",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
