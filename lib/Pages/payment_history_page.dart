import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:unza_sis_mobile/Pages/api_service.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            tooltip: 'Export / Print',
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _printPaymentHistory();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getFinances(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Failed to load payments'));
          }
          final data = snap.data ?? {'summary': {}, 'payments': [], 'fees': []};
          final payments = (data['payments'] as List?) ?? [];
          final fees = (data['fees'] as List?) ?? [];
          final totalFees = fees.fold<num>(
              0, (s, f) => s + (num.tryParse('${f['amount']}') ?? 0));
          final totalPayments = payments.fold<num>(
              0, (s, p) => s + (num.tryParse('${p['amount']}') ?? 0));
          final outstanding = totalFees - totalPayments;
          final isNarrow = MediaQuery.of(context).size.width < 600;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Information Header
                _buildStudentInfoHeader(),
                SizedBox(height: 16),

                // Current Balance Summary
                _buildCurrentBalanceSummary(
                    outstanding, totalFees, totalPayments),
                SizedBox(height: 16),

                // Cumulative Balance by Academic Year
                _buildCumulativeBalanceSection(payments, fees),
                SizedBox(height: 16),

                // Payment History Section
                _buildPaymentHistorySection(payments, isNarrow),
                SizedBox(height: 16),

                // Fee Breakdown Section
                _buildFeeBreakdownSection(fees),
                SizedBox(height: 16),
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
      builder: (context, snapshot) {
        final user = snapshot.data ?? const {};
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
                    'Payment History for - ${name.isEmpty ? 'Student' : name}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  _buildSponsorBadge(sponsor),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Student Number: ${number.isEmpty ? 'N/A' : number}'),
                  Text('Year of Study: ${year.isEmpty ? 'N/A' : year}'),
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

  Widget _buildCurrentBalanceSummary(
      num outstanding, num totalFees, num totalPayments) {
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
            'Current Financial Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Fees',
                  'ZMW ${totalFees.toStringAsFixed(2)}',
                  Colors.blue,
                  Icons.account_balance_wallet,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'Total Paid',
                  'ZMW ${totalPayments.toStringAsFixed(2)}',
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
          ),
        ],
      ),
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

  Widget _buildCumulativeBalanceSection(List payments, List fees) {
    // Group payments by academic year
    final Map<String, List<Map<String, dynamic>>> paymentsByYear = {};
    for (final payment in payments) {
      final year = (payment['year'] ?? 'Unknown').toString();
      paymentsByYear.putIfAbsent(year, () => []).add(payment);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cumulative Balance by Academic Year',
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
          child: Column(
            children: [
              // Header row
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text('Academic Year',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Fees',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Payments',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Balance',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // Data rows
              ...paymentsByYear.entries.map((entry) {
                final year = entry.key;
                final yearPayments = entry.value;
                final yearTotal = yearPayments.fold<num>(
                    0, (sum, p) => sum + (num.tryParse('${p['amount']}') ?? 0));
                final yearFees = fees
                    .where((f) => (f['year'] ?? '').toString() == year)
                    .fold<num>(
                        0,
                        (sum, f) =>
                            sum + (num.tryParse('${f['amount']}') ?? 0));
                final yearBalance = yearFees - yearTotal;

                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(year)),
                      Expanded(
                          child: Text('ZMW ${yearFees.toStringAsFixed(2)}')),
                      Expanded(
                          child: Text('ZMW ${yearTotal.toStringAsFixed(2)}')),
                      Expanded(
                        child: Text(
                          'ZMW ${yearBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: yearBalance > 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistorySection(List payments, bool isNarrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 8),
        if (payments.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No payments received.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          )
        else if (isNarrow)
          Column(
            children: payments.map((p) => _buildPaymentCard(p)).toList(),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                dataRowMinHeight: 48,
                columns: [
                  DataColumn(
                      label: Text('Date',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Term/Year',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Amount',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Method',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Reference',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Description',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: payments.map((p) {
                  final dateStr = _formatDate(p['date']);
                  final term = (p['term'] ?? '').toString();
                  final year = (p['year'] ?? '').toString();
                  final amt = (p['amount'] ?? '').toString();
                  return DataRow(cells: [
                    DataCell(Text(dateStr)),
                    DataCell(Text('$term $year'.trim())),
                    DataCell(Text('ZMW $amt')),
                    DataCell(Text((p['method'] ?? '').toString())),
                    DataCell(Text((p['reference'] ?? '').toString())),
                    DataCell(ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                      child: Text((p['description'] ?? '').toString()),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeeBreakdownSection(List fees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fee Breakdown',
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
                    label: Text('Fee Description',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Currency',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Amount',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Paid',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Outstanding',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                // Balance Brought Forward
                DataRow(
                  cells: [
                    DataCell(Text('Balance B/Fwd')),
                    DataCell(Text('ZMW')),
                    DataCell(Text('-7,037.00')),
                    DataCell(Text('0.00')),
                    DataCell(Text('-7,037.00',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold))),
                  ],
                ),
                // Individual fees
                ...fees.map((f) {
                  final desc = f['description']?.toString() ?? '';
                  final amount = (f['amount'] ?? 0).toString();
                  final paid = '0.00'; // This would come from actual data
                  final outstanding = (double.tryParse(amount) ?? 0) -
                      (double.tryParse(paid) ?? 0);
                  return DataRow(
                    cells: [
                      DataCell(Text(desc)),
                      DataCell(Text('ZMW')),
                      DataCell(Text(amount)),
                      DataCell(Text(paid)),
                      DataCell(Text(
                        outstanding.toStringAsFixed(2),
                        style: TextStyle(
                          color: outstanding > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
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
                    DataCell(Text('-7,037.00',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> p) {
    final dateStr = _formatDate(p['date']);
    final term = (p['term'] ?? '').toString();
    final year = (p['year'] ?? '').toString();
    final amt = (p['amount'] ?? '').toString();
    final method = (p['method'] ?? '').toString();
    final ref = (p['reference'] ?? '').toString();
    final desc = (p['description'] ?? '').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$dateStr  •  $term $year',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Amount: ZMW $amt'),
          if (method.isNotEmpty) Text('Method: $method'),
          if (ref.isNotEmpty) Text('Reference: $ref'),
          if (desc.isNotEmpty) Text(desc),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    try {
      final d =
          value is String ? DateTime.tryParse(value) : (value as DateTime?);
      if (d == null) return '';
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _printPaymentHistory() async {
    final doc = pw.Document();
    final user = await ApiService.getUserData();
    final finances = await ApiService.getFinances();
    final name = (user['studentName'] ?? '').toString();
    final number = (user['username'] ?? '').toString();
    final payments = (finances['payments'] as List?) ?? [];
    final fees = (finances['fees'] as List?) ?? [];
    final totalFees =
        fees.fold<num>(0, (s, f) => s + (num.tryParse('${f['amount']}') ?? 0));
    final totalPayments = payments.fold<num>(
        0, (s, p) => s + (num.tryParse('${p['amount']}') ?? 0));
    final outstanding = totalFees - totalPayments;

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Payment History',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Student: '
              '${name.isEmpty ? 'Student' : name} '
              '${number.isEmpty ? '' : number}'),
          pw.SizedBox(height: 16),

          // Current Balance Summary
          pw.Text('Current Financial Summary',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text('Total Fees: ZMW ${totalFees.toStringAsFixed(2)}'),
          pw.Text('Total Payments: ZMW ${totalPayments.toStringAsFixed(2)}'),
          pw.Text('Outstanding Balance: ZMW ${outstanding.toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),

          // Payment Transactions
          pw.Text('Payment Transactions',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          if (payments.isEmpty)
            pw.Text('No payments received.')
          else
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Term/Year',
                'Amount',
                'Method',
                'Reference',
                'Description'
              ],
              data: payments.map((p) {
                final dateStr = _formatDate(p['date']);
                final term = (p['term'] ?? '').toString();
                final year = (p['year'] ?? '').toString();
                final amt = (p['amount'] ?? '').toString();
                return [
                  dateStr,
                  '$term $year'.trim(),
                  'ZMW $amt',
                  (p['method'] ?? '').toString(),
                  (p['reference'] ?? '').toString(),
                  (p['description'] ?? '').toString()
                ];
              }).toList(),
            ),
          pw.SizedBox(height: 16),

          // Fee Breakdown
          pw.Text('Fee Breakdown',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: [
              'Fee Description',
              'Currency',
              'Amount',
              'Paid',
              'Outstanding'
            ],
            data: [
              ['Balance B/Fwd', 'ZMW', '-7,037.00', '0.00', '-7,037.00'],
              ...fees.map((f) {
                final desc = f['description']?.toString() ?? '';
                final amount = (f['amount'] ?? 0).toString();
                return [desc, 'ZMW', amount, '0.00', amount];
              }).toList(),
              ['Totals', 'ZMW', '-7,037.00', '0.00', '-7,037.00'],
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
