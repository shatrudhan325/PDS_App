import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pds_app/features/authentication/screens/login.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request all permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.phone, // For SIM card details on Android
    ].request();

    // Check the status of each permission
    if (statuses[Permission.locationWhenInUse]!.isGranted &&
        statuses[Permission.camera]!.isGranted &&
        statuses[Permission.phone]!.isGranted) {
      _navigateToLoginPage();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _navigateToLoginPage() {
    Get.to(() => const LoginPage());
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text('Please grant all permissions to use the app.'),
        actions: [
          TextButton(
            onPressed: () {
              // Opens the app's settings page
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Requesting permissions...'),
          ],
        ),
      ),
    );
  }
}

// // Dummy Login Page for demonstration
// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login Page')),
//       body: const Center(child: Text('This is the Login Page')),
//     );
//   }
// }
