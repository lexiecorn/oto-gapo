import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

class ClarityHelper {
  ClarityHelper._();

  static Widget wrapWithClarity(
    Widget app, {
    String? projectId,
    String? userId,
  }) {
    final String? flavorProjectId = (projectId ??
            (FlavorConfig.instance.variables['clarityProjectId']
                as String?))
        ?.trim();

    if (flavorProjectId == null || flavorProjectId.isEmpty) {
      return app; // No project configured; return app unchanged
    }

    final config = ClarityConfig(
      projectId: flavorProjectId,
      userId: userId,
    );

    return ClarityWidget(
      app: app,
      clarityConfig: config,
    );
  }

  static Future<void> setUserId(String userId) async {
    // Package API may not expose runtime user updates; keep as no-op for now.
  }

  static Future<void> setCustomProperties(
      Map<String, String> properties) async {
    // Not supported in this package version; no-op.
  }
}


