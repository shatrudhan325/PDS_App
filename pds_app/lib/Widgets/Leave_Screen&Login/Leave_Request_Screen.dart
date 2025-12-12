import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pds_app/core/Services/token_store.dart';
import 'package:pds_app/core/apiConfig/config.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? _leaveType;
  final _periodController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSubmitting = false;
  bool _submitted = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _animController.forward();
  }

  @override
  void dispose() {
    _periodController.dispose();
    _noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickPeriod() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDateRange: DateTimeRange(
        start: now,
        end: now.add(const Duration(days: 1)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3677F6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final int diff = picked.end.difference(picked.start).inDays;
      if (diff != 1 & 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You Can Select Maximum Two Day.")),
        );
        return;
      }

      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;

        _periodController.text =
            "${picked.start.toString().substring(0, 10)} → ${picked.end.toString().substring(0, 10)}";
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a leave period.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      "startDate": _startDate!.toIso8601String(),
      "leaveRequestType": _leaveType,
      "endDate": _endDate!.toIso8601String(),
      "reason": _noteController.text.trim(),
    };

    print("Leave payload: $payload");

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/leave/create_leave');
      final String? authToken = await TokenStorage.getToken();

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(payload),
      );
      print('Token: ${authToken}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() => _submitted = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              content: Text("Leave submitted successfully"),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              content: Text("Submission failed (${res.statusCode})"),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error connecting to server"),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Create Leave"),
        titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
        backgroundColor: const Color(0xFF3677F6),
        centerTitle: true,
        elevation: 1,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSectionCard(),
              const SizedBox(height: 20),
              _buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  // card UI
  Widget _buildSectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 232, 232, 233),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.assignment, color: Color(0xFF3677F6), size: 22),
                SizedBox(width: 8),
                Text(
                  "Leave Request Form",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Leave Type
            _label("Leave Type"),
            DropdownButtonFormField<String>(
              value: _leaveType,
              decoration: _inputDecoration(),
              items: const [
                DropdownMenuItem(
                  value: "CASUAL_LEAVE",
                  child: Text("Casual Leave"),
                ),
                DropdownMenuItem(
                  value: "SICK_LEAVE",
                  child: Text("Sick Leave"),
                ),
              ],
              onChanged: (v) => setState(() => _leaveType = v),
              validator: (v) => v == null ? "Please select a leave type" : null,
            ),

            const SizedBox(height: 18),

            // Period
            _label("Period"),
            TextFormField(
              controller: _periodController,
              readOnly: true,
              onTap: _pickPeriod,
              decoration: _inputDecoration().copyWith(
                suffixIcon: const Icon(Icons.calendar_today_rounded),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? "Please select period" : null,
            ),

            const SizedBox(height: 18),

            // Note
            _label("Note / Reason"),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: _inputDecoration(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Please enter reason";
                }

                if (v.trim().length > 250) {
                  return "Please enter at least 250 characters (${250 - v.trim().length} more needed)";
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // submit button
  Widget _buildButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          backgroundColor: _submitted ? Colors.white : const Color(0xFF3677F6),
        ),
        onPressed: (_isSubmitting || _submitted) ? null : _submit,
        child: Text(
          _submitted
              ? "✔ Submitted"
              : _isSubmitting
              ? "Submitting..."
              : "Submit",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // Reusable label
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }

  // Reusable field style
  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
