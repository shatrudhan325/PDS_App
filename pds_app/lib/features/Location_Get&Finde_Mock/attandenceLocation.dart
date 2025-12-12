import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';

class LiveLocationWidgets extends StatefulWidget {
  final void Function(AttendanceLocationData) onLocationUpdate;

  const LiveLocationWidgets({Key? key, required this.onLocationUpdate})
    : super(key: key);

  @override
  State<LiveLocationWidgets> createState() => _LiveLocationWidgetsState();
}

class _LiveLocationWidgetsState extends State<LiveLocationWidgets> {
  bool _loading = true;
  String? _error;
  Position? _position;
  String? _address;
  bool _isMock = false;
  double _accuracy = 0;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission denied';
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission permanently denied';
          _loading = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final addr = place == null
          ? 'Unknown address'
          : '${place.street}, ${place.locality}, ${place.country}';

      final isMock = pos.isMocked;
      final acc = pos.accuracy;

      setState(() {
        _position = pos;
        _address = addr;
        _isMock = isMock;
        _accuracy = acc;
        _loading = false;
      });

      // Send to controller
      widget.onLocationUpdate(
        AttendanceLocationData(
          latitude: pos.latitude,
          longitude: pos.longitude,
          isMock: isMock,
          accuracy: acc,
          address: addr,
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to get location: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_position == null) {
      return const Center(child: Text('No location data'));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isMock ? Icons.warning_amber_rounded : Icons.my_location,
                color: _isMock
                    ? const Color(0xFFDC3545)
                    : const Color.fromARGB(255, 250, 250, 251),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isMock ? 'Fake GPS detected!' : 'Live Location',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lat: ${_position!.latitude.toStringAsFixed(6)}\n'
            'Lng: ${_position!.longitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Accuracy: ${_accuracy.toStringAsFixed(1)} m',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Address:\n${_address ?? '-'}',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
