/// Test widget for Crashlytics functionality.
///
/// This widget provides buttons to test Crashlytics reporting in development
/// and staging environments. It should NOT be included in production builds.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otogapo/utils/crashlytics_helper.dart';

class CrashlyticsTestButton extends StatelessWidget {
  const CrashlyticsTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode or staging
    if (kReleaseMode) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crashlytics Test (Dev/Staging Only)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use these buttons to test Crashlytics reporting. '
              'Check Firebase Console for crash reports.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await CrashlyticsHelper.log('Test log message from button');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Test log sent to Crashlytics')),
                      );
                    }
                  },
                  child: const Text('Test Log'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await CrashlyticsHelper.logError(
                      'Test non-fatal error',
                      StackTrace.current,
                      reason: 'Test button pressed',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Test error sent to Crashlytics')),
                      );
                    }
                  },
                  child: const Text('Test Error'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await CrashlyticsHelper.setCustomKey(
                        'test_key', 'test_value');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Custom key set in Crashlytics')),
                      );
                    }
                  },
                  child: const Text('Test Custom Key'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await CrashlyticsHelper.setUserId('test_user_123');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('User ID set in Crashlytics')),
                      );
                    }
                  },
                  child: const Text('Test User ID'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // This will cause a crash for testing
                    throw Exception('Test crash from button');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Crash'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
