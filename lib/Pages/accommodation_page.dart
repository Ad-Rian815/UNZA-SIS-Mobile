import 'package:flutter/material.dart';

class AccommodationPage extends StatelessWidget {
  const AccommodationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Accommodation Information"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Student Accommodation Information"),
            const SizedBox(height: 8),
            Text(
              "Message: Hostel information is below. If you do not see any information, that means you have not been allocated any bed space.",
              style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTableHeader(["Hostel", "Block", "Level", "Room Type", "Room Number", "Remark"]),
            _buildTableRow([" ", " ", " ", " ", " ", " "]),
            const SizedBox(height: 20),
            _buildSectionTitle("Room Property assigned to you:"),
            _buildTableHeader(["Key", "Key Number"]),
            _buildTableRow([" ", " "]),
            const SizedBox(height: 20),
            _buildSectionTitle("Fixed Room Property"),
            _buildTextContent("None"),
            const SizedBox(height: 20),
            _buildSectionTitle("Optional Property"),
            _buildTextContent("No optional properties assigned."),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.green[700],
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTableHeader(List<String> headers) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: headers.map((header) => Expanded(child: Text(header, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }

  Widget _buildTableRow(List<String> values) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: values.map((value) => Expanded(child: Text(value))).toList(),
      ),
    );
  }

  Widget _buildTextContent(String content) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(content, style: const TextStyle(fontSize: 16)),
    );
  }
}
