import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';
import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_history_record.dart';
import 'package:pds_app/Widgets/Attandence/attandence.dart';
import 'package:pds_app/Widgets/Leave_Screen&Login/Leave_Status.dart';
import 'package:pds_app/Widgets/user%20profile/profile_c.dart';
import 'package:pds_app/features/Location_Get&Finde_Mock/map_view.dart';
import 'package:pds_app/Widgets/dashbordview/drawer.dart';
import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_db.dart';

// DASHBOARD CONTROLLER

class DashboardController extends GetxController {
  RxDouble deviceWidth = 0.0.obs;
  RxDouble deviceHeight = 0.0.obs;
  RxInt totalAttendance = 0.obs;

  Rx<DateTime> currentDateTime = DateTime.now().obs;
  Timer? _timer;

  void updateSize(double width, double height) {
    deviceWidth.value = width;
    deviceHeight.value = height;
  }

  Future<void> loadAttendanceStats() async {
    final records = await AttendanceDb.instance.getAllRecords();
    final completed = records
        .where((r) => r.status == RecordStatus.complete)
        .length;
    totalAttendance.value = completed;
  }

  void _startClock() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      currentDateTime.value = DateTime.now();
    });
  }

  String get greeting {
    final hour = currentDateTime.value.hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get formattedDate {
    return DateFormat('EEEE, MMMM d').format(currentDateTime.value);
  }

  @override
  void onInit() {
    super.onInit();
    _startClock();
    loadAttendanceStats();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class Dashboard_Screen extends StatelessWidget {
  const Dashboard_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const double baseWidth = 390.0;

    final double w = Get.width;
    final double h = Get.height;
    final double scale = w / baseWidth;
    double sp(double size) => size * scale;

    const Color kBlue = Color(0xFF1A57D8);
    const Color kLightBg = Color(0xFFF4F5F9);

    // --- GetX controllers (shared instances) ---
    final DashboardController dashboardController =
        Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    final AttendanceController attendanceController =
        Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());

    // keep size in controller for reuse if you need
    dashboardController.updateSize(w, h);

    // These values define the curved sheet in the header:
    const double sheetHeightLocal =
        110.0; // same units as design base; will be scaled
    final double sheetHeight = sheetHeightLocal * scale;
    //final double overlap = sheetHeight * 0.4;

    return Scaffold(
      backgroundColor: kLightBg,
      drawer: MyDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: w * 0.5,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER (with curved overlapping white sheet)
              _HeaderSection(
                scale: scale,
                sp: sp,
                blue: kBlue,
                sheetHeight: sheetHeight,
                dashboardController: dashboardController,
              ),

              // spacing so content sits nicely on white sheet (tweak as needed)
              SizedBox(height: (sheetHeight * 0.3)),

              // BODY
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // My Attendance
                    Text(
                      'My Attendance',
                      style: TextStyle(
                        fontSize: sp(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    _AttendanceCard(
                      scale: scale,
                      sp: sp,
                      blue: kBlue,
                      dashboardController: dashboardController,
                      attendanceController: attendanceController,
                    ),

                    SizedBox(height: 24 * scale),

                    // Overview
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: sp(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Obx(
                      () => _OverviewRow(
                        scale: scale,
                        sp: sp,
                        totalAttendance:
                            dashboardController.totalAttendance.value,
                      ),
                    ),

                    SizedBox(height: 24 * scale),

                    // Today's Summary
                    Text(
                      "Today's Summary",
                      style: TextStyle(
                        fontSize: sp(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    _TodaySummary(scale: scale, sp: sp),

                    SizedBox(height: 24 * scale),

                    // Quick Actions
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: sp(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    _QuickActions(
                      scale: scale,
                      sp: sp,
                      attendanceController: attendanceController,
                    ),

                    SizedBox(height: 24 * scale),

                    // Current Location (old FooterLocation behavior)
                    Text(
                      "Current Location",
                      style: TextStyle(
                        fontSize: sp(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    _FooterLocation(scale: scale),
                    SizedBox(height: 24 * scale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// HEADER (UPDATED TO OPEN DRAWER + PROFILE + curved sheet)
class _HeaderSection extends StatelessWidget {
  final double scale;
  final double Function(double) sp;
  final Color blue;
  final double sheetHeight;
  final DashboardController dashboardController; // <-- added

  const _HeaderSection({
    required this.scale,
    required this.sp,
    required this.blue,
    required this.sheetHeight,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context) {
    // header height
    final double headerHeight = 300 * scale;
    // how much the sheet overlaps outside the header (negative space)
    final double overlap = sheetHeight * 0;
    final double totalHeight = headerHeight + overlap;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blue header background
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              color: blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                12 * scale,
                16 * scale,
                20 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // top icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // MENU -> OPEN DRAWER
                      Builder(
                        builder: (ctx) => GestureDetector(
                          onTap: () => Scaffold.of(ctx).openDrawer(),
                          child: _roundIcon(
                            icon: Icons.menu,
                            size: 40 * scale,
                            color: Colors.white,
                            bg: Colors.white.withOpacity(0.12),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _roundIcon(
                                icon: Icons.notifications_none_rounded,
                                size: 40 * scale,
                                color: Colors.white,
                                bg: Colors.white.withOpacity(0.12),
                              ),
                              Positioned(
                                top: 8 * scale,
                                right: 8 * scale,
                                child: Container(
                                  width: 12 * scale,
                                  height: 12 * scale,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10 * scale),
                          GestureDetector(
                            onTap: () => Get.to(() => const ProfileScreen()),
                            child: Container(
                              width: 36 * scale,
                              height: 36 * scale,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'S',
                                style: TextStyle(
                                  fontSize: sp(16),
                                  fontWeight: FontWeight.bold,
                                  color: blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 24 * scale),

                  // Dynamic greeting (reads from dashboardController)
                  Obx(
                    () => Text(
                      dashboardController.greeting,
                      style: TextStyle(
                        fontSize: sp(13),
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    'Hello Engineer',
                    style: TextStyle(
                      fontSize: sp(22),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale,
                          vertical: 6 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        child: Text(
                          'BLOCK ENGINEER',
                          style: TextStyle(
                            fontSize: sp(10),
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Obx(
                        () => Text(
                          dashboardController.formattedDate,
                          style: TextStyle(
                            fontSize: sp(11),
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Decorative faint circles (optional)
          Positioned(
            right: -60 * scale,
            top: 40 * scale,
            child: Container(
              width: 150 * scale,
              height: 150 * scale,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -30 * scale,
            bottom: -30 * scale,
            child: Container(
              width: 110 * scale,
              height: 110 * scale,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // White curved sheet that overlaps the header
          Positioned(
            left: 0 * scale,
            right: 0 * scale,
            bottom: overlap,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 239, 236, 236),
                // borderRadius: BorderRadius.circular(24 * scale),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16 * scale,
                    offset: Offset(0, 10 * scale),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon({
    required IconData icon,
    required double size,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.6),
    );
  }
}

// ATTENDANCE CARD (now uses real status + DateTime for showing current time)

class _AttendanceCard extends StatelessWidget {
  final double scale;
  final double Function(double) sp;
  final Color blue;
  final DashboardController dashboardController;
  final AttendanceController attendanceController;

  const _AttendanceCard({
    required this.scale,
    required this.sp,
    required this.blue,
    required this.dashboardController,
    required this.attendanceController,
  });

  String _formatDateTime(DateTime t) {
    return DateFormat.jm().format(t); // e.g. "2:45 PM"
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final now = dashboardController.currentDateTime.value;
      final record = attendanceController.attendanceRecord.value;
      final hasCheckedOut = record.checkOutTime != null;
      final bool isCheckedIn = record.isCheckedIn;

      String mainStatus;
      String subStatus;
      Color statusColor;

      if (isCheckedIn) {
        mainStatus = 'Checked In';
        subStatus =
            'Since ${AttendanceRecord.formatTime(record.checkInTime)} • ${attendanceController.elapsedTime.value}';
        statusColor = const Color(0xFF1AAA55);
      } else if (hasCheckedOut) {
        mainStatus = 'Checked Out';
        subStatus = 'At ${AttendanceRecord.formatTime(record.checkOutTime)}';
        statusColor = Colors.orangeAccent;
      } else {
        mainStatus = 'Attendance Not Marked';
        subStatus = 'Tap Check In to mark your attendance';
        statusColor = Colors.redAccent;
      }

      return Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row with icon & status text
            Row(
              children: [
                Container(
                  width: 44 * scale,
                  height: 44 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Colors.grey.shade600,
                    size: 22 * scale,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Time • ${_formatDateTime(now)}',
                      style: TextStyle(
                        fontSize: sp(11),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      mainStatus,
                      style: TextStyle(
                        fontSize: sp(18),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      subStatus,
                      style: TextStyle(
                        fontSize: sp(11),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  isCheckedIn
                      ? 'Active'
                      : (hasCheckedOut ? 'Completed' : 'Inactive'),
                  style: TextStyle(
                    fontSize: sp(12),
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14 * scale),
            SizedBox(
              width: double.infinity,
              height: 46 * scale,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const AttendanceTrackingScreen());
                },
                icon: Icon(
                  isCheckedIn ? Icons.visibility_rounded : Icons.login_rounded,
                  size: 20 * scale,
                  color: Colors.white,
                ),
                label: Text(
                  isCheckedIn ? 'View Details' : 'Check In',
                  style: TextStyle(
                    fontSize: sp(17),
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// OVERVIEW  (uses totalAttendance for one card)

class _OverviewRow extends StatelessWidget {
  final double scale;
  final double Function(double) sp;
  final int totalAttendance;

  const _OverviewRow({
    required this.scale,
    required this.sp,
    required this.totalAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            scale: scale,
            sp: sp,
            title: 'Total Attandence',
            count: totalAttendance.toString(),
            icon: Icons.trending_up,
            bgColor: Colors.white,
            iconBg: const Color(0xFFE7F0FF),
            iconColor: const Color(0xFF3677F6),
            onTap: () => Get.to(() => const PastRecordsScreen()),
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _OverviewCard(
            scale: scale,
            sp: sp,
            title: 'Leave',
            count: "-",
            icon: Icons.leave_bags_at_home,
            bgColor: const Color(0xFFFFF4DD),
            iconBg: const Color(0xFFFFE6BA),
            iconColor: const Color(0xFFFF9400),
            onTap: () => Get.to(() => const MyLeavesScreen()),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final double scale;
  final double Function(double) sp;
  final String title;
  final String count;
  final IconData icon;
  final Color bgColor;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;

  const _OverviewCard({
    required this.scale,
    required this.sp,
    required this.title,
    required this.count,
    required this.icon,
    required this.bgColor,
    required this.iconBg,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(18 * scale),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18 * scale),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Icon(icon, size: 22 * scale, color: iconColor),
              ),
              SizedBox(height: 12 * scale),
              Text(
                title,
                style: TextStyle(
                  fontSize: sp(13),
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                count,
                style: TextStyle(
                  fontSize: sp(22),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TODAY'S SUMMARY

class _TodaySummary extends StatelessWidget {
  final double scale;
  final double Function(double) sp;

  const _TodaySummary({required this.scale, required this.sp});

  @override
  Widget build(BuildContext context) {
    final double radius = 18 * scale;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 12 * scale,
      ),
      child: Column(
        children: [
          _summaryRow(
            scale: scale,
            sp: sp,
            bgColor: const Color(0xFFEAFBF0),
            iconBg: Colors.white,
            iconColor: const Color(0xFF1AAA55),
            textColor: const Color(0xFF1AAA55),
            icon: Icons.check_circle_outline,
            text: '2 site visits planned',
          ),
          SizedBox(height: 8 * scale),
          _summaryRow(
            scale: scale,
            sp: sp,
            bgColor: const Color(0xFFFFECEC),
            iconBg: Colors.white,
            iconColor: const Color(0xFFE53935),
            textColor: const Color(0xFFE53935),
            icon: Icons.error_outline,
            text: '1 urgent issue pending',
          ),
          SizedBox(height: 8 * scale),
          _summaryRow(
            scale: scale,
            sp: sp,
            bgColor: const Color(0xFFEAF4FF),
            iconBg: Colors.white,
            iconColor: const Color(0xFF1A57D8),
            textColor: const Color(0xFF1A57D8),
            icon: Icons.list_alt_outlined,
            text: '4 tickets under review',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required double scale,
    required double Function(double) sp,
    required Color bgColor,
    required Color iconBg,
    required Color iconColor,
    required Color textColor,
    required IconData icon,
    required String text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 10 * scale,
      ),
      child: Row(
        children: [
          Container(
            width: 34 * scale,
            height: 34 * scale,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(icon, size: 20 * scale, color: iconColor),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: sp(14),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// QUICK ACTIONS (wired to real navigation)
// =====================================================

class _QuickActions extends StatelessWidget {
  final double scale;
  final double Function(double) sp;
  final AttendanceController attendanceController;

  const _QuickActions({
    required this.scale,
    required this.sp,
    required this.attendanceController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _quickCard(
          scale: scale,
          sp: sp,
          bgColor: Colors.white,
          iconBg: const Color(0xFFE8F1FF),
          iconColor: const Color(0xFF1A57D8),
          icon: Icons.login,
          title: 'Check In / Out',
          subtitle: 'Open attendance screen',
          onTap: () => Get.to(() => const AttendanceTrackingScreen()),
        ),
        SizedBox(height: 12 * scale),
        _quickCard(
          scale: scale,
          sp: sp,
          bgColor: const Color(0xFFFFF4DD),
          iconBg: const Color(0xFFFFE5BA),
          iconColor: const Color(0xFFFF9400),
          icon: Icons.history,
          title: 'Attendance History',
          subtitle: 'View past records',
          onTap: () => Get.to(() => const PastRecordsScreen()),
        ),
        SizedBox(height: 12 * scale),
        _quickCard(
          scale: scale,
          sp: sp,
          bgColor: Colors.white,
          iconBg: const Color(0xFFE8F1FF),
          iconColor: const Color(0xFF1A57D8),
          icon: Icons.map_outlined,
          title: 'View My Sites',
          subtitle: 'Open map view',
          onTap: () => Get.to(() => const MapView()),
        ),
      ],
    );
  }

  Widget _quickCard({
    required double scale,
    required double Function(double) sp,
    required Color bgColor,
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(18 * scale),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18 * scale),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Row(
            children: [
              Container(
                width: 40 * scale,
                height: 40 * scale,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child: Icon(icon, color: iconColor, size: 22 * scale),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: sp(15),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: sp(12),
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22 * scale,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CURRENT LOCATION (based on old FooterLocation)
// =====================================================

class _FooterLocation extends StatelessWidget {
  final double scale;

  const _FooterLocation({required this.scale});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Get.width < 600;
    final double mapHeight = isMobile ? 220 * scale : 260 * scale;

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: [
          BoxShadow(
            blurRadius: 16 * scale,
            offset: Offset(0, 6 * scale),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SizedBox(
        height: mapHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18 * scale),
                child: const MapView(),
              ),
            ),
            Positioned(
              left: 10 * scale,
              top: 10 * scale,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16 * scale),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8 * scale,
                      offset: Offset(0, 3 * scale),
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                child: Text(
                  '2.5 km away',
                  style: TextStyle(
                    fontSize: 11 * scale,
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
}
