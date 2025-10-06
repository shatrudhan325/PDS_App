//This code is currently not in use, but may be used in future for better code management

import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pds_app/Widgets/Location_Get&Finde_Mock/locationservice.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Page')),
      body: Column(
        children: [
          Expanded(child: LiveLocationWidget()),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(33, 76, 106, 102),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: ToggleSwitch(
                  minWidth: 90.0,
                  minHeight: 70.0,
                  initialLabelIndex: 0,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  totalSwitches: 2,
                  labels: const ['Check In', 'Check Out'],
                  fontSize: 16.0,
                  iconSize: 30.0,
                  activeBgColors: [
                    [
                      const Color.fromARGB(115, 3, 248, 28),
                      const Color.fromARGB(66, 8, 156, 164),
                    ],
                    [const Color.fromARGB(255, 221, 51, 8), Colors.orange],
                  ],
                  curve: Curves.bounceInOut,
                  onToggle: (index) async {
                    // handle toggle and mark attendance
                    // print('switched to: $index');
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
                    try {
                      Position position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      );
                      if (position.isMocked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Fake location detected! Attendance not marked.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Real location. Attendance marked successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error getting location: $e')),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
