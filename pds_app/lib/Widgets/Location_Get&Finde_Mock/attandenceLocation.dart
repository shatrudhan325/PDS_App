import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:detect_fake_location/detect_fake_location.dart';

class LiveLocationWidgets extends StatefulWidget {
  const LiveLocationWidgets({super.key});

  @override
  State<LiveLocationWidgets> createState() => _LiveLocationWidgetState();
}

class _LiveLocationWidgetState extends State<LiveLocationWidgets> {
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
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final newAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
        setState(() {
          _address = newAddress;
        });
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
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
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
      final isFakeGPSLocation = await detector.detectFakeLocation(
        ignoreExternalAccessory: true,
      );
      setState(() {
        isFakeLocation = isFakeGPSLocation;
      });
    } catch (_) {
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
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (futureSnapshot.hasData) {
          return StreamBuilder<Position>(
            stream: futureSnapshot.data,
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasData) {
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
                    const SizedBox(height: 10),
                    const Text(
                      'Your Live Location',
                      style: TextStyle(
                        fontSize: 22,
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
                    Text(
                      isFakeLocation
                          ? '⚠️ Fake GPS Detected'
                          : '✅ Genuine Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isFakeLocation ? Colors.red : Colors.green,
                      ),
                    ),
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
