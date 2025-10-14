// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

// Map<String, dynamic>? parsedData;
// String scannedMessage = 'No data scanned yet.';

// class QRCodeScanner extends StatefulWidget {
//   const QRCodeScanner({super.key});

//   @override
//   State<QRCodeScanner> createState() => _QRCodeScannerState();
// }

// class _QRCodeScannerState extends State<QRCodeScanner> {
//   String scannedCode = '';

//   Future<void> startscan() async {
//     String result;

//     try {
//       result = await FlutterBarcodeScanner.scanBarcode(
//         '#FFFFFF',
//         'Cancelled',
//         true,
//         ScanMode.QR,
//         int.parse('1'),
//         'back',
//         ScanFormat.ONLY_QR_CODE,
//       );
//     } on PlatformException catch (e) {
//       result = 'Failed to get platform version.';
//       Get.snackbar('Error', e.toString());
//     } catch (e) {
//       result = 'Failed to get platform version.';
//       Get.snackbar('Error', e.toString());
//     }
//     if (!mounted) return;
//     setState(() {
//       scannedCode = result;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: Text(
//               "Scanned Value - $scannedCode",
//               textAlign: TextAlign.center,
//             ),
//           ),
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 startscan();
//               },
//               child: Text("Start Scan", style: TextStyle(fontSize: 20)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:simple_barcode_scanner/enum.dart';

// Global variable to hold the parsed data
Map<String, dynamic> parsedData = {};

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  // Scanned code is only kept for temporary state
  String scannedCode = '';

  Future<void> startscan() async {
    String result = '-1';

    try {
      result = await FlutterBarcodeScanner.scanBarcode(
        '#E87A00', // Scanner overlay color
        'Cancel',
        true, // Show flash icon
        ScanMode.QR, // Scan only QR codes
        1, // timeout / additional integer argument
        'back', // camera facing option
        ScanFormat.ONLY_QR_CODE, // restricts to QR format
      );
    } on PlatformException catch (e) {
      result = '-1';
      Get.snackbar(
        'Error',
        'Platform Error: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      result = '-1';
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }

    if (!mounted) return;

    // Reset and process the result
    setState(() {
      scannedCode = result;

      // If the result is the default cancel value (-1), clear the data
      if (result == '-1' || result.isEmpty) {
        parsedData = {};
        return;
      }

      // Try to parse the result string as a JSON map
      try {
        // Attempt to decode the JSON string from the QR code
        parsedData = jsonDecode(result) as Map<String, dynamic>;
      } on FormatException {
        // Handle error if the scanned string is not valid JSON
        parsedData = {
          'Error': 'Failed to Parse Data',
          'Raw Value': result,
          'Message': 'QR code data is not valid JSON format.',
        };
        Get.snackbar(
          'Parsing Failed',
          'The scanned QR code content could not be parsed as JSON.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      } catch (e) {
        // Handle other potential errors during parsing
        parsedData = {'Unknown Error': e.toString()};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'SCANNER INFO',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false, // Align left like in the image
        backgroundColor: const Color(0xFFE87A00), // Orange-like header color
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Data Display Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
              ),
              child: parsedData.isNotEmpty
                  ? ListView(
                      children: parsedData.entries
                          .map(
                            (entry) => InfoRow(
                              keyText: entry.key,
                              valueText: entry.value.toString(),
                            ),
                          )
                          .toList(),
                    )
                  : Center(
                      child: Text(
                        'Tap "Start Scan" to read device information.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),

          // 2. Action Button (Start Scan)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 15.0,
            ),
            child: ElevatedButton(
              onPressed: startscan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF003060,
                ), // Dark Blue color for Scan
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Start Scan",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),

          // Optional: You can add the "POWER OFF" button here if needed
        ],
      ),
    );
  }
}

// Custom Widget to display the Key-Value pair row with fixed alignment
class InfoRow extends StatelessWidget {
  final String keyText;
  final String valueText;

  const InfoRow({required this.keyText, required this.valueText, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Reduced vertical padding for compact look
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Key/Label with a fixed width for consistent colon alignment
          SizedBox(
            width: 120, // Adjust this width as needed to fit your longest key
            child: Text(
              // Key text immediately followed by the colon and a space
              '$keyText :',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 8), // Small space between key and value
          // Right side: Value, takes up remaining space
          Expanded(
            child: Text(
              valueText,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
