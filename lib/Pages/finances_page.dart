import 'package:flutter/material.dart';
import 'package:unza_sis_mobile/Pages/payment_history_page.dart';

class FinancesPage extends StatelessWidget {
  const FinancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Finance'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              color: Colors.yellow,
              child: Text(
                'Please ensure you register for courses first',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Text(
              'For a student to register, he MUST pay all outstanding balances in full.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            DataTable(
              columns: [
                DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Amount Due', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Paid', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Tuition Fee')),
                  DataCell(Text('10,000.00')),
                  DataCell(Text('5,000.00')),
                  DataCell(Text('5,000.00')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Other Fees')),
                  DataCell(Text('2,000.00')),
                  DataCell(Text('1,000.00')),
                  DataCell(Text('1,000.00')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Previous Balance')),
                  DataCell(Text('3,000.00')),
                  DataCell(Text('2,000.00')),
                  DataCell(Text('1,000.00')),
                ]),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outstanding Balance (All Academic Years):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '-7,037.00',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Student Financial Standing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 10),
            Text('Name: Adrian Phiri'),
            Text('Student Number: 2021397963'),
            Text('Year of Study: 4th Year'),
            Text('Session: GER 20241 - 1129 / 1272'),
            SizedBox(height: 10),
            Text(
              'No payments received!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 20),
            Center(
              child:  ElevatedButton.icon(
              onPressed: () {
                // Directly navigate to the User Profile Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
                );
              },
              icon: Icon(Icons.money),
              label: Text("Payment History"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700], // Button color
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
