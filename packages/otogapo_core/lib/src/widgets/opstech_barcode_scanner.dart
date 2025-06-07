import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

///
class OpstechBarcodeScanner {
  ///
  bool isBinLocationValid(String toCompare, List<String> binLocations) {
    final isValid = binLocations.contains(toCompare);
    return isValid;
  }

  ///
  Future<String?> showBarCodeScanner(
    BuildContext context, {
    List<String>? compareFromList,
  }) async {
    return showDialog<String>(
      barrierColor: Colors.black.withOpacity(.8),
      context: context,
      builder: (BuildContext context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        title: const Text(
          'Scan QR/Bar Code',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 1000.w,
              width: 1500.w,
              child: MobileScanner(
                fit: BoxFit.contain,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;

                  for (final barcode in barcodes) {
                    debugPrint(
                      'Barcode found! ${barcode.rawValue}',
                    );

                    final isValid = isBinLocationValid(
                      barcode.rawValue ?? '',
                      compareFromList ?? [],
                    );

                    if (isValid) {
                      return Navigator.pop(context, barcode.rawValue);
                    }
                  }
                },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              'cancel',
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
