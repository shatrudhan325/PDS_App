import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:antifakegps/antifakegps.dart';
import 'package:detect_fake_location/detect_fake_location.dart';

class LiveLocationWidget extends StatefulWidget {
  const LiveLocationWidget({super.key});

  @override
  State<LiveLocationWidget> createState() => _LiveLocationWidgetState();
}

class _LiveLocationWidgetState extends State<LiveLocationWidget> {
  String _address = 'Fetching address...';
  bool isFakeLocation = false;
  Position? _position;

  late final Future<Stream<Position>> _positionStream;

  @override
  void initState() {
    super.initState();
    _positionStream = _getLiveLocationStream();
    _checkFakeGPS();
  }

  Future<void> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String newAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
        setState(() {
          _address = newAddress;
        });
        // print(_address);
      } else {
        setState(() {
          _address = 'No address found.';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Error getting address: $e';
      });
    }
  }

  Future<Stream<Position>> _getLiveLocationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<void> _checkFakeGPS() async {
    try {
      final detector = DetectFakeLocation();
      bool isFakeGPSLocation = await detector.detectFakeLocation(
        ignoreExternalAccessory: true,
      );

      print(isFakeGPSLocation);

      setState(() {
        isFakeLocation = isFakeGPSLocation;
      });
    } catch (err) {
      setState(() {
        isFakeLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Stream<Position>>(
      future: _positionStream,
      builder: (context, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (futureSnapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${futureSnapshot.error}',
              style: const TextStyle(color: Color.fromARGB(255, 31, 126, 185)),
              textAlign: TextAlign.center,
            ),
          );
        } else if (futureSnapshot.hasData) {
          return StreamBuilder<Position>(
            stream: futureSnapshot.data,
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasData) {
                // Get the current position and update the address.
                _position = streamSnapshot.data!;
                _getAddressFromCoordinates(_position!);
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Live Location ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      _address,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    if (_position != null) ...[
                      Text(
                        'Latitude: ${_position!.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Longitude: ${_position!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Accuracy: ${_position!.accuracy.toStringAsFixed(2)}m',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(isFakeLocation ? 'Fake detected' : ''),
                    ],
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('Unknown state.'));
        }
      },
    );
  }
}
