// // // attendance_api_service.dart
// // import 'dart:convert';
// // import 'package:flutter/foundation.dart';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';
// // import 'package:pds_app/core/Services/token_store.dart';

// // class AttendanceApiService {
// //   static const String apiUrl =
// //       'http://192.168.29.202:8080/v1/m/attendance/setlocationtag';
// //   // If you need the token at class level, store the Future and await it inside async methods.
// //   final Future<String?> authTokenFuture = TokenStorage.getToken();

// //   Future<bool> sendAttendanceToBackend({
// //     required String action,
// //     required AttendanceLocationData location,
// //     required String? androidId,
// //     required String? authToken,
// //   }) async {
// //     final payload = <String, dynamic>{
// //       'myLatitude': location.latitude.toPrecision(5),
// //       'myLongitude': location.longitude.toPrecision(5),
// //       'isMock': location.isMock.toString(),
// //       'address': location.address,
// //       'accuracy': location.accuracy.toPrecision(2),
// //       'buildNumber': androidId,
// //       'type': '',
// //     };

// //     debugPrint('Sending attendance payload: $payload');

// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $authToken',
// //         },
// //         body: jsonEncode(payload),
// //       );

// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         debugPrint('Attendance saved successfully');
// //         return true;
// //       } else {
// //         debugPrint(
// //           'Attendance API failed: ${response.statusCode} ${response.body}',
// //         );
// //         // You might want to throw an exception or return false and handle the snackbar in the controller
// //         return false;
// //       }
// //     } catch (e) {
// //       debugPrint('Attendance API error: $e');
// //       return false;
// //     }
// //   }
// // }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';
// import 'package:pds_app/core/Services/Android_id_get.dart';
// import 'package:pds_app/core/Services/token_store.dart';
// import 'package:pds_app/Widgets/Location_Get&Finde_Mock/attandenceLocation.dart';

// class LocationService {
//   static const String _apiUrl =
//       'http://192.168.29.202:8080/v1/m/attendance/setlocationtag';

//   Future<bool> sendLocationTag({
//     required String myLatitude,
//     required String myLongitude,
//     required String isMock,
//     required String address,
//     required String accuracy,
//     required String buildNumber,
//     String type = '',
//   }) async {
//     final String? authToken = await TokenStorage.getToken();
//     final String? androidId = await DeviceInfoService.getAndroidId();

//     final Map<String, dynamic> data = {
//       'myLatitude': myLatitude,
//       'myLongitude': myLongitude,
//       'isMock': isMock,
//       'address': address,
//       'accuracy': accuracy,
//       'buildNumber': androidId,
//       'type': '',
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(_apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode(data),
//       );
//       if (response.statusCode == 200) {
//         print('Location tag sent successfully!');
//         print('Response body: ${response.body}');
//         return true;
//       } else {
//         print(
//           'Failed to send location tag. Status code: ${response.statusCode}',
//         );
//         print('Response body: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('An error occurred during the API call: $e');
//       return false;
//     }
//   }
// }

// class AttendanceTaggingScreen extends StatefulWidget {
//   const AttendanceTaggingScreen({super.key});

//   @override
//   State<AttendanceTaggingScreen> createState() =>
//       _AttendanceTaggingScreenState();
// }

// class _AttendanceTaggingScreenState extends State<AttendanceTaggingScreen> {
//   final LocationService _locationService = LocationService();
//   String _statusMessage = 'Ready to tag location.';
//   bool _isLoading = false;

//   /// Handles the process of getting location and sending it to the API.
//   Future<void> _tagLocation() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Fetching current location...';
//     });

//     try {
//       // 1. Get location data
//       final location = await LiveLocationWidgets(
//         onLocationUpdate: AttendanceLocationData(longitude: double),
//       );

//       setState(() {
//         _statusMessage = 'Location found. Sending data to API...';
//       });

//       final myLatitude = location.latitude.toStringAsFixed(5);
//       final myLongitude = location.longitude.toStringAsFixed(5);
//       final isMock = location.isMock.toString();
//       final address = location.address;
//       final accuracy = location.accuracy.toStringAsFixed(2);
//       const buildNumberPlaceholder = '';

//       // 3. Send data
//       final success = await _locationService.sendLocationTag(
//         myLatitude: myLatitude,
//         myLongitude: myLongitude,
//         isMock: isMock,
//         address: address,
//         accuracy: accuracy,
//         buildNumber: buildNumberPlaceholder,
//         type: '',
//       );

//       // 4. Update UI based on API result
//       setState(() {
//         _isLoading = false;
//         _statusMessage = success
//             ? 'Success: Location Tagged at $address!'
//             : 'Error: Failed to tag location. Check console for details.';
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _statusMessage =
//             'Fatal Error: Could not retrieve location or process request.';
//       });
//       print('Error during _tagLocation: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance Location Tagger'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               // Status Message Display
//               Text(
//                 _statusMessage,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: _statusMessage.startsWith('Success')
//                       ? Colors.green.shade700
//                       : _statusMessage.startsWith('Error') ||
//                             _statusMessage.startsWith('Fatal')
//                       ? Colors.red.shade700
//                       : _isLoading
//                       ? Colors.blue.shade700
//                       : Colors.black54,
//                   fontWeight: _isLoading ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               // The Tag Location Button
//               ElevatedButton.icon(
//                 onPressed: _isLoading ? null : _tagLocation,
//                 icon: _isLoading
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : const Icon(Icons.location_on),
//                 label: Text(
//                   _isLoading ? 'Processing...' : 'TAG LOCATION',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 60),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 5,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Information about location fetching
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   'Press the button to capture your current GPS location and send the attendance tag to the server.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
