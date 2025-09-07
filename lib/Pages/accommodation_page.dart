import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  State<AccommodationPage> createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getAccommodation();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load accommodation';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Accommodation Information"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          if (!_loading && _data?['allocation'] != null) ...[
            IconButton(
              onPressed: _emailHousing,
              icon: const Icon(Icons.email_outlined),
              tooltip: 'Email registrar@unza.zm',
            ),
            IconButton(
              onPressed: _callSwitchboard,
              icon: const Icon(Icons.phone),
              tooltip: 'Call +260211 291 777',
            ),
          ]
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final allocation = _data?['allocation'];
    final roomKey = _data?['roomKey'];
    final fixedProps = (_data?['fixedProperty'] as List?) ?? const [];
    final optionalProps = (_data?['optionalProperty'] as List?) ?? const [];
    final isNarrow = MediaQuery.of(context).size.width < 380;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Student Accommodation Information"),
          const SizedBox(height: 8),
          Text(
            "Message: Hostel information is below. If you do not see any information, that means you have not been allocated any bed space.",
            style: TextStyle(
                color: Colors.orange[700], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Allocation table
          _buildSectionTitle("Allocation"),
          if (allocation == null)
            _buildTextContent("No accommodation allocated yet.")
          else if (isNarrow)
            _buildKeyValueCard({
              'Hostel': '${allocation['hostel'] ?? ''}',
              'Block': '${allocation['block'] ?? ''}',
              'Level': '${allocation['level'] ?? ''}',
              'Room Type': '${allocation['roomType'] ?? ''}',
              'Room Number': '${allocation['roomNumber'] ?? ''}',
              'Remark': '${allocation['remark'] ?? ''}',
            })
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Hostel')),
                  DataColumn(label: Text('Block')),
                  DataColumn(label: Text('Level')),
                  DataColumn(label: Text('Room Type')),
                  DataColumn(label: Text('Room Number')),
                  DataColumn(label: Text('Remark')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text('${allocation['hostel'] ?? ''}')),
                    DataCell(Text('${allocation['block'] ?? ''}')),
                    DataCell(Text('${allocation['level'] ?? ''}')),
                    DataCell(Text('${allocation['roomType'] ?? ''}')),
                    DataCell(Text('${allocation['roomNumber'] ?? ''}')),
                    DataCell(Text('${allocation['remark'] ?? ''}')),
                  ])
                ],
              ),
            ),

          if (allocation != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle("Need Help?"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _emailHousing,
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email registrar@unza.zm'),
                ),
                ElevatedButton.icon(
                  onPressed: _callSwitchboard,
                  icon: const Icon(Icons.phone),
                  label: const Text('Call +260211 291 777'),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
          _buildSectionTitle("Room Property assigned to you:"),
          if (roomKey == null)
            _buildTextContent("No key assigned.")
          else if (isNarrow)
            _buildKeyValueCard({
              'Key': '${roomKey['key'] ?? ''}',
              'Key Number': '${roomKey['number'] ?? ''}',
            })
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Key')),
                  DataColumn(label: Text('Key Number')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text('${roomKey['key'] ?? ''}')),
                    DataCell(Text('${roomKey['number'] ?? ''}')),
                  ])
                ],
              ),
            ),

          const SizedBox(height: 20),
          _buildSectionTitle("Fixed Room Property"),
          if (fixedProps.isEmpty)
            _buildTextContent("None")
          else
            ...fixedProps.map((e) => _buildTextContent('- ${e.toString()}')),

          const SizedBox(height: 20),
          _buildSectionTitle("Optional Property"),
          if (optionalProps.isEmpty)
            _buildTextContent("No optional properties assigned.")
          else
            ...optionalProps.map((e) => _buildTextContent('- ${e.toString()}')),
        ],
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
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Old table helpers removed as DataTable is used now

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

  Widget _buildKeyValueCard(Map<String, String> pairs) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pairs.entries
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          '${e.key}:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: Text(e.value)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Future<void> _emailHousing() async {
    final params = {
      'subject': 'Accommodation assistance',
      'body':
          'Hello Housing Office,\n\nI need assistance with my accommodation allocation.\n\nRegards,'
    };
    final uri = Uri(
      scheme: 'mailto',
      path: 'registrar@unza.zm',
      query: _encodeQuery(params),
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callSwitchboard() async {
    // Using primary switchboard number
    final uri = Uri(scheme: 'tel', path: '+260211291777');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _encodeQuery(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
