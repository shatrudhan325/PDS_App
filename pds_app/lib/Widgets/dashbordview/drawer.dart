// import 'package:flutter/material.dart';
// import 'package:pds_app/core/widgets/Location_Get&Finde_Mock/locationservice.dart';
// import 'package:pds_app/core/widgets/Ticket.dart';
// import 'package:pds_app/core/widgets/attendance.dart';
// import 'package:pds_app/core/widgets/QR/Scannerdart.dart';
// import 'package:get/get.dart';

// class MyDrawer extends StatelessWidget {
//   const MyDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Log whenever the drawer is built
//     // print('MyDrawer build called at ${DateTime.now()}');

//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           const DrawerHeader(
//             decoration: BoxDecoration(color: Colors.blue),
//             child: Text(
//               'Dashboard Menu',
//               style: TextStyle(color: Colors.white, fontSize: 30),
//             ),
//           ),
//           ListTile(
//             title: const Text('Ticket'),
//             onTap: () {
//               Get.to(() => const CreateTicketPage());
//             },
//           ),
//           ListTile(
//             title: const Text('Attendance'),
//             onTap: () {
//               Get.to(() => const AttendancePage());
//             },
//           ),
//           ListTile(
//             title: const Text('QR Scanner'),
//             onTap: () {
//               Get.to(() => const QRCodeScanner());
//             },
//           ),
//           ListTile(
//             title: const Text('Live Location'),
//             onTap: () {
//               Get.to(() => const LiveLocationWidget());
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';

// // import 'package:pds_app/core/widgets/Location_Get&Finde_Mock/locationservice.dart';
// import 'package:pds_app/Widgets/Ticket.dart';
// // import 'package:pds_app/core/widgets/attendance.dart';
// import 'package:pds_app/Widgets/QR/Scannerdart.dart';
// // import 'package:pds_app/core/widgets/QR/Scannerdart.dart';
// // import 'package:pds_app/features/authentication/screens/login.dart';
// // import 'package:pds_app/features/authentication/services/auth.dart';

// class MyDrawer extends StatelessWidget {
//   const MyDrawer({super.key});
//   //Updated Code
//   // Future<void> logout() async {
//   //   await AuthService.logout();
//   //   Get.offAll(() => const LoginPage());
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           const UserAccountsDrawerHeader(
//             accountName: Text(
//               "Dashboard Menu",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             accountEmail: Text("Welcome to your panel"),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(Icons.dashboard, size: 40, color: Colors.blue),
//             ),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue, Colors.lightBlueAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           _buildDrawerItem(
//             icon: Icons.confirmation_number,
//             text: "Ticket Punch",
//             onTap: () => Get.to(() => CreateTicketPage()),
//           ),
//           _buildDrawerItem(
//             icon: Icons.access_time,
//             text: "Attendance",
//             onTap: () => Get.to(() => AttendanceTrackingScreen()),
//           ),
//           _buildDrawerItem(
//             icon: Icons.qr_code_scanner,
//             text: "QR Scanner",
//             onTap: () => Get.to(() => QRCodeScanner()),
//           ),
//           const Spacer(),
//           _buildDrawerItem(
//             icon: Icons.settings,
//             text: "Setting",
//             onTap: () {
//               Get.changeTheme(
//                 Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
//               );
//             },
//           ),
//           _buildDrawerItem(icon: Icons.logout, text: "Logout", onTap: () {}),
//         ],
//       ),
//     );
//   }

//   /// Custom reusable drawer item
//   Widget _buildDrawerItem({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.blue),
//       title: Text(text, style: const TextStyle(fontSize: 16)),
//       onTap: onTap,
//     );
//   }
// }

//Fully responsive code

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';
import 'package:pds_app/Widgets/Ticket.dart';
import 'package:pds_app/Widgets/QR/Scannerdart.dart';
import 'package:pds_app/features/authentication/screens/login.dart';

/// Controller for Drawer state/actions
class DrawerControllerX extends GetxController {
  final title = 'Dashboard Menu'.obs;
  final subtitle = 'Welcome to your panel'.obs;
  final bgImagePath = 'assets/images/trinetra web logo.png'.obs;
  // store the asset path as a String

  /// Theme toggle (example)
  void toggleTheme() {
    Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
  }

  /// Navigation helpers (wrap Get.to so tests/mocks are easier later)
  void openTicketPunch() => Get.to(() => CreateTicketPage());
  void openAttendance() => Get.to(() => AttendanceTrackingScreen());
  void openQRScanner() => Get.to(() => QRCodeScanner());
  void openLogout() => Get.to(() => LoginPage());
  // Future<void> logout() async {
  //   // If you have an AuthService implementation, add its import at the top
  //   // and uncomment the following line to perform the logout action:
  //   // await AuthService.logout();

  //   // Use a named route to avoid referencing a LoginPage widget class that may not exist.
  //   // Ensure your app has a '/login' route defined in GetMaterialApp routes.
  //   Get.offAllNamed('/login');
  // }
}

/// Responsive helpers
class R {
  final double w;
  final double h;
  R._(this.w, this.h);

  factory R.of() {
    return R._(Get.width, Get.height);
  }

  double wp(double percent) => w * percent / 100; // width percentage
  double hp(double percent) => h * percent / 100; // height percentage

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
          // Responsive header
          Obx(() {
            final bg = c.bgImagePath.value;
            final title = c.title.value;
            final subtitle = c.subtitle.value;

            // header heights: tablet bigger
            final headerHeight = r.isTablet ? r.hp(30) : r.hp(20);
            final avatarRadius = r.isTablet
                ? r.wp(8)
                : r.wp(10); // avatar scales with width

            return SizedBox(
              width: double.infinity,
              height: headerHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  if (bg.isNotEmpty)
                    Image.asset(bg, fit: BoxFit.cover)
                  else
                    Container(color: Colors.blueAccent),

                  // Dark overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.black.withOpacity(0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Content (avatar + texts)
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.wp(4),
                        vertical: r.hp(1.4),
                      ),
                      child: r.isTablet
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.dashboard,
                                    size: avatarRadius,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(width: r.wp(3)),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: r.scaledFont(22),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: r.hp(0.6)),
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: r.scaledFont(14),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Optional quick-action/icon (only on tablet)
                                IconButton(
                                  onPressed: () {
                                    // Example: open profile or settings
                                  },
                                  icon: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: avatarRadius,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.dashboard,
                                        size: avatarRadius,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(width: r.wp(3)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: r.scaledFont(18),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: r.hp(0.5)),
                                          Text(
                                            subtitle,
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
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Drawer items - spacing/padding responsive
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildResponsiveTile(
                  icon: Icons.confirmation_number,
                  text: 'Ticket Punch',
                  onTap: () {
                    Navigator.of(context).pop(); // close drawer
                    c.openTicketPunch();
                  },
                ),
                _buildResponsiveTile(
                  icon: Icons.access_time,
                  text: 'Attendance',
                  onTap: () {
                    Navigator.of(context).pop();
                    c.openAttendance();
                  },
                ),
                _buildResponsiveTile(
                  icon: Icons.qr_code_scanner,
                  text: 'QR Scanner',
                  onTap: () {
                    Navigator.of(context).pop();
                    c.openQRScanner();
                  },
                ),
              ],
            ),
          ),

          // Bottom actions (Setting, Logout) pinned to bottom
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: r.wp(3),
              vertical: r.hp(1.6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 1),
                SizedBox(height: r.hp(1)),
                Row(
                  children: [
                    Expanded(
                      child: _buildResponsiveTile(
                        icon: Icons.settings,
                        text: 'Setting',
                        onTap: () {
                          Navigator.of(context).pop();
                          c.toggleTheme();
                        },
                      ),
                    ),
                    SizedBox(width: r.wp(2)),
                    Expanded(
                      child: _buildResponsiveTile(
                        icon: Icons.logout,
                        text: 'Logout',
                        onTap: () {
                          // Navigator.of(context).pop();
                          //c.logout();
                          Get.to(() => LoginPage());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final r = R.of();
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: r.wp(4),
        vertical: r.hp(0.6),
      ),
      leading: Icon(
        icon,
        color: Colors.blue,
        size: r.isTablet ? r.wp(5) : r.wp(6.2),
      ),
      title: Text(text, style: TextStyle(fontSize: r.isTablet ? 18 : 16)),
      onTap: onTap,
    );
  }
}
