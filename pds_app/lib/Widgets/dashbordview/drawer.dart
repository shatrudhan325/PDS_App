// // Yaha se fully responsive + Sub Drawer added code hai.
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';
// import 'package:pds_app/Widgets/Leave_Screen&Login/Leave_Approved_Screen.dart';
// import 'package:pds_app/Widgets/Leave_Screen&Login/Leave_Request_Screen.dart';
// import 'package:pds_app/Widgets/Ticket.dart';
// import 'package:pds_app/features/QR/Scannerdart.dart';
// import 'package:pds_app/features/Tag%20Location/Tag_Location_Logic.dart';
// import 'package:pds_app/features/authentication/screens/login.dart';

// /// Controller for Drawer state/actions
// class DrawerControllerX extends GetxController {
//   final title = 'Dashboard Menu'.obs;
//   final subtitle = 'Welcome to your panel'.obs;
//   final bgImagePath = 'assets/images/Trinetra Inhenced logo.png'.obs;

//   /// Theme toggle (example)
//   void toggleTheme() {
//     Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
//   }

//   /// Navigation helpers
//   void openTicketPunch() => Get.to(() => CreateTicketPage());

//   /// Subsection 1: Attendance Check in / Check out
//   void openAttendanceCheck() => Get.to(() => AttendanceTrackingScreen());

//   /// Subsection 2: Tag Location
//   void openTagLocation() => Get.to(() => TagLocationPage());

//   void openLeaveRequestForm() => Get.to(() => LeaveRequestPage());

//   void openLeaveApprovelScreen() => Get.to(() => MyLeavesScreen(userId: 1));

//   void openQRScanner() => Get.to(() => QRCodeScanner());
//   void openLogout() => Get.to(() => LoginPage());

//   // Future<void> logout() async {
//   //   // await AuthService.logout();
//   //   Get.offAllNamed('/login');
//   // }
// }

// /// Responsive helpers
// class R {
//   final double w;
//   final double h;
//   R._(this.w, this.h);

//   factory R.of() {
//     return R._(Get.width, Get.height);
//   }

//   double wp(double percent) => w * percent / 100;
//   double hp(double percent) => h * percent / 100;

//   bool get isTablet => w >= 600;
//   double scaledFont(double base) => isTablet ? base * 1.25 : base;
// }

// class MyDrawer extends StatelessWidget {
//   MyDrawer({Key? key}) : super(key: key);

//   final DrawerControllerX c = Get.put(DrawerControllerX());

//   @override
//   Widget build(BuildContext context) {
//     final r = R.of();

//     return Drawer(
//       child: Column(
//         children: [
//           // Responsive header
//           Obx(() {
//             final bg = c.bgImagePath.value;
//             final title = c.title.value;
//             final subtitle = c.subtitle.value;

//             final headerHeight = r.isTablet ? r.hp(30) : r.hp(20);
//             final avatarRadius = r.isTablet
//                 ? r.wp(8)
//                 : r.wp(10); // avatar scales with width

//             return SizedBox(
//               width: double.infinity,
//               height: headerHeight,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // Background image
//                   if (bg.isNotEmpty)
//                     Image.asset(bg, fit: BoxFit.cover)
//                   else
//                     Container(color: Colors.blueAccent),

//                   // Dark overlay for readability
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.black.withOpacity(0.35),
//                           Colors.black.withOpacity(0.10),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                   ),

//                   // Content (avatar + texts)
//                   SafeArea(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: r.wp(4),
//                         vertical: r.hp(1.4),
//                       ),
//                       child: r.isTablet
//                           ? Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 CircleAvatar(
//                                   radius: avatarRadius,
//                                   backgroundColor: Colors.white,
//                                   child: Icon(
//                                     Icons.dashboard,
//                                     size: avatarRadius,
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                                 SizedBox(width: r.wp(3)),
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       title,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: r.scaledFont(22),
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(height: r.hp(0.6)),
//                                     Text(
//                                       subtitle,
//                                       style: TextStyle(
//                                         color: Colors.white70,
//                                         fontSize: r.scaledFont(14),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const Spacer(),
//                                 IconButton(
//                                   onPressed: () {
//                                     // quick action
//                                   },
//                                   icon: const Icon(
//                                     Icons.person,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: avatarRadius,
//                                       backgroundColor: Colors.white,
//                                       child: Icon(
//                                         Icons.dashboard,
//                                         size: avatarRadius,
//                                         color: Colors.blue,
//                                       ),
//                                     ),
//                                     SizedBox(width: r.wp(3)),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             title,
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: r.scaledFont(18),
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           SizedBox(height: r.hp(0.5)),
//                                           Text(
//                                             subtitle,
//                                             style: TextStyle(
//                                               color: Colors.white70,
//                                               fontSize: r.scaledFont(12),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),

//           // Drawer items
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 _buildResponsiveTile(
//                   icon: Icons.confirmation_number,
//                   text: 'Ticket Punch',
//                   onTap: () {
//                     Navigator.of(context).pop(); // close drawer
//                     c.openTicketPunch();
//                   },
//                 ),

//                 // Attendance section with sub-items
//                 _buildAttendanceSection(context),

//                 _buildResponsiveTile(
//                   icon: Icons.qr_code_scanner,
//                   text: 'QR Scanner',
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     c.openQRScanner();
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Bottom actions (Mode, Logout) pinned to bottom
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: r.wp(3),
//               vertical: r.hp(1.6),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Divider(height: 1),
//                 SizedBox(height: r.hp(1)),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildResponsiveTile(
//                         icon: Icons.dark_mode,
//                         text: 'Mode',
//                         onTap: () {
//                           c.toggleTheme();
//                         },
//                       ),
//                     ),
//                     SizedBox(width: r.wp(2)),
//                     Expanded(
//                       child: _buildResponsiveTile(
//                         icon: Icons.logout,
//                         text: 'Logout',
//                         onTap: () {
//                           Get.to(() => LoginPage());
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Attendance section as ExpansionTile with 2 sub-items
//   Widget _buildAttendanceSection(BuildContext context) {
//     final r = R.of();
//     return Theme(
//       // remove default ExpansionTile divider color
//       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//       child: ExpansionTile(
//         leading: Icon(
//           Icons.access_time,
//           color: Colors.blue,
//           size: r.isTablet ? r.wp(5) : r.wp(6.2),
//         ),
//         title: Text(
//           'Attendance',
//           style: TextStyle(fontSize: r.isTablet ? 18 : 16),
//         ),
//         childrenPadding: EdgeInsets.only(
//           left: r.wp(8),
//           right: r.wp(4),
//           bottom: r.hp(0.6),
//         ),
//         children: [
//           ListTile(
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: r.wp(2),
//               vertical: r.hp(0.4),
//             ),
//             leading: const Icon(Icons.check_circle_outline, color: Colors.blue),
//             title: Text(
//               'Attendance Check In / Check Out',
//               style: TextStyle(fontSize: r.isTablet ? 16 : 14),
//             ),
//             onTap: () {
//               Navigator.of(context).pop();
//               c.openAttendanceCheck();
//             },
//           ),
//           ListTile(
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: r.wp(2),
//               vertical: r.hp(0.4),
//             ),
//             leading: const Icon(Icons.location_on_outlined, color: Colors.blue),
//             title: Text(
//               'Tag Location',
//               style: TextStyle(fontSize: r.isTablet ? 16 : 14),
//             ),
//             onTap: () {
//               Navigator.of(context).pop();
//               c.openTagLocation();
//             },
//           ),
//           ListTile(
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: r.wp(2),
//               vertical: r.hp(0.4),
//             ),
//             leading: const Icon(Icons.time_to_leave, color: Colors.blue),
//             title: Text(
//               'Leave Request',
//               style: TextStyle(fontSize: r.isTablet ? 16 : 14),
//             ),
//             onTap: () {
//               Navigator.of(context).pop();
//               c.openLeaveRequestForm();
//             },
//           ),
//           ListTile(
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: r.wp(2),
//               vertical: r.hp(0.4),
//             ),
//             leading: const Icon(
//               Icons.leave_bags_at_home_sharp,
//               color: Colors.blue,
//             ),
//             title: Text(
//               'Leave Status',
//               style: TextStyle(fontSize: r.isTablet ? 16 : 14),
//             ),
//             onTap: () {
//               Navigator.of(context).pop();
//               c.openLeaveApprovelScreen();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResponsiveTile({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//   }) {
//     final r = R.of();
//     return ListTile(
//       contentPadding: EdgeInsets.symmetric(
//         horizontal: r.wp(4),
//         vertical: r.hp(0.6),
//       ),
//       leading: Icon(
//         icon,
//         color: Colors.blue,
//         size: r.isTablet ? r.wp(5) : r.wp(6.2),
//       ),
//       title: Text(text, style: TextStyle(fontSize: r.isTablet ? 18 : 16)),
//       onTap: onTap,
//     );
//   }
// }

// Up Side code is all ok but Ui is Diffrent.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';
import 'package:pds_app/Widgets/Leave_Screen&Login/Leave_Status.dart';
import 'package:pds_app/Widgets/Leave_Screen&Login/Leave_Request_Screen.dart';
import 'package:pds_app/Widgets/Ticket.dart';
import 'package:pds_app/features/QR/Scannerdart.dart';
import 'package:pds_app/features/Tag%20Location/Tag_Location_Logic.dart';
import 'package:pds_app/features/authentication/screens/login.dart';

class DrawerControllerX extends GetxController {
  final title = 'Amit Singh'.obs;
  final subtitle = 'Block Engineer'.obs;
  final bgImagePath = ''.obs;

  final sitesCount = 12.obs;
  final issuesCount = 3.obs;
  final isActive = true.obs;

  void toggleTheme() =>
      Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());

  void openTicketPunch() => Get.to(() => CreateTicketPage());
  void openAllSites() => Get.to(() => ());
  void openCriticalSites() => Get.to(() => ());
  void openInspections() => Get.to(() => ());
  void openAllTickets() => Get.to(() => ());
  void openOpenTickets() => Get.to(() => ());
  void openClosedTickets() => Get.to(() => ());
  void openAttendanceCheck() => Get.to(() => AttendanceTrackingScreen());
  void openTagLocation() => Get.to(() => TagLocationPage());
  void openLeaveRequestForm() => Get.to(() => LeaveRequestPage());
  void openLeaveApprovelScreen() => Get.to(() => MyLeavesScreen());
  void openQRScanner() => Get.to(() => QRCodeScanner());
  void openLogout() => Get.offAll(() => LoginPage());
  void openProfile() => Get.to(() => ());
  void openSettings() => Get.to(() => ());
}

/// Responsive helper
class R {
  final double w;
  final double h;
  R._(this.w, this.h);
  factory R.of() => R._(Get.width, Get.height);
  double wp(double percent) => w * percent / 100;
  double hp(double percent) => h * percent / 100;
  bool get isTablet => w >= 600;
  double scaledFont(double base) => isTablet ? base * 1.25 : base;
}

class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key}) : super(key: key);
  final DrawerControllerX c = Get.put(DrawerControllerX());

  @override
  Widget build(BuildContext context) {
    final r = R.of();

    return Drawer(
      child: Column(
        children: [
          // Header
          Obx(() {
            // final bg = c.bgImagePath.value;
            final headerH = r.isTablet ? r.hp(30) : r.hp(27);
            return Container(
              width: double.infinity,
              height: headerH,
              color: Colors.blue[700],
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.wp(4),
                    vertical: r.hp(2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // small logo avatar like screenshot
                          Container(
                            width: r.wp(10),
                            height: r.wp(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: r.wp(6),
                              ),
                            ),
                          ),
                          SizedBox(width: r.wp(3)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.title.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: r.scaledFont(18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: r.hp(0.4)),
                                Text(
                                  c.subtitle.value,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: r.scaledFont(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.hp(2)),
                      // pill with SITES / ISSUES / STATUS (rounded container)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.wp(3),
                          vertical: r.hp(1.2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[500],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _headerStat(
                              r,
                              'SITES',
                              c.sitesCount.value.toString(),
                            ),
                            _verticalDivider(r),
                            _headerStat(
                              r,
                              'ISSUES',
                              c.issuesCount.value.toString(),
                            ),
                            _verticalDivider(r),
                            _statusSmall(r, c.isActive.value),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // main menu label
          Padding(
            padding: EdgeInsets.fromLTRB(r.wp(5), r.hp(2), r.wp(3), r.hp(1)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MAIN MENU',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: r.isTablet ? r.scaledFont(14) : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),

          // body list
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: r.wp(3)),
              children: [
                // My Sites Expansion styled like screenshot (no visible divider)
                _roundedExpansionCard(
                  r,
                  leadingIcon: Icons.location_city,
                  iconBg: Colors.green[50]!,
                  iconColor: Colors.green,
                  title: 'My Sites',
                  children: [
                    _subItem(r, 'All Sites', () {
                      Navigator.of(context).pop();
                      c.openAllSites();
                    }),
                    _subItem(r, 'Critical Sites', () {
                      Navigator.of(context).pop();
                      c.openCriticalSites();
                    }),
                    _subItem(r, 'Inspections', () {
                      Navigator.of(context).pop();
                      c.openInspections();
                    }),
                  ],
                ),

                SizedBox(height: r.hp(1)),

                // Tickets expansion
                _roundedExpansionCard(
                  r,
                  leadingIcon: Icons.receipt_long,
                  iconBg: Colors.amber[50]!,
                  iconColor: Colors.amber[800]!,
                  title: 'Tickets',
                  children: [
                    _subItem(r, 'Create Tickets', () {
                      Navigator.of(context).pop();
                      c.openTicketPunch();
                    }),
                    _subItem(r, 'All Tickets', () {
                      Navigator.of(context).pop();
                      c.openAllTickets();
                    }),
                    _subItem(r, 'Open Tickets', () {
                      Navigator.of(context).pop();
                      c.openOpenTickets();
                    }),
                    _subItem(r, 'Closed Tickets', () {
                      Navigator.of(context).pop();
                      c.openClosedTickets();
                    }),
                  ],
                ),

                SizedBox(height: r.hp(1)),

                // Attendance expansion (re-uses your items)
                _roundedExpansionCard(
                  r,
                  leadingIcon: Icons.access_time,
                  iconBg: Colors.blue[50]!,
                  iconColor: Colors.blue,
                  title: 'Attendance',
                  children: [
                    _subItem(r, 'Attendance Check In / Check Out', () {
                      Navigator.of(context).pop();
                      c.openAttendanceCheck();
                    }),
                    _subItem(r, 'Tag Location', () {
                      Navigator.of(context).pop();
                      c.openTagLocation();
                    }),
                    _subItem(r, 'Leave Request', () {
                      Navigator.of(context).pop();
                      c.openLeaveRequestForm();
                    }),
                    _subItem(r, 'Leave Status', () {
                      Navigator.of(context).pop();
                      c.openLeaveApprovelScreen();
                    }),
                  ],
                ),

                SizedBox(height: r.hp(1)),

                // QR Scanner simple tile
                _roundedMenuCard(
                  r,
                  icon: Icons.qr_code_scanner,
                  iconBg: Colors.blue[50]!,
                  iconColor: Colors.blue,
                  title: 'QR Scanner',
                  onTap: () {
                    Navigator.of(context).pop();
                    c.openQRScanner();
                  },
                ),

                SizedBox(height: r.hp(2)),

                // ---------- ACCOUNT label
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    r.wp(5),
                    r.hp(1),
                    r.wp(3),
                    r.hp(1),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ACCOUNT',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: r.isTablet ? r.scaledFont(14) : 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: r.hp(0.6)),

                // Profile tile
                _roundedMenuCard(
                  r,
                  icon: Icons.person,
                  iconBg: Colors.grey[50]!,
                  iconColor: Colors.grey[800]!,
                  title: 'Profile',
                  onTap: () {
                    Navigator.of(context).pop();
                    c.openProfile();
                  },
                ),

                SizedBox(height: r.hp(1)),

                // Settings tile
                _roundedMenuCard(
                  r,
                  icon: Icons.settings,
                  iconBg: Colors.grey[50]!,
                  iconColor: Colors.grey[800]!,
                  title: 'Settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    c.openSettings();
                  },
                ),

                SizedBox(height: r.hp(2)),

                // Big Logout Card like screenshot
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    c.openLogout();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: r.hp(1.6)),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(r.wp(2)),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.red[700],
                            size: r.wp(5),
                          ),
                        ),
                        SizedBox(width: r.wp(3)),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: r.isTablet ? r.scaledFont(18) : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: r.hp(3)),
              ],
            ),
          ),

          // Footer version & copyright centered
          Padding(
            padding: EdgeInsets.only(bottom: r.hp(2)),
            child: Column(
              children: [
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: r.isTablet ? 14 : 12,
                  ),
                ),
                SizedBox(height: r.hp(0.4)),
                Text(
                  '© 2025 Trinetra Consulting',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: r.isTablet ? 13 : 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // small helpers to match screenshot style

  Widget _headerStat(R r, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: r.isTablet ? r.scaledFont(16) : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: r.hp(0.3)),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: r.isTablet ? 12 : 10,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider(R r) =>
      Container(width: 1, height: r.hp(4), color: Colors.white24);

  Widget _statusSmall(R r, bool active) {
    return Row(
      children: [
        Container(
          width: r.wp(2.6),
          height: r.wp(2.6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.green : Colors.red,
          ),
        ),
        SizedBox(width: r.wp(2)),
        Text(
          active ? 'Active' : 'Inactive',
          style: TextStyle(
            color: Colors.white70,
            fontSize: r.isTablet ? 14 : 12,
          ),
        ),
      ],
    );
  }

  Widget _roundedMenuCard(
    R r, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: r.wp(3), vertical: r.hp(1.4)),
        child: Row(
          children: [
            Container(
              width: r.wp(10),
              height: r.wp(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: r.wp(5)),
            ),
            SizedBox(width: r.wp(4)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: r.isTablet ? r.scaledFont(18) : 16),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _roundedExpansionCard(
    R r, {
    required IconData leadingIcon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            width: r.wp(10),
            height: r.wp(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(leadingIcon, color: iconColor, size: r.wp(5)),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: r.isTablet ? r.scaledFont(18) : 16),
          ),
          children: children,
        ),
      ),
    );
  }

  // sub item with small dot indicator
  Widget _subItem(R r, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: r.wp(6), vertical: r.hp(1.2)),
        child: Row(
          children: [
            Container(
              width: r.wp(2.8),
              height: r.wp(2.8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: r.wp(4)),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: r.isTablet ? r.scaledFont(16) : 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
