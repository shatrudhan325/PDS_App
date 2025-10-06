import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

Map<String, dynamic>? parsedData;
String scannedMessage = 'No data scanned yet.';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  String scannedCode = '';

  Future<void> startscan() async {
    String result;

    try {
      result = await FlutterBarcodeScanner.scanBarcode(
        '#FFFFFF',
        'Cancelled',
        true,
        ScanMode.QR,
        int.parse('1'),
        'back',
        ScanFormat.ONLY_QR_CODE,
      );
    } on PlatformException catch (e) {
      result = 'Failed to get platform version.';
      Get.snackbar('Error', e.toString());
    } catch (e) {
      result = 'Failed to get platform version.';
      Get.snackbar('Error', e.toString());
    }
    if (!mounted) return;
    setState(() {
      scannedCode = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Scanned Value - $scannedCode",
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                startscan();
              },
              child: Text("Start Scan", style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}
