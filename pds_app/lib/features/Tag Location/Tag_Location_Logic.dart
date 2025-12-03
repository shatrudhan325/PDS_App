// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:http/http.dart' as http;
// import 'package:pds_app/core/Services/token_store.dart';
// import 'package:pds_app/features/Tag Location/sending_payload_backend.dart';
// import 'package:pds_app/Widgets/Attandence/TestClass.dart';

// class TagLocationPage extends StatefulWidget {
//   const TagLocationPage({super.key});

//   @override
//   State<TagLocationPage> createState() => _TagLocationPageState();
// }

// class _TagLocationPageState extends State<TagLocationPage> {
//   final String baseUrl =
//       "http://192.168.29.202:8080/v1/m/attendance/getlocationtaginfo";

//   bool loading = true;

//   double? targetLat;
//   double? targetLng;
//   bool userTagged = false;
//   bool approved = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchTagInfo();
//   }

//   Future<void> fetchTagInfo() async {
//     setState(() {
//       loading = true;
//     });
//     final String? authToken = await TokenStorage.getToken();

//     try {
//       final response = await http.get(
//         Uri.parse(baseUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         },
//       );

//       print(response.statusCode);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           targetLat = (data["taggedLatitude"] as num?)?.toDouble();
//           targetLng = (data["taggedLongitude"] as num?)?.toDouble();
//           approved = data["approved"] ?? false;
//           userTagged = data["tagged"] ?? false;
//         });
//       } else {
//         setState(() => loading = false);
//       }
//     } catch (e) {
//       print(e);
//       setState(() => loading = false);
//     } finally {
//       setState(() => loading = false);
//     }
//   }

//   void tagLocation() {
//     if (approved) return;

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("Location Tagged")));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Tag Location")),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Center(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Location",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),

//                   Container(
//                     margin: const EdgeInsets.all(20),
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         const Icon(
//                           Icons.location_on,
//                           size: 40,
//                           color: Color.fromARGB(255, 36, 35, 92),
//                         ),
//                         const SizedBox(height: 10),

//                         const Text(
//                           "Your Office Location",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(height: 15),

//                         Text("targgedLatitude: $targetLat"),
//                         Text("targgedLongitude: $targetLng"),
//                         Text("tagged: ${userTagged ? "True" : "False"}"),
//                         Text(
//                           "approved: ${approved ? "True" : "False"}",
//                           style: TextStyle(
//                             color: approved ? Colors.green : Colors.orange,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   ElevatedButton(
//                     onPressed: () {
//                       Get.to(() => {});
//                     },

//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue.shade900,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 40,
//                         vertical: 14,
//                       ),
//                     ),
//                     child: Text(
//                       approved ? "Already Approved" : "Tag Location",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Color.fromRGBO(255, 255, 255, 0.931),
//                       ),
//                     ),
//                   ),

//                   // ElevatedButton(
//                   //   onPressed: () => Get.to(() => AttendanceService()),
//                   //   child: const Text('Send Data'),
//                   // ),
//                   const SizedBox(height: 20),
//                   // ElevatedButton(
//                   //   onPressed: fetchTagInfo,
//                   //   child: const Text("Refresh Status"),
//                   // ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// // //Updated Code

// tag_location_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:pds_app/core/Services/Android_id_get.dart';
import 'package:pds_app/core/apiConfig/config.dart';

// Import your project-specific token storage (adjust path).
import 'package:pds_app/core/Services/token_store.dart';

/// Replace this with your actual backend endpoint if different
const String _setLocationTagUrl =
    // 'http://192.168.29.202:8080/v1/m/attendance/setlocationtag';
    '${ApiConfig.baseUrl}/attendance/setlocationtag';

const String baseUrl1 =
    // 'http://192.168.29.202:8080/v1/m/attendance/getlocationtaginfo';
    '${ApiConfig.baseUrl}/attendance/getlocationtaginfo';

/// Simple data holder you can adapt to your project types
class AttendanceLocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isMock;
  final String address;

  AttendanceLocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMock,
    required this.address,
  });
}

/// Helper to fetch Android ID (device_info_plus)
// class DeviceInfoService {
//   static Future<String?> getAndroidId() async {
//     try {
//       final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//       final info = await deviceInfoPlugin.deviceInfo;
//       // On Android, cast to AndroidDeviceInfo and fetch androidId
//       if (info is AndroidDeviceInfo) {
//         return info.androidId; // may be null on some devices
//       }
//       // For iOS or others, return null or some fallback
//       return null;
//     } catch (e) {
//       debugPrint('DeviceInfoService error: $e');
//       return null;
//     }
//   }
// }

/// Service that sends the location payload to your backend
class LocationService {
  final String apiUrl;

  LocationService({this.apiUrl = _setLocationTagUrl});

  Future<bool> sendLocationTag({
    required String myLatitude,
    required String myLongitude,
    required String isMock,
    required String address,
    required String accuracy,
    required String buildNumber,
    String type = '',
  }) async {
    final String? authToken = await TokenStorage.getToken();
    final String? androidId = await DeviceInfoService.getAndroidId();

    final Map<String, dynamic> data = {
      'myLatitude': myLatitude,
      'myLongitude': myLongitude,
      'isMock': isMock,
      'address': address,
      'accuracy': accuracy,
      'buildNumber': androidId,
      'type': type,
    };

    print(data);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(data),
      );

      debugPrint('LocationService response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('LocationService error: $e');
      return false;
    }
  }
}

/// The main screen widget — drop-in replacement for your TagLocationPage button flow
class TagLocationPage extends StatefulWidget {
  const TagLocationPage({Key? key}) : super(key: key);

  @override
  State<TagLocationPage> createState() => _TagLocationPageState();
}

class _TagLocationPageState extends State<TagLocationPage> {
  final LocationService _locationService = LocationService();

  // Which is to be sent as Payload to Backend for Tagging
  bool _isLoading = false;
  String _statusMessage = 'Ready to tag location';
  double? targetLat;
  double? targetLng;
  bool userTagged = false;
  bool approved = false;

  // State to Show to the UI after fetching Tag Info
  bool loading = false;
  double? targetLatitude;
  double? targetLongitude;
  // bool userTagged = false;
  // bool approved = false;

  @override
  void initState() {
    super.initState();
    // Optionally load initial tag info from your API
    fetchTagInfo();
  }

  // --- Location helpers ---
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them from settings.',
      );
    }

    // You can choose desired accuracy
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final List<Placemark> places = await placemarkFromCoordinates(lat, lng);
      if (places.isEmpty) return '';
      final p = places.first;
      final parts = [
        if ((p.name ?? '').isNotEmpty) p.name,
        if ((p.street ?? '').isNotEmpty) p.street,
        if ((p.locality ?? '').isNotEmpty) p.locality,
        if ((p.postalCode ?? '').isNotEmpty) p.postalCode,
        if ((p.country ?? '').isNotEmpty) p.country,
      ];
      return parts.join(', ');
    } catch (e) {
      debugPrint('Reverse geocode failed: $e');
      return '';
    }
  }

  Future<AttendanceLocationData> _getCurrentAttendanceLocation() async {
    final Position pos = await _determinePosition();

    // geolocator's Position has isMocked property (if available). Use safe fallback.
    bool isMocked = false;
    try {
      // Some versions of geolocator expose isMocked
      // Use dynamic access to avoid compile problems on older versions:
      final dynamic dp = pos;
      if (dp != null && dp.isMocked != null) {
        isMocked = dp.isMocked as bool;
      }
    } catch (_) {
      isMocked = false;
    }

    final address = await _reverseGeocode(pos.latitude, pos.longitude);

    return AttendanceLocationData(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      isMock: isMocked,
      address: address,
    );
  }

  // UI Update waala FetchCall
  Future<void> fetchTagInfo() async {
    print('fetch Tag info called');
    setState(() {
      loading = true;
    });
    final String? authToken = await TokenStorage.getToken();

    try {
      final response = await http.get(
        Uri.parse(baseUrl1),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        setState(() {
          targetLatitude = (data["taggedLatitude"] as num?)?.toDouble();
          targetLongitude = (data["taggedLongitude"] as num?)?.toDouble();
          approved = data["approved"] ?? false;
          userTagged = data["tagged"] ?? false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print(e);
      setState(() => loading = false);
    } finally {
      setState(() => loading = false);
    }
  }

  // --- Main tagging flow ---
  Future<void> _tagLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching location...';
    });

    try {
      final AttendanceLocationData loc = await _getCurrentAttendanceLocation();

      setState(() {
        _statusMessage = 'Sending location to server...';
      });

      final androidId = await DeviceInfoService.getAndroidId() ?? '';

      final success = await _locationService.sendLocationTag(
        myLatitude: loc.latitude.toStringAsFixed(5),
        myLongitude: loc.longitude.toStringAsFixed(5),
        isMock: loc.isMock.toString(),
        address: loc.address,
        accuracy: loc.accuracy.toStringAsFixed(2),
        buildNumber: androidId,
        type: '',
      );

      setState(() {
        _isLoading = false;
        _statusMessage = success
            ? 'Success — location tagged: ${loc.address.isNotEmpty ? loc.address : "${loc.latitude}, ${loc.longitude}"}'
            : 'Failed to tag location (see console for details).';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Location tagged successfully' : 'Failed to tag location',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        // update UI state maybe to show user has tagged
        setState(() {
          userTagged = true;
          targetLat = loc.latitude;
          targetLng = loc.longitude;
          // Optionally set approved = true if API says so (you can fetchTagInfo)
        });
      }
    } catch (e) {
      debugPrint('Tagging error: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Optional: replace Get.to navigation; you previously had Get in project
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tag Location')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Text('Status: $_statusMessage', textAlign: TextAlign.center),
              // const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(60),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Color.fromARGB(255, 6, 52, 89),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Office Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Target Latitude: $targetLatitude"),
                    SizedBox(height: 6),
                    Text("TargetLongitude: $targetLongitude"),
                    SizedBox(height: 6),
                    Text('Tagged: ${userTagged ? "True" : "False"}'),
                    SizedBox(height: 6),
                    Text(
                      'Approved: ${approved ? "True" : "False"}',

                      style: TextStyle(
                        color: approved ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _tagLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 41, 99),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Tagging...', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : Text(
                        approved ? 'Already Approved' : 'Tag Location',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(249, 248, 248, 1),
                        ),
                      ),
              ),

              Text('Status: $_statusMessage', textAlign: TextAlign.center),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}





// //Not Tested But Improved UI.
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// // import 'package:device_info_plus/device_info_plus.dart';
// import 'package:http/http.dart' as http;
// import 'package:pds_app/core/Services/Android_id_get.dart';

// // Import your project-specific token storage (adjust path).
// import 'package:pds_app/core/Services/token_store.dart';

// /// Replace this with your actual backend endpoint if different
// const String _setLocationTagUrl =
//     'http://192.168.29.202:8080/v1/m/attendance/setlocationtag';

// const String baseUrl =
//     'http://192.168.29.202:8080/v1/m/attendance/getlocationtaginfo';

// /// Simple data holder you can adapt to your project types
// class AttendanceLocationData {
//   final double latitude;
//   final double longitude;
//   final double accuracy;
//   final bool isMock;
//   final String address;

//   AttendanceLocationData({
//     required this.latitude,
//     required this.longitude,
//     required this.accuracy,
//     required this.isMock,
//     required this.address,
//   });
// }

// // --- Keeping your existing Service classes intact ---
// // (DeviceInfoService and LocationService code remains exactly as you provided)
// // ... [Your existing DeviceInfoService placeholder] ...

// /// Service that sends the location payload to your backend
// class LocationService {
//   final String apiUrl;

//   LocationService({this.apiUrl = _setLocationTagUrl});

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
//       'type': type,
//     };

//     print(data);

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           if (authToken != null) 'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode(data),
//       );

//       debugPrint('LocationService response: ${response.statusCode}');
//       debugPrint('Response body: ${response.body}');

//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       debugPrint('LocationService error: $e');
//       return false;
//     }
//   }
// }

// /// The main screen widget
// class TagLocationPage extends StatefulWidget {
//   const TagLocationPage({Key? key}) : super(key: key);

//   @override
//   State<TagLocationPage> createState() => _TagLocationPageState();
// }

// class _TagLocationPageState extends State<TagLocationPage> {
//   final LocationService _locationService = LocationService();

//   // --- YOUR EXISTING STATE VARIABLES (LOGIC REMAINS UNCHANGED) ---
//   // Which is to be sent as Payload to Backend for Tagging
//   bool _isLoading = false;
//   String _statusMessage = 'Ready to tag location';
//   double? targetLat;
//   double? targetLng;
//   bool userTagged = false;
//   bool approved = false;

//   // State to Show to the UI after fetching Tag Info
//   bool loading = false;
//   double? targetLatitude;
//   double? targetLongitude;

//   // UI Colors
//   final Color primaryBlue = const Color(0xFF0D3B66);
//   final Color disabledBlue = const Color(0xFF7F97AC);
//   final Color statusGreen = Colors.green;
//   final Color backgroundColor = const Color(0xFFF5F7F9);

//   @override
//   void initState() {
//     super.initState();
//     // Optionally load initial tag info from your API
//     fetchTagInfo();
//   }

//   // --- YOUR EXISTING LOGIC METHODS (REMAIN UNCHANGED) ---
//   Future<Position> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled.');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       throw Exception(
//         'Location permissions are permanently denied. Please enable them from settings.',
//       );
//     }

//     // You can choose desired accuracy
//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.best,
//     );
//   }

//   Future<String> _reverseGeocode(double lat, double lng) async {
//     try {
//       final List<Placemark> places = await placemarkFromCoordinates(lat, lng);
//       if (places.isEmpty) return '';
//       final p = places.first;
//       final parts = [
//         if ((p.name ?? '').isNotEmpty) p.name,
//         if ((p.street ?? '').isNotEmpty) p.street,
//         if ((p.locality ?? '').isNotEmpty) p.locality,
//         if ((p.postalCode ?? '').isNotEmpty) p.postalCode,
//         if ((p.country ?? '').isNotEmpty) p.country,
//       ];
//       return parts.join(', ');
//     } catch (e) {
//       debugPrint('Reverse geocode failed: $e');
//       return '';
//     }
//   }

//   Future<AttendanceLocationData> _getCurrentAttendanceLocation() async {
//     final Position pos = await _determinePosition();

//     bool isMocked = false;
//     try {
//       final dynamic dp = pos;
//       if (dp != null && dp.isMocked != null) {
//         isMocked = dp.isMocked as bool;
//       }
//     } catch (_) {
//       isMocked = false;
//     }

//     final address = await _reverseGeocode(pos.latitude, pos.longitude);

//     return AttendanceLocationData(
//       latitude: pos.latitude,
//       longitude: pos.longitude,
//       accuracy: pos.accuracy,
//       isMock: isMocked,
//       address: address,
//     );
//   }

//   // UI Update waala FetchCall
//   Future<void> fetchTagInfo() async {
//     print('fetch Tag info called');
//     setState(() {
//       loading = true;
//     });
//     final String? authToken = await TokenStorage.getToken();

//     try {
//       final response = await http.get(
//         Uri.parse(baseUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print(data);

//         setState(() {
//           targetLatitude = (data["taggedLatitude"] as num?)?.toDouble();
//           targetLongitude = (data["taggedLongitude"] as num?)?.toDouble();
//           approved = data["approved"] ?? false;
//           userTagged = data["tagged"] ?? false;
//         });
//       } else {
//         setState(() => loading = false);
//       }
//     } catch (e) {
//       print(e);
//       setState(() => loading = false);
//     } finally {
//       setState(() => loading = false);
//     }
//   }

//   // --- Main tagging flow ---
//   Future<void> _tagLocation() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Fetching location...';
//     });

//     try {
//       final AttendanceLocationData loc = await _getCurrentAttendanceLocation();

//       setState(() {
//         _statusMessage = 'Sending location to server...';
//       });

//       final androidId = await DeviceInfoService.getAndroidId() ?? '';

//       final success = await _locationService.sendLocationTag(
//         myLatitude: loc.latitude.toStringAsFixed(5),
//         myLongitude: loc.longitude.toStringAsFixed(5),
//         isMock: loc.isMock.toString(),
//         address: loc.address,
//         accuracy: loc.accuracy.toStringAsFixed(2),
//         buildNumber: androidId,
//         type: '',
//       );

//       setState(() {
//         _isLoading = false;
//         _statusMessage = success
//             ? 'Success — location tagged.'
//             : 'Failed to tag location (see console for details).';
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             success ? 'Location tagged successfully' : 'Failed to tag location',
//           ),
//           backgroundColor: success ? Colors.green : Colors.red,
//         ),
//       );

//       if (success) {
//         // update UI state maybe to show user has tagged
//         setState(() {
//           userTagged = true;
//           targetLat = loc.latitude;
//           targetLng = loc.longitude;
//           // We re-fetch info to get updated approved status if backend sets it immediately
//           fetchTagInfo();
//         });
//       }
//     } catch (e) {
//       debugPrint('Tagging error: $e');
//       setState(() {
//         _isLoading = false;
//         _statusMessage = 'Error: $e';
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // ==========================================
//   // NEW UI BUILD METHOD STARTS HERE
//   // ==========================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Tag Location',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//       ),
//       body: loading
//           ? Center(child: CircularProgressIndicator(color: primaryBlue))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 children: [
//                   // 1. The Main Info Card
//                   _buildLocationCard(),
//                   const SizedBox(height: 30),

//                   // 2. The Action Button (Handles Approved/Loading/Ready states)
//                   _buildActionButton(),
//                   const SizedBox(height: 16),

//                   // 3. The Bottom Status Message
//                   _buildStatusMessage(),
//                 ],
//               ),
//             ),
//     );
//   }

//   // --- Helper Widgets for the new UI ---

//   Widget _buildLocationCard() {
//     return Card(
//       elevation: 4,
//       shadowColor: Colors.black26,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       child: Column(
//         children: [
//           // 1.1 Map Placeholder Image
//           ClipRRect(
//             borderRadius:
//                 const BorderRadius.vertical(top: Radius.circular(16.0)),
//             child: Container(
//               height: 140,
//               width: double.infinity,
//               color: Colors.grey[200],
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Faking a map pattern
//                   Opacity(
//                     opacity: 0.1,
//                      // Using a network image as placeholder pattern.
//                      // If offline, it will just show grey background.
//                     child: Image.network(
//                       'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Sample_Map.png/640px-Sample_Map.png',
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       errorBuilder: (context, error, stackTrace) =>
//                           const SizedBox(),
//                     ),
//                   ),
//                   Icon(Icons.location_on, color: primaryBlue, size: 48),
//                 ],
//               ),
//             ),
//           ),

//           // 1.2 Card Content using your state variables
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 const Text(
//                   'Office Location',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),

//                 // Latitude & Longitude Rows using your state variables
//                 _buildCoordinateRow(
//                     'Latitude', targetLatitude?.toString() ?? 'N/A'),
//                 const SizedBox(height: 8),
//                 _buildCoordinateRow(
//                     'Longitude', targetLongitude?.toString() ?? 'N/A'),

//                 const SizedBox(height: 16),
//                 const Divider(thickness: 1),
//                 const SizedBox(height: 8),

//                 // Checkbox Status Rows using your state variables
//                 _buildStatusCheckbox('Tagged', userTagged),
//                 const SizedBox(height: 4),
//                 _buildStatusCheckbox('Approved', approved),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCoordinateRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[700]),
//         const SizedBox(width: 6),
//         Text('$label: ',
//             style: TextStyle(fontSize: 15, color: Colors.grey[800])),
//         Text(value,
//             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   Widget _buildStatusCheckbox(String label, bool isChecked) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           isChecked ? Icons.check_box : Icons.check_box_outline_blank,
//           color: isChecked ? statusGreen : Colors.grey,
//           size: 22,
//         ),
//         const SizedBox(width: 8),
//         Text(label,
//             style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
//                 color: isChecked ? Colors.black : Colors.grey)),
//       ],
//     );
//   }

//   Widget _buildActionButton() {
//     // If already approved, show disabled button
//     if (approved) {
//       return SizedBox(
//         width: double.infinity,
//         height: 50,
//         child: ElevatedButton(
//           onPressed: null,
//           style: ElevatedButton.styleFrom(
//             disabledBackgroundColor: disabledBlue,
//             disabledForegroundColor: Colors.white.withOpacity(0.9),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(25),
//             ),
//             elevation: 0,
//           ),
//           child: const Text('Already Approved',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         ),
//       );
//     }

//     // Otherwise show Tag button (loading or ready state)
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _tagLocation,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryBlue,
//           disabledBackgroundColor: primaryBlue.withOpacity(0.7),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(25),
//           ),
//           elevation: 2,
//         ),
//         child: _isLoading
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                         strokeWidth: 2, color: Colors.white),
//                   ),
//                   SizedBox(width: 12),
//                   Text('Tagging...',
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white)),
//                 ],
//               )
//             : const Text('Tag Location',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white)),
//       ),
//     );
//   }

//   Widget _buildStatusMessage() {
//     // Only show status if it's not the default message and not currently loading
//     if (_statusMessage == 'Ready to tag location' && !_isLoading) {
//       return const SizedBox.shrink();
//     }

//     bool isError = _statusMessage.toLowerCase().contains('error') ||
//         _statusMessage.toLowerCase().contains('failed');
//     bool isSuccess = _statusMessage.toLowerCase().contains('success');

//     Color messageColor = Colors.grey.shade700;
//     IconData messageIcon = Icons.info_outline;

//     if (isError) {
//       messageColor = Colors.redAccent;
//       messageIcon = Icons.error_outline;
//     } else if (isSuccess) {
//       messageColor = statusGreen;
//       messageIcon = Icons.check_circle_outline;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         color: messageColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(messageIcon, color: messageColor, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               _statusMessage,
//               style: TextStyle(
//                   color: messageColor,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }