//Currently not in used

import 'package:flutter/material.dart';
//import 'package:pds_app/Widgets/Location_Get&Finde_Mock/map_view.dart';
import 'package:pds_app/Widgets/Location_Get&Finde_Mock/locationservice.dart';

class TagLocation extends StatefulWidget {
  const TagLocation({super.key});

  @override
  State<TagLocation> createState() => _MyAppState();
}

class _MyAppState extends State<TagLocation> {
  // Simple controller value for scaling; replace with real responsive logic if needed
  final double controller = 1.0;

  double _scale(double? controller) {
    // Ensure a valid scale is returned; customize as required.
    return (controller != null && controller > 0) ? controller : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Tag Location')),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 10 * _scale(controller)),
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 16 * _scale(controller),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF030213),
                ),
              ),
              SizedBox(height: 16 * _scale(controller)),

              Container(
                height: 280 * _scale(controller),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LiveLocationWidget(), //LiveLocationWidget(),
              ),
              SizedBox(height: 16 * _scale(controller)),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF003060,
                  ), // Dark Blue color for Scan
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Tag Location",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              // Container(
              //   height: 280 * _scale(controller),
              //   decoration: BoxDecoration(
              //     gradient: const LinearGradient(
              //       colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
              //     ),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: MapView(), //LiveLocationWidget(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
