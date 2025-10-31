/// N8N Test Button Widget
///
/// A simple widget for testing n8n error logging integration.
/// This widget provides buttons to test both test and production webhooks.
library;

import 'package:flutter/material.dart';
import 'package:otogapo/services/n8n_error_logger.dart';

class N8nTestButton extends StatelessWidget {
  const N8nTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'N8N Error Logging Test',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _testN8nError(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Webhook'),
            ),
            ElevatedButton(
              onPressed: () => _testN8nError(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Production Webhook'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Check your n8n workflow for received errors',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _testN8nError(bool useTestUrl) {
    N8nErrorLogger.sendErrorToN8n(
      'Test error from Flutter app - ${useTestUrl ? "TEST" : "PRODUCTION"} webhook',
      'This is a test stack trace:\n'
          '  at main (main.dart:1)\n'
          '  at runApp (app.dart:1)\n'
          '  at build (widget.dart:1)',
      reason: 'Manual test from N8nTestButton widget',
      useTestUrl: useTestUrl,
    );
  }
}
