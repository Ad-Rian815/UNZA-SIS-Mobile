import 'package:flutter/material.dart';
import 'package:unza_sis_mobile/Pages/api_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Results"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            tooltip: 'Export Results',
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _exportResultsPdf(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          ApiService.getUserData(),
          ApiService.getResults(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load student data'));
          }

          final user = (snapshot.data?[0] as Map<String, dynamic>?) ?? {};
          final results = (snapshot.data?[1] as Map<String, dynamic>?) ??
              {'academicYears': <dynamic>[]};
          final academicYears =
              (results['academicYears'] as List<dynamic>? ?? []);
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Information Header
                _buildStudentInfoHeader(user),
                SizedBox(height: 20),

                // Continuous Assessment Results
                _buildContinuousAssessmentSection(),
                SizedBox(height: 20),

                // Examination Results & GPA Computation
                _buildExaminationResultsSection(),
                SizedBox(height: 20),

                // Academic Year Results (student-specific)
                if (academicYears.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No results available yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  )
                else
                  ..._buildAcademicYearsFromData(academicYears),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportResultsPdf(BuildContext context) async {
    try {
      final user = await ApiService.getUserData();
      final results = await ApiService.getResults();
      final academicYears = (results['academicYears'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final pdf = pw.Document();

      // Header styles
      final headerStyle = pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
      );
      final sectionTitleStyle = pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.green800,
      );

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(24),
          ),
          build: (context) => [
            // Title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_sanitizePlain('UNZA - Student Course Results'),
                    style: headerStyle),
                pw.Text(
                  _sanitizePlain(_formatNow()),
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700),
                )
              ],
            ),
            pw.SizedBox(height: 8),

            // Student info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                color: PdfColors.grey100,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      _sanitizePlain(
                          'Computer number: ${user['username'] ?? ''}'),
                      style: const pw.TextStyle(fontSize: 11)),
                  pw.Text(_sanitizePlain('Names: ${user['studentName'] ?? ''}'),
                      style: const pw.TextStyle(fontSize: 11)),
                  pw.Text(_sanitizePlain('Gender: ${user['sex'] ?? ''}'),
                      style: const pw.TextStyle(fontSize: 11)),
                  pw.Text(_sanitizePlain('Programme: ${user['program'] ?? ''}'),
                      style: const pw.TextStyle(fontSize: 11)),
                  pw.Text(
                      _sanitizePlain(
                          'Year of Study: ${user['yearOfStudy'] ?? ''}'),
                      style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Academic years
            if (academicYears.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Center(
                  child: pw.Text('No results available yet.',
                      style: const pw.TextStyle(color: PdfColors.grey700)),
                ),
              )
            else
              ...academicYears.map((ay) {
                final String year =
                    _sanitizePlain((ay['year'] ?? '').toString());
                final String programme =
                    _sanitizePlain((ay['programme'] ?? '').toString());
                final String? status = ay['status'] == null
                    ? null
                    : _sanitizePlain(ay['status'].toString());
                final List<Map<String, dynamic>> courses =
                    (ay['courses'] as List?)
                            ?.map((e) => Map<String, dynamic>.from(e))
                            .toList() ??
                        [];

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('$year - $programme', style: sectionTitleStyle),
                    if (status != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2),
                        child: pw.Text(_sanitizePlain('Status: $status'),
                            style: const pw.TextStyle(
                                color: PdfColors.red800, fontSize: 10)),
                      ),
                    pw.SizedBox(height: 6),
                    pw.Table(
                      border: pw.TableBorder.all(
                          color: PdfColors.grey400, width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2),
                        1: const pw.FlexColumnWidth(6),
                        2: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.grey300),
                          children: [
                            _cell('CODE', bold: true),
                            _cell('COURSE', bold: true),
                            _cell('GRADE', bold: true),
                          ],
                        ),
                        ...courses.map((c) => pw.TableRow(children: [
                              _cell(
                                  _sanitizePlain((c['code'] ?? '').toString())),
                              _cell(
                                  _sanitizePlain((c['name'] ?? '').toString())),
                              _cell(_sanitizePlain(
                                  (c['grade'] ?? '***').toString())),
                            ])),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                  ],
                );
              }),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'UNZA_Results_${user['username'] ?? 'student'}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    }
  }

  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Text(
        _sanitizePlain(text),
        style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  String _formatNow() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _sanitizePlain(String input) {
    // Remove emoji and special pictographic symbols often unsupported in PDFs or undesired in official docs
    final regex = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{1F900}-\u{1F9FF}\u{1F600}-\u{1F64F}\u{2600}-\u{27BF}\uFE0F]',
      unicode: true,
    );
    return input.replaceAll(regex, '');
  }

  List<Widget> _buildAcademicYearsFromData(List<dynamic> academicYears) {
    return academicYears.map((ay) {
      final String year = (ay['year'] ?? '').toString();
      final String programme = (ay['programme'] ?? '').toString();
      final String? status =
          ay['status'] == null ? null : ay['status'].toString();
      final List<Map<String, dynamic>> courses = (ay['courses'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];
      return _buildAcademicYearResult(
        academicYear: year,
        programme: programme,
        courses: courses
            .map((c) => {
                  'code': (c['code'] ?? '').toString(),
                  'name': (c['name'] ?? '').toString(),
                  'grade': (c['grade'] ?? '***').toString(),
                })
            .toList(),
        status: status,
      );
    }).toList();
  }

  Widget _buildStudentInfoHeader(Map<String, dynamic> user) {
    final name = (user['studentName'] ?? '').toString();
    final number = (user['username'] ?? '').toString();
    final gender = (user['sex'] ?? '').toString();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Computer number: $number',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Names: $name',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Gender: $gender',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildContinuousAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Continuous Assessment Results [Current Academic Year]',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'No continuous assessment results available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExaminationResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Examination Results & GPA Computation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Note: GPA per Academic Year is computed by ((Course Credits * grade points)/sum of credits)',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.blue[700], size: 16),
                onPressed: () {},
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicYearResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Academic Year Results Table Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'ACADEMIC YEAR PROGRAMME',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'YEAR OF STUDY COURSE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'GRADE COMMENT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Academic Year Results Data
        _buildAcademicYearResult(
          academicYear: 'GER 20241',
          programme:
              'BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 4TH YEAR',
          courses: [
            {
              'code': 'CSC 4642',
              'name': 'SOFTWARE AND QUALITY ASSURANCE',
              'grade': 'NOT PUBLISHED'
            },
            {
              'code': 'CSC 4035',
              'name': 'WEB PROGRAMMING AND TECHNOLOGIES',
              'grade': '***'
            },
            {
              'code': 'CSC 4631',
              'name': 'SOFTWARE TESTING AND MAINTENANCE',
              'grade': '***'
            },
            {
              'code': 'CSC 4630',
              'name': 'ADVANCED SOFTWARE ENGEERING',
              'grade': '***'
            },
            {
              'code': 'CSC 4505',
              'name': 'GRAPHICS AND VISUAL COMPUTING',
              'grade': '***'
            },
            {'code': 'CSC 4004', 'name': 'PROJECTS', 'grade': '***'},
            {
              'code': 'CSC 3009',
              'name': 'INDUSTRIAL TRAINING COURSE',
              'grade': '***'
            },
          ],
        ),

        _buildAcademicYearResult(
          academicYear: 'GER 20231',
          programme:
              'BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 3RD YEAR',
          courses: [
            {'code': 'CSC 3600', 'name': 'SOFTWARE ENGINEERING', 'grade': 'C+'},
            {
              'code': 'CSC 3301',
              'name': 'PROGRAMMING LANGUAGES DESIGN & IMPLEMENTAT',
              'grade': 'C'
            },
            {
              'code': 'CSC 3801',
              'name': 'DATA COMMUNICATION & NETWORKS',
              'grade': 'B'
            },
            {
              'code': 'CSC 3612',
              'name': 'IT PROJECT MANAGEMENT',
              'grade': 'C+'
            },
            {'code': 'CSC 3712', 'name': 'ADVANCED DATABASES', 'grade': 'C+'},
            {
              'code': 'CSC 3011',
              'name': 'ALGORITHM AND COMPLEXITY',
              'grade': 'C+'
            },
            {
              'code': 'CSC 3402',
              'name': 'FUNDAMENTALS OF ARTIFICIAL INTELLIGENCE',
              'grade': 'C+'
            },
            {
              'code': 'CSC 3009',
              'name': 'INDUSTRIAL TRAINING COURSE',
              'grade': 'IN'
            },
          ],
          status: 'PROCEED',
        ),

        _buildAcademicYearResult(
          academicYear: 'GER 20221',
          programme:
              'BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 2ND YEAR',
          courses: [
            {'code': 'CSC 2901', 'name': 'DISCRETE STRUCTURES', 'grade': 'B'},
            {'code': 'CSC 2101', 'name': 'COMPUTER SYSTEMS', 'grade': 'B'},
            {'code': 'CSC 2111', 'name': 'COMPUTER ARCHITECTURE', 'grade': 'B'},
            {
              'code': 'CSC 2702',
              'name': 'DATABASE & INFORMATION MANAGEMENT SYSTEM',
              'grade': 'B'
            },
            {'code': 'CSC 2202', 'name': 'OPERATING SYSTEMS', 'grade': 'B'},
            {'code': 'CSC 2000', 'name': 'COMPUTER PROGRAMMING', 'grade': 'C+'},
            {'code': 'CSC 2912', 'name': 'NUMERICAL ANALYSIS', 'grade': 'C+'},
          ],
          status: 'CLEAR PASS',
        ),

        _buildAcademicYearResult(
          academicYear: 'GER 20211',
          programme:
              'BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 1ST YEAR',
          courses: [
            {'code': 'PHY 1010', 'name': 'INTRODUCTORY PHYSICS', 'grade': 'C+'},
            {
              'code': 'CHE 1000',
              'name': 'INTRODUCTORY CHEMISTRY',
              'grade': 'C+'
            },
            {
              'code': 'BIO 1401',
              'name': 'CELLS AND BIOMOLECULES',
              'grade': 'B'
            },
            {
              'code': 'BIO 1412',
              'name': 'MOLECULAR BIOLOGY AND GENETICS',
              'grade': 'B+'
            },
            {
              'code': 'MAT 1100',
              'name': 'FOUNDATION MATHEMATICS',
              'grade': 'C'
            },
          ],
          status: 'CLEAR PASS',
        ),
      ],
    );
  }

  Widget _buildAcademicYearResult({
    required String academicYear,
    required String programme,
    required List<Map<String, String>> courses,
    String? status,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Academic Year Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$academicYear $programme',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (status != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Courses List
          ...courses
              .map((course) => Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${course['code']} - ${course['name']}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            course['grade']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getGradeColor(course['grade']!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
      case 'A+':
        return Colors.green[800]!;
      case 'B':
      case 'B+':
        return Colors.blue[800]!;
      case 'C':
      case 'C+':
        return Colors.orange[800]!;
      case 'D':
      case 'D+':
        return Colors.red[600]!;
      case 'F':
        return Colors.red[800]!;
      case 'IN':
        return Colors.purple[800]!;
      case 'NOT PUBLISHED':
        return Colors.grey[600]!;
      case '***':
        return Colors.grey[500]!;
      default:
        return Colors.black;
    }
  }
}
