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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';

// import 'package:pds_app/core/widgets/Location_Get&Finde_Mock/locationservice.dart';
import 'package:pds_app/Widgets/Ticket.dart';
// import 'package:pds_app/core/widgets/attendance.dart';
import 'package:pds_app/Widgets/QR/Scannerdart.dart';
// import 'package:pds_app/core/widgets/QR/Scannerdart.dart';
// import 'package:pds_app/features/authentication/screens/login.dart';
// import 'package:pds_app/features/authentication/services/auth.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
  //Updated Code
  // Future<void> logout() async {
  //   await AuthService.logout();
  //   Get.offAll(() => const LoginPage());
  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text(
              "Dashboard Menu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text("Welcome to your panel"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.dashboard, size: 40, color: Colors.blue),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Ticket Page
          // Ticket Page
          _buildDrawerItem(
            icon: Icons.confirmation_number,
            text: "Ticket Punch",
            onTap: () => Get.to(() => const CreateTicketPage()),
          ),
          _buildDrawerItem(
            icon: Icons.access_time,
            text: "Attendance",
            onTap: () => Get.to(() => AttendanceTrackingScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.qr_code_scanner,
            text: "QR Scanner",
            onTap: () => Get.to(() => QRCodeScanner()),
          ),
          // _buildDrawerItem(
          //   icon: Icons.location_on,
          //   text: "Live Location",
          //   onTap: () => Get.to(() => LiveLocationWidget()),
          // ),
          const Spacer(),
          _buildDrawerItem(icon: Icons.logout, text: "Logout", onTap: () {}),
        ],
      ),
    );
  }

  /// Custom reusable drawer item
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
