import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<Widget> errorDialog(
  BuildContext context,
  String errorMessage,
  String errorCode,
  String errorPlugin,
) async {
  if (Platform.isIOS) {
    await showCupertinoDialog<Widget>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(errorCode),
          content: Text('$errorPlugin\n$errorMessage'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  } else {
    await showDialog<Widget>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(errorCode),
          content: Text('$errorPlugin\n$errorMessage'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
  return const SizedBox.shrink();
}
