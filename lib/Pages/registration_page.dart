import 'package:flutter/material.dart';
import 'package:unza_sis_mobile/Pages/api_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Course Registration"),
        backgroundColor: Colors.green[700],
      ),
      // Replaced static body with dynamic user + finance loader
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          ApiService.getUserData(),
          ApiService.getFinances(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Failed to load registration data'));
          }

          final user = (snapshot.data?[0] as Map<String, dynamic>?) ?? {};
          final finances = (snapshot.data?[1] as Map<String, dynamic>?) ?? {};
          final summary = (finances['summary'] as Map<String, dynamic>?) ?? {};
          final num totalDue = num.tryParse('${summary['totalDue'] ?? 0}') ?? 0;
          final num totalPaid =
              num.tryParse('${summary['totalPaid'] ?? 0}') ?? 0;
          final double ratio = totalDue > 0 ? (totalPaid / totalDue) : 1.0;
          final String status = ratio >= 0.7 ||
                  (user['sponsor'] ?? '')
                      .toString()
                      .toUpperCase()
                      .contains('GRZ')
              ? 'REGISTERED'
              : 'AWAITING PAYMENT';
          final courses = (user['courses'] as List?) ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentInfo(user),
                SizedBox(height: 20),
                _buildRegistrationStatus(status),
                SizedBox(height: 20),
                _buildCourseList(courses),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _handlePrintExamSlip(context),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Download Exam Slip"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Updated to use real user data including sex, nationality, sponsor
  Widget _buildStudentInfo(Map<String, dynamic> user) {
    final id = (user['username'] ?? '').toString();
    final name = (user['studentName'] ?? '').toString();
    final nrc = (user['studentNRC'] ?? '').toString();
    final program = (user['program'] ?? '').toString();
    final major = (user['major'] ?? '').toString();
    final school = (user['school'] ?? '').toString();
    final year = (user['yearOfStudy'] ?? '').toString();
    final sex = (user['sex'] ?? '').toString();
    final nationality = (user['nationality'] ?? '').toString();
    final sponsor = (user['sponsor'] ?? '').toString();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Student ID", id.isEmpty ? 'N/A' : id),
            _infoRow("Student Name", name.isEmpty ? 'N/A' : name),
            _infoRow("Student NRC", nrc.isEmpty ? 'N/A' : nrc),
            _infoRow("Sex", sex.isEmpty ? 'N/A' : sex),
            _infoRow("Nationality", nationality.isEmpty ? 'N/A' : nationality),
            _infoRow("School", school.isEmpty ? 'N/A' : school),
            _infoRow("Program", program.isEmpty ? 'N/A' : program),
            _infoRow("Major", major.isEmpty ? 'N/A' : major),
            _infoRow("Student academic session", "GER 2024 Session"),
            _infoRow("Sponsor", sponsor.isEmpty ? 'N/A' : sponsor),
            _infoRow("Study Year", year.isEmpty ? 'N/A' : year),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePrintExamSlip(BuildContext context) async {
    try {
      final finances = await ApiService.getFinances();
      final summary = (finances['summary'] as Map<String, dynamic>?) ?? {};
      final num totalDue = (summary['totalDue'] ?? 0) is num
          ? summary['totalDue']
          : num.tryParse('${summary['totalDue']}') ?? 0;
      final num totalPaid = (summary['totalPaid'] ?? 0) is num
          ? summary['totalPaid']
          : num.tryParse('${summary['totalPaid']}') ?? 0;
      final user = await ApiService.getUserData();
      final sponsor = (user['sponsor'] ?? '').toString();

      final double ratio = totalDue > 0 ? (totalPaid / totalDue) : 1.0;

      if (ratio < 0.7 && !sponsor.toUpperCase().contains('GRZ')) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Clear Balance'),
            content: Text(
                'You have paid ${_formatPercent(ratio)} of your total fees.\nPlease clear at least 70% to download the exam slip.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
        return;
      }

      await _generateExamSlipPdf();
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to prepare exam slip. Please try again.\n$e'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
          ],
        ),
      );
    }
  }

  Future<void> _generateExamSlipPdf() async {
    final user = await ApiService.getUserData();
    final courses = (user['courses'] as List?) ?? [];

    final doc = pw.Document();

    final String number = (user['username'] ?? '').toString();
    final String name = (user['studentName'] ?? '').toString();
    final String nrc = (user['studentNRC'] ?? '').toString();
    final String program = (user['program'] ?? '').toString();
    final String school = (user['school'] ?? '').toString();
    final String major = (user['major'] ?? '').toString();
    final String yearOfStudy = (user['yearOfStudy'] ?? '').toString();
    final String sex = (user['sex'] ?? '').toString();
    final String nationality = (user['nationality'] ?? '').toString();

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text(
                'UNIVERSITY OF ZAMBIA - CONFIRMATION OF REGISTRATION',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
              child: pw.Text('GER 2024 SESSION',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Table(columnWidths: const {
            0: pw.FixedColumnWidth(140),
            1: pw.FlexColumnWidth(),
            2: pw.FixedColumnWidth(100),
            3: pw.FlexColumnWidth(),
          }, children: [
            _kvRow('NUMBER:', number, 'SEX:', sex),
            _kvRow('NAME:', name, 'NATIONALITY:', nationality),
            _kvRow('YEAR OF BIRTH:', '', 'NRC:', nrc),
            _kvRow('SCHOOL:', school, 'PROGRAMME:', program),
            _kvRow('MAJOR:', major, 'CATEGORY:', 'FULL-TIME'),
            _kvRow(
                'METHOD OF STUDY:', 'REGULAR', 'YEAR OF STUDY:', yearOfStudy),
          ]),
          pw.SizedBox(height: 16),
          pw.Text('COURSES:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (courses.isEmpty)
            pw.Text('No courses found')
          else
            pw.Text(courses.map((c) => '${c['code'] ?? ''}').join(', ')),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.TableRow _kvRow(String k1, String v1, String k2, String v2) {
    return pw.TableRow(children: [
      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(k1)),
      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(v1)),
      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(k2)),
      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(v2)),
    ]);
  }

  String _formatPercent(double r) {
    final p = (r * 100).toStringAsFixed(1);
    return '$p%';
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
        Text("Registration Status",
            style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Now renders provided user courses (codes only)
  Widget _buildCourseList(List<dynamic> courses) {
    final items = courses
        .map((c) => {
              'code': (c['code'] ?? '').toString(),
            })
        .toList();

    return Expanded(
      child: items.isEmpty
          ? const Center(child: Text('No courses found'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final c = items[index];
                return ListTile(
                  leading: Icon(Icons.check, color: Colors.orange),
                  title: Text(c['code']!),
                );
              },
            ),
    );
  }
}
