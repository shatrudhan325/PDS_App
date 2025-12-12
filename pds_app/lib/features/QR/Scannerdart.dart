// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:simple_barcode_scanner/enum.dart';

// // Global variable to hold the parsed data
// Map<String, dynamic> parsedData = {};

// class QRCodeScanner extends StatefulWidget {
//   const QRCodeScanner({super.key});

//   @override
//   State<QRCodeScanner> createState() => _QRCodeScannerState();
// }

// class _QRCodeScannerState extends State<QRCodeScanner> {
//   // Scanned code is only kept for temporary state
//   String scannedCode = '';

//   Future<void> startscan() async {
//     String result = '-1';

//     try {
//       result = await FlutterBarcodeScanner.scanBarcode(
//         '#E87A00', // Scanner overlay color
//         'Cancel',
//         true, // Show flash icon
//         ScanMode.QR, // Scan only QR codes
//         1, // timeout / additional integer argument
//         'back', // camera facing option
//         ScanFormat.ONLY_QR_CODE, // restricts to QR format
//       );
//     } on PlatformException catch (e) {
//       result = '-1';
//       Get.snackbar(
//         'Error',
//         'Platform Error: ${e.message}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       result = '-1';
//       Get.snackbar(
//         'Error',
//         'An unexpected error occurred: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//       );
//     }

//     if (!mounted) return;

//     // Reset and process the result
//     setState(() {
//       scannedCode = result;

//       // If the result is the default cancel value (-1), clear the data
//       if (result == '-1' || result.isEmpty) {
//         parsedData = {};
//         return;
//       }

//       // Try to parse the result string as a JSON map
//       try {
//         // Attempt to decode the JSON string from the QR code
//         parsedData = jsonDecode(result) as Map<String, dynamic>;
//       } on FormatException {
//         // Handle error if the scanned string is not valid JSON
//         parsedData = {
//           'Error': 'Failed to Parse Data',
//           'Raw Value': result,
//           'Message': 'QR code data is not valid JSON format.',
//         };
//         Get.snackbar(
//           'Parsing Failed',
//           'The scanned QR code content could not be parsed as JSON.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.orange.withOpacity(0.8),
//           colorText: Colors.white,
//         );
//       } catch (e) {
//         // Handle other potential errors during parsing
//         parsedData = {'Unknown Error': e.toString()};
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'SCANNER INFO',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: false, // Align left like in the image
//         backgroundColor: const Color(0xFFE87A00), // Orange-like header color
//         systemOverlayStyle: SystemUiOverlayStyle.light,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // 1. Data Display Section
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 left: 20.0,
//                 right: 20.0,
//                 top: 20.0,
//               ),
//               child: parsedData.isNotEmpty
//                   ? ListView(
//                       children: parsedData.entries
//                           .map(
//                             (entry) => InfoRow(
//                               keyText: entry.key,
//                               valueText: entry.value.toString(),
//                             ),
//                           )
//                           .toList(),
//                     )
//                   : Center(
//                       child: Text(
//                         'Tap "Start Scan" to read device information.',
//                         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//             ),
//           ),

//           // 2. Action Button (Start Scan)
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 15.0,
//             ),
//             child: ElevatedButton(
//               onPressed: startscan,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(
//                   0xFF003060,
//                 ), // Dark Blue color for Scan
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text(
//                 "Start Scan",
//                 style: TextStyle(fontSize: 20, color: Colors.white),
//               ),
//             ),
//           ),

//           // Optional: You can add the "POWER OFF" button here if needed
//         ],
//       ),
//     );
//   }
// }

// // Custom Widget to display the Key-Value pair row with fixed alignment
// class InfoRow extends StatelessWidget {
//   final String keyText;
//   final String valueText;

//   const InfoRow({required this.keyText, required this.valueText, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       // Reduced vertical padding for compact look
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left side: Key/Label with a fixed width for consistent colon alignment
//           SizedBox(
//             width: 120, // Adjust this width as needed to fit your longest key
//             child: Text(
//               // Key text immediately followed by the colon and a space
//               '$keyText :',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.left,
//             ),
//           ),
//           const SizedBox(width: 8), // Small space between key and value
//           // Right side: Value, takes up remaining space
//           Expanded(
//             child: Text(
//               valueText,
//               style: const TextStyle(fontSize: 16, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//Only Improved UI. TOP code is tested
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:simple_barcode_scanner/enum.dart';

// -----------------------------------------------------------------------------
// GetX Controller: keeps scanned state reactive and encapsulates scanning logic
// (Logic preserved from your original implementation; only moved into controller)
// -----------------------------------------------------------------------------
class QRController extends GetxController {
  // Reactive map and scanned code string
  final parsedData = <String, dynamic>{}.obs;
  final scannedCode = ''.obs;

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

    // Update reactive state (logic unchanged)
    scannedCode.value = result;

    if (result == '-1' || result.isEmpty) {
      parsedData.clear();
      return;
    }

    try {
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      parsedData.assignAll(decoded);
    } on FormatException {
      parsedData.assignAll({
        'Error': 'Failed to Parse Data',
        'Raw Value': result,
        'Message': 'QR code data is not valid JSON format.',
      });
      Get.snackbar(
        'Parsing Failed',
        'The scanned QR code content could not be parsed as JSON.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF1A57D8),
        colorText: Colors.white,
      );
    } catch (e) {
      parsedData.assignAll({'Unknown Error': e.toString()});
    }
  }
}

class R {
  static double width(BuildContext c, double factor) => Get.width * factor;
  static double height(BuildContext c, double factor) => Get.height * factor;

  // Responsive font size with a base factor and clamp to limits
  static double font(BuildContext c, double base) {
    // base is designed for a 400pt width device. Scale proportionally.
    final scale = Get.width / 400.0;
    final size = base * scale;
    return size.clamp(base * 0.85, base * 1.6);
  }

  static EdgeInsets paddingAll(BuildContext c, double factor) =>
      EdgeInsets.all(Get.width * factor);
}

// -----------------------------------------------------------------------------
// Main UI: uses GetX (Obx) to react to controller changes and R for responsive sizes
// -----------------------------------------------------------------------------
class QRCodeScanner extends StatelessWidget {
  QRCodeScanner({super.key});

  // Bind the controller once for the lifetime of this page
  final QRController ctrl = Get.put(QRController());

  @override
  Widget build(BuildContext context) {
    // Provide a media-aware baseline (for orientation changes)
    final isPortrait = Get.height >= Get.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isPortrait ? 72 : 56),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.03,
              vertical: Get.height * 0.01,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A57D8), Color(0xFF1A57D8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: R.font(context, 18),
                  ),
                  onPressed: () => Get.back(),
                ),
                SizedBox(width: Get.width * 0.02),
                Text(
                  'SCANNER INFO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: R.font(context, 18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final hasData = ctrl.parsedData.isNotEmpty;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(hasData ? 0.18 : 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasData ? Icons.check_circle : Icons.qr_code,
                          color: Colors.white,
                          size: R.font(context, 14),
                        ),
                        SizedBox(width: Get.width * 0.015),
                        Text(
                          hasData ? 'Data Loaded' : 'Ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: R.font(context, 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),

      // Floating action button positioned adaptively
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ctrl.startscan,
        label: Text(
          'Start Scan',
          style: TextStyle(fontSize: R.font(context, 14), color: Colors.white),
        ),
        icon: Icon(Icons.qr_code_scanner, size: R.font(context, 18)),
        backgroundColor: Color(0xFF1A57D8),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth * 0.04;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    8,
                  ),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(constraints.maxWidth * 0.035),
                      child: Row(
                        children: [
                          Container(
                            width: constraints.maxWidth * 0.14,
                            height: constraints.maxWidth * 0.14,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A57D8), Color(0xFF1A57D8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              Icons.qr_code,
                              color: Colors.white,
                              size: R.font(context, 28),
                            ),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scan results appear here',
                                  style: TextStyle(
                                    fontSize: R.font(context, 15),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: constraints.maxHeight * 0.008),
                                Obx(() {
                                  final preview = _previewTextFromParsed(
                                    ctrl.parsedData,
                                  );
                                  return Text(
                                    preview.isNotEmpty
                                        ? preview
                                        : 'Tap the button below or use the floating action button to scan a QR code.',
                                    style: TextStyle(
                                      fontSize: R.font(context, 12),
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }),
                              ],
                            ),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.02),
                          IconButton(
                            onPressed: () {
                              ctrl.parsedData.clear();
                              ctrl.scannedCode.value = '';
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey[600],
                              size: R.font(context, 18),
                            ),
                            tooltip: 'Clear',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Expanded list area for key/value pairs
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 8,
                    ),
                    child: Obx(() {
                      if (ctrl.parsedData.isNotEmpty) {
                        final entries = ctrl.parsedData.entries.toList();
                        return ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: constraints.maxHeight * 0.01),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return InfoCard(
                              keyText: entry.key,
                              valueText: entry.value.toString(),
                              widthConstraint: constraints.maxWidth,
                              fontGetter: (base) => R.font(context, base),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: constraints.maxWidth * 0.18,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: constraints.maxHeight * 0.02),
                              Text(
                                'No data yet',
                                style: TextStyle(
                                  fontSize: R.font(context, 18),
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: constraints.maxHeight * 0.008),
                              Text(
                                'Press "Start Scan" to scan a QR code',
                                style: TextStyle(
                                  fontSize: R.font(context, 13),
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
                  ),
                ),

                // Bottom safe spacing so FAB doesn't overlap content on small devices
                SizedBox(height: Get.height * 0.08),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Helper to show a short preview string from parsed data without changing any logic
String _previewTextFromParsed(Map<String, dynamic> data) {
  final commonKeys = ['name', 'device', 'id', 'serial', 'model'];
  for (var k in commonKeys) {
    if (data.containsKey(k)) return '$k: ${data[k]}';
  }
  if (data.isNotEmpty)
    return '${data.entries.first.key}: ${data.entries.first.value}';
  return '';
}

// A modern card-like widget to display each key/value pair with copy action
class InfoCard extends StatelessWidget {
  final String keyText;
  final String valueText;
  final double widthConstraint;
  final double Function(double) fontGetter;

  const InfoCard({
    required this.keyText,
    required this.valueText,
    required this.widthConstraint,
    required this.fontGetter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final keyWidth = (widthConstraint * 0.28).clamp(100.0, 180.0);

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widthConstraint * 0.03,
          vertical: widthConstraint * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: keyWidth,
              child: Text(
                '$keyText :',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: fontGetter(15),
                ),
              ),
            ),
            SizedBox(width: widthConstraint * 0.02),
            Expanded(
              child: Text(
                valueText,
                style: TextStyle(fontSize: fontGetter(15)),
              ),
            ),
            SizedBox(width: widthConstraint * 0.02),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: valueText));
                Get.snackbar(
                  'Copied',
                  'Value copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: Icon(Icons.copy, size: fontGetter(16)),
              tooltip: 'Copy value',
            ),
          ],
        ),
      ),
    );
  }
}
