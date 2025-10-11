import 'package:otogapo/models/monthly_dues.dart';

/// Utility class for computing payment statistics based on user's joined date
/// and monthly dues records.
class PaymentStatisticsUtils {
  /// Computes payment statistics for a user based on their joined date and dues records.
  ///
  /// [joinedDate] - The date when the user joined the association
  /// [monthlyDues] - List of monthly dues records for the user
  /// [currentDate] - Current date (defaults to DateTime.now())
  ///
  /// Returns a map with:
  /// - 'paid': Number of months with completed payments
  /// - 'unpaid': Number of months without payments (but user was a member)
  /// - 'advance': Number of future months with advance payments
  /// - 'total': Total number of months user should have paid (joinedDate to current)
  static Map<String, int> computePaymentStatistics({
    required DateTime joinedDate,
    required List<MonthlyDues> monthlyDues,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final joinedMonth = DateTime(joinedDate.year, joinedDate.month);
    final currentMonth = DateTime(now.year, now.month);

    // Create a set of months that have payment records
    final paidMonths = <DateTime>{};
    final advanceMonths = <DateTime>{};

    for (final due in monthlyDues) {
      if (due.dueForMonth != null) {
        final dueMonth = DateTime(due.dueForMonth!.year, due.dueForMonth!.month);

        if (due.isPaid) {
          if (dueMonth.isBefore(currentMonth) || dueMonth.isAtSameMomentAs(currentMonth)) {
            paidMonths.add(dueMonth);
          } else {
            // Future months with payments are advance payments
            advanceMonths.add(dueMonth);
          }
        }
      }
    }

    var paid = 0;
    var unpaid = 0;
    var advance = advanceMonths.length;

    // Count all months from joinedDate to current month
    var currentCheckMonth = joinedMonth;
    while (!currentCheckMonth.isAfter(currentMonth)) {
      if (paidMonths.contains(currentCheckMonth)) {
        paid++;
      } else {
        unpaid++;
      }
      // Move to next month
      currentCheckMonth = DateTime(
        currentCheckMonth.year + (currentCheckMonth.month == 12 ? 1 : 0),
        currentCheckMonth.month == 12 ? 1 : currentCheckMonth.month + 1,
      );
    }

    return {
      'paid': paid,
      'unpaid': unpaid,
      'advance': advance,
      'total': paid + unpaid,
    };
  }

  /// Computes payment statistics for a specific month range.
  ///
  /// [joinedDate] - The date when the user joined the association
  /// [monthlyDues] - List of monthly dues records for the user
  /// [startDate] - Start of the range to analyze
  /// [endDate] - End of the range to analyze
  ///
  /// Returns a map with the same structure as computePaymentStatistics.
  static Map<String, int> computePaymentStatisticsForRange({
    required DateTime joinedDate,
    required List<MonthlyDues> monthlyDues,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final joinedMonth = DateTime(joinedDate.year, joinedDate.month);
    final startMonth = DateTime(startDate.year, startDate.month);
    final endMonth = DateTime(endDate.year, endDate.month);

    // Create a set of months that have payment records within the range
    final paidMonths = <DateTime>{};
    final advanceMonths = <DateTime>{};

    for (final due in monthlyDues) {
      if (due.dueForMonth != null) {
        final dueMonth = DateTime(due.dueForMonth!.year, due.dueForMonth!.month);

        // Only consider months within the specified range
        if (dueMonth.isAtSameMomentAs(startMonth) ||
            (dueMonth.isAfter(startMonth) && dueMonth.isBefore(endMonth)) ||
            dueMonth.isAtSameMomentAs(endMonth)) {
          if (due.isPaid) {
            if (dueMonth.isBefore(endMonth) || dueMonth.isAtSameMomentAs(endMonth)) {
              paidMonths.add(dueMonth);
            } else {
              advanceMonths.add(dueMonth);
            }
          }
        }
      }
    }

    var paid = 0;
    var unpaid = 0;
    var advance = advanceMonths.length;

    // Count months from the later of joinedDate or startDate to endDate
    var currentCheckMonth = joinedMonth.isAfter(startMonth) ? joinedMonth : startMonth;
    while (!currentCheckMonth.isAfter(endMonth)) {
      if (paidMonths.contains(currentCheckMonth)) {
        paid++;
      } else {
        unpaid++;
      }
      // Move to next month
      currentCheckMonth = DateTime(
        currentCheckMonth.year + (currentCheckMonth.month == 12 ? 1 : 0),
        currentCheckMonth.month == 12 ? 1 : currentCheckMonth.month + 1,
      );
    }

    return {
      'paid': paid,
      'unpaid': unpaid,
      'advance': advance,
      'total': paid + unpaid,
    };
  }

  /// Determines the payment status for a specific month.
  ///
  /// [monthDate] - The month to check
  /// [joinedDate] - The date when the user joined the association
  /// [monthlyDues] - List of monthly dues records for the user
  ///
  /// Returns:
  /// - null: Month is before user joined (not applicable)
  /// - true: Month is paid
  /// - false: Month is unpaid
  static bool? getPaymentStatusForMonth({
    required DateTime monthDate,
    required DateTime joinedDate,
    required List<MonthlyDues> monthlyDues,
  }) {
    final month = DateTime(monthDate.year, monthDate.month);
    final joinedMonth = DateTime(joinedDate.year, joinedDate.month);

    // If the month is before user joined, it's not applicable
    if (month.isBefore(joinedMonth)) {
      return null;
    }

    // Find the dues record for this month
    for (final due in monthlyDues) {
      if (due.dueForMonth != null) {
        final dueMonth = DateTime(due.dueForMonth!.year, due.dueForMonth!.month);
        if (dueMonth.isAtSameMomentAs(month)) {
          return due.isPaid;
        }
      }
    }

    // No record found, but user was a member, so it's unpaid
    return false;
  }

  /// Gets a list of all months from joinedDate to current date that should have payments.
  ///
  /// [joinedDate] - The date when the user joined the association
  /// [currentDate] - Current date (defaults to DateTime.now())
  ///
  /// Returns a list of DateTime objects representing each month.
  static List<DateTime> getAllPaymentMonths({
    required DateTime joinedDate,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final joinedMonth = DateTime(joinedDate.year, joinedDate.month);
    final currentMonth = DateTime(now.year, now.month);

    final months = <DateTime>[];
    var currentCheckMonth = joinedMonth;

    while (!currentCheckMonth.isAfter(currentMonth)) {
      months.add(DateTime(currentCheckMonth.year, currentCheckMonth.month));
      // Move to next month
      currentCheckMonth = DateTime(
        currentCheckMonth.year + (currentCheckMonth.month == 12 ? 1 : 0),
        currentCheckMonth.month == 12 ? 1 : currentCheckMonth.month + 1,
      );
    }

    return months;
  }

  /// Calculates the percentage of paid months.
  ///
  /// [stats] - Payment statistics map from computePaymentStatistics
  ///
  /// Returns a percentage (0.0 to 100.0) of paid months.
  static double calculatePaymentPercentage(Map<String, int> stats) {
    final total = stats['total'] ?? 0;
    final paid = stats['paid'] ?? 0;

    if (total == 0) return 0.0;
    return (paid / total) * 100.0;
  }

  /// Gets a human-readable summary of payment statistics.
  ///
  /// [stats] - Payment statistics map from computePaymentStatistics
  ///
  /// Returns a formatted string summary.
  static String getPaymentSummary(Map<String, int> stats) {
    final paid = stats['paid'] ?? 0;
    final unpaid = stats['unpaid'] ?? 0;
    final advance = stats['advance'] ?? 0;
    final total = stats['total'] ?? 0;
    final percentage = calculatePaymentPercentage(stats);

    return 'Payment Summary: $paid paid, $unpaid unpaid, $advance advance ($total total months, ${percentage.toStringAsFixed(1)}% paid)';
  }
}
