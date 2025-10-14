import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:unza_sis_mobile/Pages/api_service.dart';

class ConfirmationSlipPage extends StatelessWidget {
  const ConfirmationSlipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation Slip'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            tooltip: 'Export / Print',
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _printConfirmationSlip();
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
            child: _buildConfirmationSlip(user),
          );
        },
      ),
    );
  }

  Widget _buildConfirmationSlip(Map<String, dynamic> user) {
    final name = (user['studentName'] ?? '').toString();
    final number = (user['username'] ?? '').toString();
    final sex = (user['sex'] ?? '').toString();
    final nationality = (user['nationality'] ?? '').toString();
    final nrc = (user['studentNRC'] ?? '').toString();
    final yearOfBirth = '2002-08-15'; // This would come from actual data
    final maritalStatus = 'S'; // This would come from actual data
    final school = (user['school'] ?? '').toString();
    final program = (user['program'] ?? '').toString();
    final major = (user['major'] ?? '').toString();
    final yearOfStudy = (user['yearOfStudy'] ?? '').toString();
    final methodOfStudy = 'REGULAR'; // This would come from actual data
    final category = 'FULL-TIME'; // This would come from actual data
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
          // Header Section
          _buildHeader(),
          SizedBox(height: 20),

          // Dotted line separator
          Container(
            height: 1,
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
          SizedBox(height: 10),

          // Session
          Text(
            'GER 2024 SESSION',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),

          // Student Details Section
          _buildStudentDetails(
            number: number,
            name: name,
            sex: sex,
            yearOfBirth: yearOfBirth,
            nationality: nationality,
            nrc: nrc,
            maritalStatus: maritalStatus,
            school: school,
            program: program,
            major: major,
            yearOfStudy: yearOfStudy,
            methodOfStudy: methodOfStudy,
            category: category,
          ),
          SizedBox(height: 20),

          // Courses Section
          _buildCoursesSection(courses),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Timestamp (top left)
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year.toString().substring(2)}, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour < 12 ? 'AM' : 'PM'}',
            style: TextStyle(fontSize: 12),
          ),
        ),
        SizedBox(height: 10),

        // Main title
        Text(
          'Confirmation Slip',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),

        // Date (top right)
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12),
          ),
        ),
        SizedBox(height: 10),

        // University name
        Text(
          'UNIVERSITY OF ZAMBIA - CONFIRMATION OF REGISTRATION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentDetails({
    required String number,
    required String name,
    required String sex,
    required String yearOfBirth,
    required String nationality,
    required String nrc,
    required String maritalStatus,
    required String school,
    required String program,
    required String major,
    required String yearOfStudy,
    required String methodOfStudy,
    required String category,
  }) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // First row
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDetailRow('NUMBER:', number),
              ),
              Expanded(
                flex: 2,
                child: _buildDetailRow('NAME:', name),
              ),
              Expanded(
                flex: 1,
                child: _buildDetailRow('SEX:', sex),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Second row
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDetailRow('MARITAL STATUS:', maritalStatus),
              ),
              Expanded(
                flex: 2,
                child: _buildDetailRow('YEAR OF BIRTH:', yearOfBirth),
              ),
              Expanded(
                flex: 1,
                child: _buildDetailRow('NATIONALITY:', nationality),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Third row
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDetailRow('SCHOOL:', school),
              ),
              Expanded(
                flex: 2,
                child: _buildDetailRow('PROGRAMME:', program),
              ),
              Expanded(
                flex: 1,
                child: _buildDetailRow('NRC:', nrc),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Fourth row
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDetailRow('METHOD OF STUDY:', methodOfStudy),
              ),
              Expanded(
                flex: 2,
                child: _buildDetailRow('MAJOR:', major),
              ),
              Expanded(
                flex: 1,
                child: _buildDetailRow('CATEGORY:', category),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Fifth row
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDetailRow('', ''),
              ),
              Expanded(
                flex: 2,
                child: _buildDetailRow('YEAR OF STUDY:', yearOfStudy),
              ),
              Expanded(
                flex: 1,
                child: _buildDetailRow('', ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCoursesSection(List courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'COURSES:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                courses
                    .map((course) => course['code']?.toString() ?? '')
                    .join(', '),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _printConfirmationSlip() async {
    final doc = pw.Document();
    final user = await ApiService.getUserData();
    final name = (user['studentName'] ?? '').toString();
    final number = (user['username'] ?? '').toString();
    final sex = (user['sex'] ?? '').toString();
    final nationality = (user['nationality'] ?? '').toString();
    final nrc = (user['studentNRC'] ?? '').toString();
    final yearOfBirth = '2002-08-15';
    final maritalStatus = 'S';
    final school = (user['school'] ?? '').toString();
    final program = (user['program'] ?? '').toString();
    final major = (user['major'] ?? '').toString();
    final yearOfStudy = (user['yearOfStudy'] ?? '').toString();
    final methodOfStudy = 'REGULAR';
    final category = 'FULL-TIME';
    final courses = (user['courses'] as List?) ?? [];

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          // Header
          pw.Text(
            'Confirmation Slip',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'UNIVERSITY OF ZAMBIA - CONFIRMATION OF REGISTRATION',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 20),

          // Dotted line
          pw.Divider(),
          pw.SizedBox(height: 10),

          // Session
          pw.Text(
            'GER 2024 SESSION',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 20),

          // Student details table
          pw.Table(
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Text('NUMBER:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('NAME:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('SEX:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text(number),
                  pw.Text(name),
                  pw.Text(sex),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text('MARITAL STATUS:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('YEAR OF BIRTH:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('NATIONALITY:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text(maritalStatus),
                  pw.Text(yearOfBirth),
                  pw.Text(nationality),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text('SCHOOL:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('PROGRAMME:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('NRC:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text(school),
                  pw.Text(program),
                  pw.Text(nrc),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text('METHOD OF STUDY:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('MAJOR:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('CATEGORY:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text(methodOfStudy),
                  pw.Text(major),
                  pw.Text(category),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text(''),
                  pw.Text('YEAR OF STUDY:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(''),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text(''),
                  pw.Text(yearOfStudy),
                  pw.Text(''),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Courses section
          pw.Row(
            children: [
              pw.Text('COURSES:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  courses
                      .map((course) => course['code']?.toString() ?? '')
                      .join(', '),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
