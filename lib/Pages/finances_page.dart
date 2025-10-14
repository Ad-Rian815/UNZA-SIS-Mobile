import 'package:flutter/material.dart';
import 'package:unza_sis_mobile/Pages/payment_history_page.dart';
import 'package:unza_sis_mobile/Pages/api_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class FinancesPage extends StatelessWidget {
  const FinancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Finance'),
        actions: [
          IconButton(
            tooltip: 'Export Statement',
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _exportStatement();
            },
          ),
        ],
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getFinances(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load finances'));
          }
          final data =
              snapshot.data ?? {'summary': {}, 'fees': [], 'payments': []};
          final summary = data['summary'] as Map<String, dynamic>? ?? {};
          final fees = (data['fees'] as List?) ?? [];
          final payments = (data['payments'] as List?) ?? [];
          final outstanding = (summary['outstanding'] ?? 0) as num;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Information Header
                _buildStudentInfoHeader(),
                SizedBox(height: 16),

                // Registration Notice
                _buildRegistrationNotice(),
                SizedBox(height: 16),

                // Balance Section
                _buildBalanceSection(outstanding),
                SizedBox(height: 16),

                // Financial Summary Cards
                _buildFinancialSummaryCards(summary, fees, payments),
                SizedBox(height: 16),

                // Detailed Fee Breakdown
                _buildDetailedFeeBreakdown(fees, payments),
                SizedBox(height: 16),

                // Payment History Button
                _buildPaymentHistoryButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentInfoHeader() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getUserData(),
      builder: (context, userSnap) {
        final user = userSnap.data ?? const {};
        final name = (user['studentName'] ?? '').toString();
        final number = (user['username'] ?? '').toString();
        final year = (user['yearOfStudy'] ?? '').toString();
        final sponsor = (user['sponsor'] ?? '').toString();

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Student Number: ${number.isEmpty ? 'N/A' : number}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    name.isEmpty ? 'N/A' : name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Year of Study: ${year.isEmpty ? 'N/A' : year}'),
                  _buildSponsorBadge(sponsor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSponsorBadge(String sponsor) {
    final isFullySponsored = sponsor.toUpperCase().contains('GRZ') ||
        sponsor.toUpperCase().contains('FULLY');
    final isSelfSponsored = sponsor.toUpperCase().contains('SELF');

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (isFullySponsored) {
      badgeColor = Colors.blue;
      badgeText = 'FULLY SPONSORED';
      badgeIcon = Icons.verified;
    } else if (isSelfSponsored) {
      badgeColor = Colors.orange;
      badgeText = 'SELF SPONSORED';
      badgeIcon = Icons.person;
    } else {
      badgeColor = Colors.grey;
      badgeText = sponsor.isEmpty ? 'UNKNOWN' : sponsor;
      badgeIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationNotice() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[800]),
          SizedBox(height: 4),
          Text(
            'Registration Requirements',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'To register, you must clear all outstanding balances and pay required fees.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.amber[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(num outstanding) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: outstanding > 0 ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: outstanding > 0 ? Colors.red[200]! : Colors.green[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Outstanding Balance (All Academic Years):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'ZMW ${outstanding.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: outstanding > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Minimum Payment to Register:'),
              Text(
                'ZMW 0.00',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCards(
      Map<String, dynamic> summary, List fees, List payments) {
    final totalDue = (summary['totalDue'] ?? 0) as num;
    final totalPaid = (summary['totalPaid'] ?? 0) as num;
    final outstanding = (summary['outstanding'] ?? 0) as num;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Due',
            'ZMW ${totalDue.toStringAsFixed(2)}',
            Colors.blue,
            Icons.account_balance_wallet,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Total Paid',
            'ZMW ${totalPaid.toStringAsFixed(2)}',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Outstanding',
            'ZMW ${outstanding.toStringAsFixed(2)}',
            outstanding > 0 ? Colors.red : Colors.green,
            outstanding > 0 ? Icons.warning : Icons.check,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFeeBreakdown(List fees, List payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Fee Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Text(
                    'Fee Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Currency',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Paid',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: [
                // Balance Brought Forward
                DataRow(
                  cells: [
                    DataCell(Text('Balance B/Fwd')),
                    DataCell(Text('ZMW')),
                    DataCell(Text('-7,037.00')),
                    DataCell(Text('0.00')),
                  ],
                ),
                // Individual fees
                ...fees.map((f) {
                  final desc = f['description']?.toString() ?? '';
                  final amount = (f['amount'] ?? 0).toString();
                  return DataRow(
                    cells: [
                      DataCell(Text(desc)),
                      DataCell(Text('ZMW')),
                      DataCell(Text(amount)),
                      DataCell(Text('0.00')),
                    ],
                  );
                }),
                // Totals row
                DataRow(
                  cells: [
                    DataCell(Text('Totals',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('ZMW')),
                    DataCell(Text('-7,037.00',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('0.00',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                // Balance row
                DataRow(
                  cells: [
                    DataCell(Text('Balance',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('ZMW')),
                    DataCell(Text('-7,037.00',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('0.00',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
          );
        },
        icon: Icon(Icons.history),
        label: Text("Payment History"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

Future<void> _exportStatement() async {
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('Student Finance Statement',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Outstanding Balance (All Academic Years): -7,037.00'),
        pw.SizedBox(height: 16),
        pw.Table.fromTextArray(
          headers: ['Description', 'Amount Due', 'Paid', 'Balance'],
          data: [
            ['Tuition Fee', '10,000.00', '5,000.00', '5,000.00'],
            ['Other Fees', '2,000.00', '1,000.00', '1,000.00'],
            ['Previous Balance', '3,000.00', '2,000.00', '1,000.00'],
          ],
        ),
      ],
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => doc.save());
}
