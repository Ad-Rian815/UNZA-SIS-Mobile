import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:unza_sis_mobile/Pages/api_service.dart';

class ExamSlipPage extends StatelessWidget {
  const ExamSlipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Examination Slip'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            tooltip: 'Export / Print',
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _printExamSlip();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load student data'));
          }

          final user = snapshot.data ?? {};
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: _buildExamSlip(user),
          );
        },
      ),
    );
  }

  Widget _buildExamSlip(Map<String, dynamic> user) {
    final name = (user['studentName'] ?? '').toString();
    final number = (user['username'] ?? '').toString();
    final school = (user['school'] ?? '').toString();
    final program = (user['program'] ?? '').toString();
    final major = (user['major'] ?? '').toString();
    final courses = (user['courses'] as List?) ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Logo
          _buildHeader(),
          SizedBox(height: 20),

          // Student Details
          _buildStudentDetails(
            number: number,
            name: name,
            school: school,
            program: program,
            major: major,
          ),
          SizedBox(height: 20),

          // Course Eligibility
          _buildCourseEligibility(courses),
          SizedBox(height: 20),

          // Instructions for Invigilator
          _buildInvigilatorInstructions(),
          SizedBox(height: 20),

          // Important Notes
          _buildImportantNotes(),
          SizedBox(height: 20),

          // Footer
          _buildFooter(number),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // University Logo (simplified representation)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[100],
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, color: Colors.green, size: 30),
              Text(
                'UNZA',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),

        // University Name
        Text(
          'UNIVERSITY OF ZAMBIA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),

        // Slip Title
        Text(
          'EXAMINATION SLIP 20241',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),

        // Reference and Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REF: EXAMINATION SLIP',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'DATE: ${DateTime.now().day}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentDetails({
    required String number,
    required String name,
    required String school,
    required String program,
    required String major,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('STUDENT ID:', number),
          SizedBox(height: 8),
          _buildDetailRow('NAME:', name),
          SizedBox(height: 8),
          _buildDetailRow('SCHOOL:', school),
          SizedBox(height: 8),
          _buildDetailRow('PROGRAMME:', program),
          SizedBox(height: 8),
          _buildDetailRow('MAJOR:', major),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseEligibility(List courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE BEARER IS ALLOWED TO SIT FOR THE FOLLOWING COURSES ONLY:-',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            courses
                .map((course) => course['code']?.toString() ?? '')
                .join(', '),
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInvigilatorInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TO THE INVIGILATOR:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. IDENTIFY THE STUDENT USING THE PHOTOGRAPH ON THE OFFICIAL STUDENT IDENTITY CARD.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                '2. MAKE SURE THAT THE COMPUTER NUMBER AND THE NAME ON THE IDENTITY CARD MATCH WITH THE ONES ON THIS SLIP',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                '3. THE COURSE AND NAME OF THE STUDENT APPEAR ON THE ATTENDANCE SHEET',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportantNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTE:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• THIS SLIP SHOULD BE SHOWN TO THE INVIGILATOR WITH THE BEARER\'S STUDENT IDENTITY CARD.',
                style: TextStyle(fontSize: 12, color: Colors.red[800]),
              ),
              SizedBox(height: 4),
              Text(
                '• IF THIS SLIP IS LOST OR MUTILATED, CONTACT THE ASST. REGISTRAR (EXAMINATIONS) IMMEDIATELY.',
                style: TextStyle(fontSize: 12, color: Colors.red[800]),
              ),
              SizedBox(height: 4),
              Text(
                '• OTHER WISE YOU WILL NOT BE ALLOWED TO SIT FOR THE EXAMINATION.',
                style: TextStyle(fontSize: 12, color: Colors.red[800]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(String number) {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PRINTED BY: $number',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Signature: _________________',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 1,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _printExamSlip() async {
    final doc = pw.Document();
    final user = await ApiService.getUserData();
    final name = (user['studentName'] ?? '').toString();
    final number = (user['username'] ?? '').toString();
    final school = (user['school'] ?? '').toString();
    final program = (user['program'] ?? '').toString();
    final major = (user['major'] ?? '').toString();
    final courses = (user['courses'] as List?) ?? [];

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          // Header
          pw.Text(
            'UNIVERSITY OF ZAMBIA',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'EXAMINATION SLIP 20241',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('REF: EXAMINATION SLIP'),
              pw.Text(
                  'DATE: ${DateTime.now().day}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}'),
            ],
          ),
          pw.SizedBox(height: 20),

          // Student Details
          pw.Text('STUDENT ID: $number'),
          pw.Text('NAME: $name'),
          pw.Text('SCHOOL: $school'),
          pw.Text('PROGRAMME: $program'),
          pw.Text('MAJOR: $major'),
          pw.SizedBox(height: 20),

          // Course Eligibility
          pw.Text(
            'THE BEARER IS ALLOWED TO SIT FOR THE FOLLOWING COURSES ONLY:-',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            courses
                .map((course) => course['code']?.toString() ?? '')
                .join(', '),
          ),
          pw.SizedBox(height: 20),

          // Instructions for Invigilator
          pw.Text(
            'TO THE INVIGILATOR:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
              '1. IDENTIFY THE STUDENT USING THE PHOTOGRAPH ON THE OFFICIAL STUDENT IDENTITY CARD.'),
          pw.Text(
              '2. MAKE SURE THAT THE COMPUTER NUMBER AND THE NAME ON THE IDENTITY CARD MATCH WITH THE ONES ON THIS SLIP'),
          pw.Text(
              '3. THE COURSE AND NAME OF THE STUDENT APPEAR ON THE ATTENDANCE SHEET'),
          pw.SizedBox(height: 20),

          // Important Notes
          pw.Text(
            'NOTE:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
              '• THIS SLIP SHOULD BE SHOWN TO THE INVIGILATOR WITH THE BEARER\'S STUDENT IDENTITY CARD.'),
          pw.Text(
              '• IF THIS SLIP IS LOST OR MUTILATED, CONTACT THE ASST. REGISTRAR (EXAMINATIONS) IMMEDIATELY.'),
          pw.Text(
              '• OTHER WISE YOU WILL NOT BE ALLOWED TO SIT FOR THE EXAMINATION.'),
          pw.SizedBox(height: 20),

          // Footer
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('PRINTED BY: $number'),
              pw.Text('Signature: _________________'),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
