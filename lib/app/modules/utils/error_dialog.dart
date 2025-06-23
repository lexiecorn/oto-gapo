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
          title: Text(
            errorCode,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '$errorPlugin\n$errorMessage',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
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
          title: Text(
            errorCode,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '$errorPlugin\n$errorMessage',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
  return const SizedBox.shrink();
}
