import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pds_app/core/Services/token_store.dart';
import 'package:pds_app/core/apiConfig/config.dart';

class Leave {
  final DateTime fromDate;
  final DateTime toDate;
  final String leaveType;
  final String reason;
  final String status;
  final bool approved;
  final String? approvedBy;
  final DateTime? approvedOn;

  Leave({
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.reason,
    required this.status,
    required this.approved,
    this.approvedBy,
    this.approvedOn,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    final String? rawStatus = (json['leaveStatus'] as String?)?.trim();
    final bool approved = (json['approved'] as bool?) ?? false;

    // Determine status
    final String status;
    if (rawStatus != null && rawStatus.isNotEmpty) {
      status = rawStatus.toUpperCase();
    } else if (approved) {
      status = 'APPROVED';
    } else {
      status = 'PENDING';
    }

    DateTime parseDateSafe(String? s) {
      if (s == null) return DateTime.now();
      final dt = DateTime.tryParse(s);
      return dt ?? DateTime.now();
    }

    DateTime? parseNullableDate(String? s) {
      if (s == null) return null;
      return DateTime.tryParse(s);
    }

    return Leave(
      fromDate: parseDateSafe(json['startDate'] as String?),
      toDate: parseDateSafe(json['endDate'] as String?),
      leaveType: (json['leaveRequestType'] as String?) ?? 'UNKNOWN',
      reason: (json['reason'] as String?) ?? '',
      status: status,
      approved: approved,
      approvedBy: json['approvedBy'] as String?,
      approvedOn: parseNullableDate(json['approvedOn'] as String?),
    );
  }
}

/// Fetch leaves for the currently authenticated user (uses token).
Future<List<Leave>> fetchLeaves() async {
  final url = Uri.parse('${ApiConfig.baseUrl}/leave/get_leaves');
  final String? authToken = await TokenStorage.getToken();

  final response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load leaves: ${response.statusCode}');
  }

  final body = response.body.trim();
  if (body.isEmpty) return [];

  final decoded = jsonDecode(body);

  List<dynamic> list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map<String, dynamic>) {
    if (decoded['data'] is List) {
      list = decoded['data'] as List<dynamic>;
    } else {
      // maybe the backend returns an object representing a single leave
      list = [decoded];
    }
  } else {
    throw Exception('Unexpected response format');
  }

  return list.map<Leave>((e) {
    if (e is Map<String, dynamic>) {
      return Leave.fromJson(e);
    } else {
      throw Exception('Unexpected element type in response');
    }
  }).toList();
}

class MyLeavesScreen extends StatefulWidget {
  const MyLeavesScreen({super.key});

  @override
  State<MyLeavesScreen> createState() => _MyLeavesScreenState();
}

class _MyLeavesScreenState extends State<MyLeavesScreen> {
  late Future<List<Leave>> _futureLeaves;
  final DateFormat _displayDate = DateFormat('yMMMd'); // e.g. Dec 13, 2025

  @override
  void initState() {
    super.initState();
    _futureLeaves = fetchLeaves();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureLeaves = fetchLeaves();
    });
  }

  /// Returns a map with text and color for UI
  Map<String, dynamic> _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'APPROVE':
        return {'text': 'Approved', 'color': Colors.green};
      case 'REJECTED':
      case 'DENIED':
        return {'text': 'Rejected', 'color': Colors.red};
      default:
        return {'text': 'Pending', 'color': Colors.orange};
    }
  }

  String _friendlyLeaveType(String raw) {
    switch (raw.toUpperCase()) {
      case 'CASUAL_LEAVE':
        return 'Casual';
      case 'SICK_LEAVE':
        return 'Sick';
      case 'EARNED_LEAVE':
      case 'EARNED':
        return 'Earned';
      default:
        return raw;
    }
  }

  Widget _leaveCard(Leave leave) {
    final status = _statusStyle(leave.status);
    final String statusText = status['text'] as String;
    final Color statusColor = status['color'] as Color;

    final dateRange =
        '${_displayDate.format(leave.fromDate)} → ${_displayDate.format(leave.toDate)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateRange,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
            Text(
              '${_friendlyLeaveType(leave.leaveType)} · ${leave.reason}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            if (leave.status.toUpperCase() == 'APPROVED')
              Text(
                'Approved${leave.approvedBy != null ? " by ${leave.approvedBy}" : ""}'
                '${leave.approvedOn != null ? " on ${_displayDate.format(leave.approvedOn!)}" : ""}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (leave.status.toUpperCase() == 'REJECTED')
              const Text(
                'Your leave was rejected',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("My Leaves"),
        titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
        backgroundColor: const Color(0xFF3677F6),
      ),
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
}
