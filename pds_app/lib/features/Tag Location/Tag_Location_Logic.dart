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

// // tag_location_page.dart this code is tested .
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:pds_app/core/Services/Android_id_get.dart';
// import 'package:pds_app/core/apiConfig/config.dart';
// import 'package:pds_app/core/Services/token_store.dart';

// const String _setLocationTagUrl =
//     // 'http://192.168.29.202:8080/v1/m/attendance/setlocationtag';
//     '${ApiConfig.baseUrl}/attendance/setlocationtag';

// const String baseUrl1 =
//     // 'http://192.168.29.202:8080/v1/m/attendance/getlocationtaginfo';
//     '${ApiConfig.baseUrl}/attendance/getlocationtaginfo';

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

// class TagLocationPage extends StatefulWidget {
//   const TagLocationPage({Key? key}) : super(key: key);

//   @override
//   State<TagLocationPage> createState() => _TagLocationPageState();
// }

// class _TagLocationPageState extends State<TagLocationPage> {
//   final LocationService _locationService = LocationService();

//   bool _isLoading = false;
//   String _statusMessage = 'Ready to tag location';
//   double? targetLat;
//   double? targetLng;
//   bool userTagged = false;
//   bool approved = false;

//   bool loading = false;
//   double? targetLatitude;
//   double? targetLongitude;

//   @override
//   void initState() {
//     super.initState();
//     fetchTagInfo();
//   }

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

//   Future<void> fetchTagInfo() async {
//     print('fetch Tag info called');
//     setState(() {
//       loading = true;
//       // _isLoading = true;
//     });
//     final String? authToken = await TokenStorage.getToken();

//     try {
//       final response = await http.get(
//         Uri.parse(baseUrl1),
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

//   // Main tagging flow
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
//             ? 'Success — location tagged: ${loc.address.isNotEmpty ? loc.address : "${loc.latitude}, ${loc.longitude}"}'
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
//         setState(() {
//           userTagged = true;
//           targetLat = loc.latitude;
//           targetLng = loc.longitude;
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Tag Location')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Center(
//           child: Column(
//             children: [
//               const SizedBox(height: 8),
//               // Text('Status: $_statusMessage', textAlign: TextAlign.center),
//               // const SizedBox(height: 18),
//               Container(
//                 padding: const EdgeInsets.all(60),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.location_on,
//                       size: 48,
//                       color: Color.fromARGB(255, 6, 52, 89),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Office Location',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text("Target Latitude: $targetLatitude"),
//                     SizedBox(height: 6),
//                     Text("TargetLongitude: $targetLongitude"),
//                     SizedBox(height: 6),
//                     Text('Tagged: ${userTagged ? "True" : "False"}'),
//                     SizedBox(height: 6),
//                     Text(
//                       'Approved: ${approved ? "True" : "False"}',

//                       style: TextStyle(
//                         color: approved ? Colors.green : Colors.orange,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _tagLocation,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 2, 41, 99),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 40,
//                     vertical: 14,
//                   ),
//                 ),
//                 child: _isLoading
//                     ? Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           SizedBox(
//                             height: 18,
//                             width: 18,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Text('Tagging...', style: TextStyle(fontSize: 16)),
//                         ],
//                       )
//                     : Text(
//                         approved ? 'Already Approved' : 'Tag Location',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Color.fromRGBO(249, 248, 248, 1),
//                         ),
//                       ),
//               ),

//               Text('Status: $_statusMessage', textAlign: TextAlign.center),
//               const SizedBox(height: 18),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//Testing

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pds_app/core/Services/Android_id_get.dart';
import 'package:pds_app/core/apiConfig/config.dart';
import 'package:pds_app/core/Services/token_store.dart';

const String _setLocationTagUrl =
    '${ApiConfig.baseUrl}/attendance/setlocationtag';
const String _getLocationTagUrl =
    '${ApiConfig.baseUrl}/attendance/getlocationtaginfo';

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
    final Map<String, dynamic> data = {
      'myLatitude': myLatitude,
      'myLongitude': myLongitude,
      'isMock': isMock,
      'address': address,
      'accuracy': accuracy,
      'buildNumber': buildNumber,
      'type': type,
    };

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

class TagLocationPage extends StatefulWidget {
  const TagLocationPage({Key? key}) : super(key: key);

  @override
  State<TagLocationPage> createState() => _TagLocationPageState();
}

class _TagLocationPageState extends State<TagLocationPage> {
  final LocationService _locationService = LocationService();

  double? targetLatitude;
  double? targetLongitude;

  bool userTagged = false;
  bool approved = false;

  bool _isTagging = false;

  late Future<void> _initialFetchFuture;

  @override
  void initState() {
    super.initState();
    _initialFetchFuture = fetchTagInfo();
  }

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

    bool isMocked = false;
    try {
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

  //Fetch initial tag info
  Future<void> fetchTagInfo() async {
    debugPrint('fetch Tag info called');
    final String? authToken = await TokenStorage.getToken();

    try {
      final response = await http.get(
        Uri.parse(_getLocationTagUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('fetchTagInfo data: $data');
        setState(() {
          targetLatitude = (data["taggedLatitude"] as num?)?.toDouble();
          targetLongitude = (data["taggedLongitude"] as num?)?.toDouble();
          approved = data["approved"] ?? false;
          userTagged = data["tagged"] ?? false;
        });
      } else {
        throw Exception('Failed to fetch tag info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchTagInfo error: $e');
      rethrow;
    }
  }

  // Tagging flow
  Future<void> _tagLocation() async {
    if (approved) return;

    setState(() => _isTagging = true);

    try {
      final AttendanceLocationData loc = await _getCurrentAttendanceLocation();

      final androidId = await DeviceInfoService.getAndroidId() ?? '';

      final bool success = await _locationService.sendLocationTag(
        myLatitude: loc.latitude.toStringAsFixed(5),
        myLongitude: loc.longitude.toStringAsFixed(5),
        isMock: loc.isMock.toString(),
        address: loc.address,
        accuracy: loc.accuracy.toStringAsFixed(2),
        buildNumber: androidId,
        type: '',
      );

      if (success) {
        setState(() {
          userTagged = true;
          targetLatitude = loc.latitude;
          targetLongitude = loc.longitude;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location tagged successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to tag location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Tagging error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isTagging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialFetchFuture,
      builder: (context, snapshot) {
        // initial loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tag Location')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          return Scaffold(
            appBar: AppBar(title: const Text('Tag Location')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load tag info.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(err, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _initialFetchFuture = fetchTagInfo();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Tag Location')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 8),
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
                        Text(
                          'Target Latitude: ${targetLatitude?.toStringAsFixed(5) ?? "N/A"}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Target Longitude: ${targetLongitude?.toStringAsFixed(5) ?? "N/A"}',
                        ),
                        const SizedBox(height: 6),
                        Text('Tagged: ${userTagged ? "True" : "False"}'),
                        const SizedBox(height: 6),
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
                    onPressed: _isTagging ? null : _tagLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 2, 41, 99),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    child: _isTagging
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
                              Text(
                                'Tagging...',
                                style: TextStyle(fontSize: 16),
                              ),
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
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      userTagged
                          ? 'You have already tagged this location.'
                          : 'Ready to tag location.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
