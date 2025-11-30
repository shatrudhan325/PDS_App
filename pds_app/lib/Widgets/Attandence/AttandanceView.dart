import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pds_app/Widgets/Attandence/attandence.dart';
import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
import 'package:pds_app/features/Location_Get&Finde_Mock/attandenceLocation.dart';
import 'package:pds_app/core/Services/Android_id_get.dart';
import 'package:pds_app/core/Services/token_store.dart';
import 'Attandance_info_card.dart';
import 'log_entry_items.dart';

///   Model for current location data
class AttendanceLocationData {
  final double latitude;
  final double longitude;
  final bool isMock;
  final double accuracy;
  final String address;

  AttendanceLocationData({
    required this.latitude,
    required this.longitude,
    required this.isMock,
    required this.accuracy,
    required this.address,
  });

  /// If you ever need to serialize location directly, this matches backend keys
  Map<String, dynamic> toJson() => {
    'myLatitude': latitude,
    'myLongitude': longitude,
    'isMock': isMock.toString(), // "true" / "false"
    'accuracy': accuracy,
    'address': address,
  };
}

///  GetX Controller
class AttendanceController extends GetxController {
  final attendanceRecord = AttendanceRecord().obs;
  final isFakeLocation = false.obs;
  final elapsedTime = '0 hours, 0 minutes'.obs;

  // latest location from LiveLocationWidgets
  final Rxn<AttendanceLocationData> lastLocation =
      Rxn<AttendanceLocationData>();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// Compare only date part (year, month, day)
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Start a timer to update elapsed time every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (attendanceRecord.value.isCheckedIn) {
        elapsedTime.value = attendanceRecord.value.getElapsedTime();
      }
    });
  }

  /// Called by location widget with full data
  void updateLocation(AttendanceLocationData location) {
    lastLocation.value = location;
    isFakeLocation.value = location.isMock;
  }

  /// Handle check-in action (only once per day)
  Future<void> handleCheckIn() async {
    if (isFakeLocation.value) {
      Get.snackbar(
        'Check-in blocked',
        'Fake GPS detected! Check-in not allowed.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFFDC3545),
        colorText: Colors.white,
      );
      return;
    }

    if (lastLocation.value == null) {
      Get.snackbar(
        'Location missing',
        'Unable to get current location. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final now = DateTime.now();
    final currentRecord = attendanceRecord.value;

    // Already checked in today? Block second check-in
    if (currentRecord.checkInTime != null &&
        _isSameDate(currentRecord.checkInTime!, now)) {
      Get.snackbar(
        'Already checked in',
        'You have already checked in for today.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    // Either first time or new day → fresh record for today
    final record = AttendanceRecord(
      checkInTime: now,
      checkOutTime: null,
      isCheckedIn: true,
    );

    attendanceRecord.value = record;
    elapsedTime.value = record.getElapsedTime();

    // Fire & forget API
    _sendAttendanceToBackend(action: 'check_in');
  }

  /// Handle check-out action (only for today's check-in)
  Future<void> handleCheckOut() async {
    final currentRecord = attendanceRecord.value;
    final now = DateTime.now();

    // No check-in or not today's check-in → block
    if (currentRecord.checkInTime == null ||
        !_isSameDate(currentRecord.checkInTime!, now)) {
      Get.snackbar(
        'No active check-in',
        'You have not checked in today.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final updated = currentRecord.copyWith(
      checkOutTime: now,
      isCheckedIn: false,
    );

    attendanceRecord.value = updated;
    elapsedTime.value = updated.getElapsedTime();
    _sendAttendanceToBackend(action: 'check_out');
  }

  Future<void> _sendAttendanceToBackend({required String action}) async {
    final loc = lastLocation.value;

    if (loc == null) {
      debugPrint('No location data available. Skipping API call.');
      return;
    }

    const String apiUrl =
        'http://192.168.29.202:8080/v1/m/attendance/mark_attendance';

    final String? androidId = await DeviceInfoService.getAndroidId();
    final String? authToken = await TokenStorage.getToken();

    final payload = <String, dynamic>{
      'myLatitude': loc.latitude.toPrecision(5),
      'myLongitude': loc.longitude.toPrecision(5),
      'isMock': loc.isMock.toString(),
      'address': loc.address,
      'accuracy': loc.accuracy.toPrecision(2),
      'buildNumber': androidId,
      'type': action == 'check_in' ? 'CHECK-IN' : 'CHECK-OUT',
    };

    debugPrint('Sending attendance payload: $payload');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Attendance saved successfully');
      } else {
        debugPrint(
          'Attendance API failed: ${response.statusCode} ${response.body}',
        );
        Get.snackbar(
          'Server error',
          'Unable to save attendance. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Attendance API error: $e');
      Get.snackbar(
        'Network error',
        'Failed to connect to server.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// Attendance tracking screen yaha se hai.
class AttendanceTrackingScreen extends StatelessWidget {
  const AttendanceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register/Get controller
    final AttendanceController controller = Get.put(AttendanceController());

    final double h = Get.height;
    final double w = Get.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      /// App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF030213)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Daily Attendance',
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF030213),
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

      /// Body
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(w * 0.04),
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

              SizedBox(height: h * 0.02),

              /// Location Indicator Card
              Container(
                width: double.infinity,
                height: h * 0.25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
                  ),
                  borderRadius: BorderRadius.circular(w * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: w * 0.03,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: LiveLocationWidgets(
                  onLocationUpdate: controller.updateLocation,
                ),
              ),

              SizedBox(height: h * 0.02),

              /// Primary Action Card (reactive)
              Obx(() => _buildPrimaryActionCard(controller, h, w)),

              SizedBox(height: h * 0.03),

              /// Today's Log Header
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF717182),
                    size: 20,
                  ),
                  SizedBox(width: w * 0.02),
                  Text(
                    "Today's Log",
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF030213),
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.015),

              /// Today's Log History Card (reactive)
              Obx(() => _buildLogHistoryCard(controller, h, w)),

              SizedBox(height: h * 0.03),

              /// Footer - View Past Records
              Center(
                child: TextButton(
                  onPressed: () {
                    debugPrint('View Past Records clicked');
                    Get.to(() => const PastRecordsScreen());
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.06,
                      vertical: h * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.02),
                    ),
                  ),
                  child: Text(
                    'View Past Records',
                    style: TextStyle(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF007BFF),
                    ),
                  ),
                ),
              ),

              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  /// Primary Action Card (Check-in / Check-out)
  Widget _buildPrimaryActionCard(
    AttendanceController controller,
    double h,
    double w,
  ) {
    final record = controller.attendanceRecord.value;
    final bool isCheckedIn = record.isCheckedIn;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCheckedIn
              ? [const Color(0xFFFFC107), const Color(0xFFFF9800)]
              : [const Color(0xFF007BFF), const Color(0xFF0056b3)],
        ),
        borderRadius: BorderRadius.circular(w * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: w * 0.03,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Status Header
            Row(
              children: [
                Icon(
                  isCheckedIn ? Icons.check_circle : Icons.access_time,
                  color: Colors.white,
                  size: w * 0.055,
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  child: Text(
                    isCheckedIn
                        ? 'Status: Work in Progress'
                        : 'Status: Ready to Start',
                    style: TextStyle(
                      fontSize: w * 0.05,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: h * 0.01),

            /// Status Description
            Text(
              isCheckedIn
                  ? 'Checked in at ${AttendanceRecord.formatTime(record.checkInTime)}'
                  : 'Tap to log your attendance.',
              style: TextStyle(fontSize: w * 0.04, color: Colors.white),
            ),

            SizedBox(height: h * 0.03),

            /// Action Button
            SizedBox(
              width: double.infinity,
              height: h * 0.065,
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
                            Get.back();
                            controller.handleCheckOut();
                          },
                          buttonColor: const Color(0xFFDC3545),
                          confirmTextColor: Colors.white,
                        );
                      }
                    : () => controller.handleCheckIn(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCheckedIn
                      ? const Color(0xFFDC3545)
                      : Colors.white,
                  foregroundColor: isCheckedIn
                      ? Colors.white
                      : const Color(0xFF007BFF),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.02),
                  ),
                ),
                child: Text(
                  isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                  style: TextStyle(
                    fontSize: w * 0.045,
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

  /// Log History Card: Check-in, Check-out, Total Hours
  Widget _buildLogHistoryCard(
    AttendanceController controller,
    double h,
    double w,
  ) {
    final record = controller.attendanceRecord.value;
    final hasCheckedIn = record.checkInTime != null;
    final hasCheckedOut = record.checkOutTime != null;
    final isOngoing = record.isCheckedIn;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
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
              value: AttendanceRecord.formatTime(record.checkInTime),
              valueColor: hasCheckedIn
                  ? const Color(0xFF030213)
                  : const Color(0xFF717182),
              statusLabel: hasCheckedIn ? 'Logged' : null,
              statusBackgroundColor: const Color(0xFF28A745).withOpacity(0.1),
              statusTextColor: const Color(0xFF28A745),
            ),

            SizedBox(height: h * 0.02),
            const Divider(color: Color(0xFFECECF0), height: 1),
            SizedBox(height: h * 0.02),

            /// Check-out Entry
            LogEntryItem(
              icon: hasCheckedOut ? Icons.cancel : Icons.access_time,
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
                  ? AttendanceRecord.formatTime(record.checkOutTime)
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

            SizedBox(height: h * 0.02),
            const Divider(color: Color(0xFFECECF0), height: 1),
            SizedBox(height: h * 0.02),

            /// Total Hours Entry
            Obx(
              () => LogEntryItem(
                icon: Icons.access_time,
                iconColor: const Color(0xFF007BFF),
                backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
                label: 'Total Hours',
                value: controller.elapsedTime.value,
                valueColor: const Color(0xFF030213),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
