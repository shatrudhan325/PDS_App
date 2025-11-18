import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:pds_app/Models/attandence.dart';
import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
import 'package:pds_app/Widgets/Location_Get&Finde_Mock/attandenceLocation.dart';
import 'Attandance_info_card.dart';
import 'log_entry_items.dart';
// import 'AttandencePastRecord.dart';

/// Daily Attendance Tracking Screen
///
/// Complete implementation with:
/// - Check-in and check-out functionality
/// - Real-time elapsed time tracking
/// - Today's attendance log
/// - Location indicator
/// - Two dynamic states (Ready to Start / Work in Progress)
class AttendanceTrackingScreen extends StatefulWidget {
  const AttendanceTrackingScreen({super.key});

  @override
  State<AttendanceTrackingScreen> createState() =>
      _AttendanceTrackingScreenState();
}

class _AttendanceTrackingScreenState extends State<AttendanceTrackingScreen> {
  AttendanceRecord _attendanceRecord = AttendanceRecord();
  bool _isFakeLocation = false;
  String _elapsedTime = '0 hours, 0 minutes';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Start a timer to update elapsed time every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_attendanceRecord.isCheckedIn) {
        setState(() {
          _elapsedTime = _attendanceRecord.getElapsedTime();
        });
      }
    });
  }

  /// Handle check-in action
  void _handleCheckIn() {
    if (_isFakeLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Check-in not allowed — Fake GPS detected!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // 🚫 Stop check-in
    }

    setState(() {
      _attendanceRecord = AttendanceRecord(
        checkInTime: DateTime.now(),
        checkOutTime: null,
        isCheckedIn: true,
      );
      _elapsedTime = _attendanceRecord.getElapsedTime();
    });
  }

  /// Handle check-out action
  void _handleCheckOut() {
    setState(() {
      _attendanceRecord = _attendanceRecord.copyWith(
        checkOutTime: DateTime.now(),
        isCheckedIn: false,
      );
      _elapsedTime = _attendanceRecord.getElapsedTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      /// App Bar with back button, title, and action icons
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF030213)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Daily Attendance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF030213),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF030213),
            ),
            onPressed: () {
              debugPrint('Notifications clicked');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF030213)),
            onPressed: () {
              debugPrint('Settings clicked');
            },
          ),
        ],
      ),

      /// Scrollable content area
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Current Date Card
              AttendanceInfoCard(
                icon: Icons.calendar_today,
                iconColor: const Color(0xFF007BFF),
                backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
                label: 'Today',
                value: AttendanceRecord.getCurrentDate(),
              ),

              const SizedBox(height: 16),

              /// Location Indicator Card
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: LiveLocationWidgets(
                  onLocationCheck: (isFake) {
                    setState(() {
                      _isFakeLocation = isFake;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// Primary Action Section - Dynamic Based on State
              _buildPrimaryActionCard(),

              const SizedBox(height: 24),

              /// Today's Log Section Header
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF717182),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Today's Log",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF030213),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Today's Log History Card
              _buildLogHistoryCard(),

              const SizedBox(height: 24),

              /// Footer - View Past Records Button
              Center(
                child: TextButton(
                  onPressed: () {
                    debugPrint('View Past Records clicked');
                    Get.to(() => const PastRecordsScreen());
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Past Records',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the primary action card with gradient background
  /// Changes color and content based on check-in state
  Widget _buildPrimaryActionCard() {
    final isCheckedIn = _attendanceRecord.isCheckedIn;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCheckedIn
              ? [const Color(0xFFFFC107), const Color(0xFFFF9800)]
              : [const Color(0xFF007BFF), const Color(0xFF0056b3)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Status Header
            Row(
              children: [
                Icon(
                  isCheckedIn ? Icons.check_circle : Icons.access_time,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCheckedIn
                        ? 'Status: Work in Progress'
                        : 'Status: Ready to Start',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Status Description
            Text(
              isCheckedIn
                  ? 'Checked in at ${AttendanceRecord.formatTime(_attendanceRecord.checkInTime)}'
                  : 'Tap to log your attendance.',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),

            const SizedBox(height: 24),

            /// Action Button
            // SizedBox(
            //   width: double.infinity,
            //   height: 56,
            //   child: ElevatedButton(
            //     onPressed: isCheckedIn ? _handleCheckOut : _handleCheckIn,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: isCheckedIn
            //           ? const Color(0xFFDC3545)
            //           : Colors.white,
            //       foregroundColor: isCheckedIn
            //           ? Colors.white
            //           : const Color(0xFF007BFF),
            //       elevation: 4,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     child: Text(
            //       isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
            //       style: const TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isCheckedIn
                    ? () {
                        Get.defaultDialog(
                          title: 'Confirm Check Out',
                          middleText: 'Are you sure you want to CHECK OUT?',
                          barrierDismissible: false,
                          textCancel: 'Cancel',
                          textConfirm: 'Yes, Check Out',
                          onCancel: () {},
                          onConfirm: () {
                            Get.back(); // Close dialog
                            _handleCheckOut(); // Execute checkout
                          },
                          buttonColor: const Color(0xFFDC3545),
                          confirmTextColor: Colors.white,
                        );
                      }
                    : _handleCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCheckedIn
                      ? const Color(0xFFDC3545)
                      : Colors.white,
                  foregroundColor: isCheckedIn
                      ? Colors.white
                      : const Color(0xFF007BFF),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the log history card showing check-in, check-out, and total time
  Widget _buildLogHistoryCard() {
    final hasCheckedIn = _attendanceRecord.checkInTime != null;
    final hasCheckedOut = _attendanceRecord.checkOutTime != null;
    final isOngoing = _attendanceRecord.isCheckedIn;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            /// Check-in Entry
            LogEntryItem(
              icon: hasCheckedIn ? Icons.check_circle : Icons.access_time,
              iconColor: hasCheckedIn
                  ? const Color(0xFF28A745)
                  : const Color(0xFF717182),
              backgroundColor: hasCheckedIn
                  ? const Color(0xFF28A745).withOpacity(0.1)
                  : const Color(0xFFECECF0),
              label: 'Check-in',
              value: AttendanceRecord.formatTime(_attendanceRecord.checkInTime),
              valueColor: hasCheckedIn
                  ? const Color(0xFF030213)
                  : const Color(0xFF717182),
              statusLabel: hasCheckedIn ? 'Logged' : null,
              statusBackgroundColor: const Color(0xFF28A745).withOpacity(0.1),
              statusTextColor: const Color(0xFF28A745),
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECECF0), height: 1),
            const SizedBox(height: 16),

            /// Check-out Entry
            LogEntryItem(
              icon: hasCheckedOut
                  ? Icons.cancel
                  : (isOngoing ? Icons.access_time : Icons.access_time),
              iconColor: hasCheckedOut
                  ? const Color(0xFFDC3545)
                  : (isOngoing
                        ? const Color(0xFFFFC107)
                        : const Color(0xFF717182)),
              backgroundColor: hasCheckedOut
                  ? const Color(0xFFDC3545).withOpacity(0.1)
                  : const Color(0xFFECECF0),
              label: 'Check-out',
              value: hasCheckedOut
                  ? AttendanceRecord.formatTime(_attendanceRecord.checkOutTime)
                  : (isOngoing ? 'Ongoing...' : '—'),
              valueColor: hasCheckedOut
                  ? const Color(0xFF030213)
                  : (isOngoing
                        ? const Color(0xFFFFC107)
                        : const Color(0xFF717182)),
              statusLabel: hasCheckedOut ? 'Logged' : null,
              statusBackgroundColor: const Color(0xFFDC3545).withOpacity(0.1),
              statusTextColor: const Color(0xFFDC3545),
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECECF0), height: 1),
            const SizedBox(height: 16),

            /// Total Hours Entry
            LogEntryItem(
              icon: Icons.access_time,
              iconColor: const Color(0xFF007BFF),
              backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
              label: 'Total Hours',
              value: _elapsedTime,
              valueColor: const Color(0xFF030213),
            ),
          ],
        ),
      ),
    );
  }
}
