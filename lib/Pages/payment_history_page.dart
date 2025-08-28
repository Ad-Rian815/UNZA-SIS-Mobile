import 'package:flutter/material.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Payment History for - ADRIAN PHIRI 2021397963',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            DataTable(
              columnSpacing: 20,
              columns: [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Academic Year')),
                DataColumn(label: Text('Payment Details')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('1095/1272')),
                  DataCell(Text('GER 20231')),
                  DataCell(Text('No payments received!')),
                ]),
                DataRow(cells: [
                  DataCell(Text('1094/1272')),
                  DataCell(Text('GER 20221')),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TranID: OBMDtUnAV8YQFrVd'),
                      Text('TranID: FJB2308967967114'),
                    ],
                  )),
                ]),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Fee Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            DataTable(
              columns: [
                DataColumn(label: Text('Fee Type')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Paid')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Examination')),
                  DataCell(Text('350.00')),
                  DataCell(Text('350.00')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Medical')),
                  DataCell(Text('200.00')),
                  DataCell(Text('200.00')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Internet')),
                  DataCell(Text('194.00')),
                  DataCell(Text('194.00')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Tuition')),
                  DataCell(Text('0.00')),
                  DataCell(Text('0.00')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Total')),
                  DataCell(Text('2,334.00')),
                  DataCell(Text('9,371.00')),
                ]),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Balance: -7,037.00',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
