import 'package:flutter/material.dart';

/// Helper class for announcement type colors and icons
class AnnouncementTypeHelper {
  /// Get color for announcement type
  static Color getTypeColor(String type, bool isDark) {
    switch (type) {
      case 'general':
        return isDark ? Colors.blue[300]! : Colors.blue[600]!;
      case 'important':
        return isDark ? Colors.orange[300]! : Colors.orange[600]!;
      case 'urgent':
        return isDark ? Colors.red[300]! : Colors.red[600]!;
      case 'event':
        return isDark ? Colors.purple[300]! : Colors.purple[600]!;
      case 'reminder':
        return isDark ? Colors.teal[300]! : Colors.teal[600]!;
      case 'success':
        return isDark ? Colors.green[300]! : Colors.green[600]!;
      // Legacy types
      case 'announce':
        return isDark ? Colors.blue[300]! : Colors.blue[600]!;
      case 'warning':
        return isDark ? Colors.red[300]! : Colors.red[600]!;
      case 'notice':
        return isDark ? Colors.orange[300]! : Colors.orange[600]!;
      case 'info':
        return isDark ? Colors.green[300]! : Colors.green[600]!;
      default:
        return isDark ? Colors.grey[400]! : Colors.grey[600]!;
    }
  }

  /// Get icon for announcement type
  static IconData getTypeIcon(String type) {
    switch (type) {
      case 'general':
        return Icons.info;
      case 'important':
        return Icons.priority_high;
      case 'urgent':
        return Icons.warning;
      case 'event':
        return Icons.event;
      case 'reminder':
        return Icons.notifications;
      case 'success':
        return Icons.check_circle;
      // Legacy types
      case 'announce':
        return Icons.announcement;
      case 'warning':
        return Icons.warning_rounded;
      case 'notice':
        return Icons.info_rounded;
      case 'info':
        return Icons.lightbulb_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  /// Get all announcement types
  static List<String> get allTypes => [
        'general',
        'important',
        'urgent',
        'event',
        'reminder',
        'success',
      ];
}
