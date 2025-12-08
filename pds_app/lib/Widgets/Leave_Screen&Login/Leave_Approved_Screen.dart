import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Leave {
  final int id;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status;

  Leave({
    required this.id,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] as int,
      fromDate: json['fromDate'] as String,
      toDate: json['toDate'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
    );
  }
}

Future<List<Leave>> fetchLeaves(int userId) async {
  final url = Uri.parse('https://your-backend.com/api/leaves?userId=$userId');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((e) => Leave.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load leaves: ${response.statusCode}');
  }
}

class MyLeavesScreen extends StatefulWidget {
  final int userId;

  const MyLeavesScreen({super.key, required this.userId});

  @override
  State<MyLeavesScreen> createState() => _MyLeavesScreenState();
}

class _MyLeavesScreenState extends State<MyLeavesScreen> {
  late Future<List<Leave>> _futureLeaves;

  @override
  void initState() {
    super.initState();
    _futureLeaves = fetchLeaves(widget.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureLeaves = fetchLeaves(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Leaves')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Leave>>(
          future: _futureLeaves,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final leaves = snapshot.data ?? [];

            if (leaves.isEmpty) {
              return const Center(child: Text('No leaves found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                return _leaveCard(leaves[index]);
              },
            );
          },
        ),
      ),
    );
  }

  //LEAVE CARD UI
  Widget _leaveCard(Leave leave) {
    final (statusText, statusColor) = _statusStyle(leave.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // row: dates + chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${leave.fromDate} → ${leave.toDate}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: statusColor.withOpacity(0.12),
                  side: BorderSide(color: statusColor.withOpacity(0.4)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(leave.reason, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            if (leave.status.toUpperCase() == 'APPROVED')
              const Text(
                'Your leave has been approved',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }

  //STATUS STYLE
  (String, Color) _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return ('Approved', Colors.green);
      case 'REJECTED':
        return ('Rejected', Colors.red);
      default:
        return ('Pending', Colors.orange);
    }
  }
}
