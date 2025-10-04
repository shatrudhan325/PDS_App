import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pds_app/core/widgets/Attandence/AttandencePastRecord.dart';
import 'package:pds_app/core/widgets/Location_Get&Finde_Mock/locationservice.dart';
// import 'package:pds_app/core/widgets/AttandanceView.dart';
// import 'package:pds_app/core/widgets/LiveLocationWidget.dart';

/// ============================================================================
/// DAILY ATTENDANCE TRACKING - COMPLETE SINGLE FILE IMPLEMENTATION
/// ============================================================================
///
/// This file contains everything needed for the Daily Attendance Tracking screen:
/// - Data Models
/// - Reusable Widgets
/// - Main Screen Implementation
///
/// Design System:
/// - Primary Blue: #007BFF
/// - Success Green: #28A745
/// - Warning Orange: #FFC107
/// - Error Red: #DC3545
/// - Background: #F8F9FA
/// - Surface White: #FFFFFF
/// ============================================================================

// ============================================================================
// DATA MODEL
// ============================================================================

/// Model class for attendance data
class AttendanceRecord {
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool isCheckedIn;

  AttendanceRecord({
    this.checkInTime,
    this.checkOutTime,
    this.isCheckedIn = false,
  });

  /// Calculate elapsed time between check-in and check-out (or current time if still checked in)
  String getElapsedTime() {
    if (checkInTime == null) {
      return '0 hours, 0 minutes';
    }

    final endTime = isCheckedIn
        ? DateTime.now()
        : (checkOutTime ?? checkInTime!);
    final duration = endTime.difference(checkInTime!);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '$hours hours, $minutes minutes';
  }

  /// Format time to 12-hour format
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '—';

    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  /// Get current date formatted as "DayName, Month Date"
  static String getCurrentDate() {
    final now = DateTime.now();
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }

  AttendanceRecord copyWith({
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? isCheckedIn,
  }) {
    return AttendanceRecord(
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }
}

// ============================================================================
// REUSABLE WIDGETS
// ============================================================================

/// Reusable card widget for displaying attendance information
class AttendanceInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final Widget value;

  const AttendanceInfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF717182),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Value is now a Widget so callers can provide Text or any other widget.
                  value,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable widget for displaying a log entry (check-in/check-out/total)
class LogEntryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final String value;
  final Color valueColor;
  final String? statusLabel;
  final Color? statusBackgroundColor;
  final Color? statusTextColor;

  const LogEntryItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    required this.valueColor,
    this.statusLabel,
    this.statusBackgroundColor,
    this.statusTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Icon and text
        Expanded(
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717182),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: valueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Right side - Status badge (optional)
        if (statusLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBackgroundColor ?? Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: statusTextColor ?? Colors.black,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// MAIN SCREEN
// ============================================================================

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
                value: Text(
                  AttendanceRecord.getCurrentDate(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF030213),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Current Location Card
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
              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: LiveLocationWidget(),
              ),

              const SizedBox(height: 16),

              /// Footer - View Past Records Button
              Center(
                child: TextButton(
                  onPressed: () {
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
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  // Determine if we're checking out or checking in
                  final bool isCheckingOut = isCheckedIn;
                  final String actionName = isCheckingOut
                      ? 'Check-out'
                      : 'Check-in';

                  // Location permission check
                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location permissions are denied'),
                        ),
                      );
                      return;
                    }
                  }

                  // Attempt to get the current position and validate it
                  try {
                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );

                    // Reject mocked locations
                    if (position.isMocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fake location detected! Attendance not marked.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Mark attendance and update UI
                    setState(() {
                      if (isCheckingOut) {
                        _handleCheckOut();
                      } else {
                        _handleCheckIn();
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Real location. $actionName marked successfully!',
                        ),
                        backgroundColor: isCheckingOut
                            ? Colors.blue
                            : Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error getting location: $e')),
                    );
                  }
                },
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
                  isCheckedIn ? 'Check out' : 'Check in',
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

// ============================================================================
// DEMO APP - HOW TO USE
// ============================================================================

/// Example usage - wrap in MaterialApp and navigate to the screen
/// 
/// ```dart
/// void main() {
///   runApp(MaterialApp(
///     home: AttendanceTrackingScreen(),
///   ));
/// }
/// ```
/// 
/// Or navigate from another screen:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => AttendanceTrackingScreen()),
/// );
/// ```
