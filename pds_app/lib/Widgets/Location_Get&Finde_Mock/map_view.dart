import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Replace with your MapTiler API key:
const String MAPTILER_API_KEY = 'oFbUzyiQm7apc8RoI4CA';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Position? _position;
  String? _error;
  bool _initializing = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initLocationQuick();
  }

  Future<void> _initLocationQuick() async {
    try {
      final perm = await _ensurePermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission denied. Please enable location.';
          _initializing = false;
        });
        return;
      }

      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _applyPosition(last);
      }

      try {
        final fresh = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 6));
        _applyPosition(fresh);
      } on TimeoutException {
      } catch (_) {}
    } catch (e) {
      _error = 'Error getting location: $e';
    } finally {
      setState(() => _initializing = false);
    }
  }

  Future<LocationPermission> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  void _applyPosition(Position pos) {
    setState(() => _position = pos);
    final latLng = LatLng(pos.latitude, pos.longitude);
    try {
      _mapController.move(latLng, 16);
    } catch (_) {}
  }

  Future<void> _refreshLocation() async {
    setState(() => _initializing = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));
      _applyPosition(pos);
      _error = null;
    } catch (e) {
      _error = 'Could not get fresh location: $e';
    } finally {
      setState(() => _initializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing && _position == null && _error == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null && _position == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final perm = await Geolocator.checkPermission();
                  if (perm == LocationPermission.deniedForever) {
                    Geolocator.openAppSettings();
                  } else {
                    setState(() => _initializing = true);
                    await _initLocationQuick();
                  }
                },
                child: const Text('Retry / Fix permissions'),
              ),
            ],
          ),
        ),
      );
    }

    final center = LatLng(
      _position?.latitude ?? 0.0,
      _position?.longitude ?? 0.0,
    );

    // ✔ THIS URL WORKS WITH FREE MAPTILER KEY
    final maptilerUrl =
        'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$MAPTILER_API_KEY';
    // 'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=Mgq1OoHQyHRzisH04wCw';
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     _position != null
      //         ? '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}'
      //         : 'Map',
      //   ),
      //   actions: [
      //     IconButton(
      //       onPressed: _refreshLocation,
      //       icon: const Icon(Icons.my_location),
      //       tooltip: 'Refresh location',
      //     ),
      //   ],
      // ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 16,
          minZoom: 3,
          maxZoom: 19,
        ),
        children: [
          TileLayer(
            urlTemplate: maptilerUrl,
            userAgentPackageName: 'com.yourcompany.yourapp',
          ),

          if (_position != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 60,
                  height: 60,
                  child: const Center(
                    child: Icon(Icons.location_on, size: 40, color: Colors.red),
                  ),
                ),
              ],
            ),

          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(padding: EdgeInsets.all(8.0)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_position != null) {
            _mapController.move(center, 16);
          } else {
            _refreshLocation();
          }
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
