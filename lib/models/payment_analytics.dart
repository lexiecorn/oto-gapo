import 'package:otogapo/models/payment_transaction.dart';

/// Represents monthly revenue data
class MonthlyRevenue {
  const MonthlyRevenue({
    required this.month,
    required this.totalAmount,
    required this.transactionCount,
    required this.paidCount,
    required this.pendingCount,
    required this.waivedCount,
  });

  final String month; // Format: "YYYY-MM"
  final double totalAmount;
  final int transactionCount;
  final int paidCount;
  final int pendingCount;
  final int waivedCount;

  /// Get the month as a DateTime (first day of the month)
  DateTime get monthDate => DateTime.parse('$month-01');
}

/// Represents payment method usage statistics
class PaymentMethodStats {
  const PaymentMethodStats({
    required this.method,
    required this.count,
    required this.totalAmount,
    required this.percentage,
  });

  final PaymentMethod method;
  final int count;
  final double totalAmount;
  final double percentage;

  String get displayName => method.displayName;
}

/// Represents payment compliance rate for a specific month
class ComplianceRate {
  const ComplianceRate({
    required this.month,
    required this.totalExpected,
    required this.paidCount,
    required this.waivedCount,
    required this.pendingCount,
    required this.overdueCount,
  });

  final String month; // Format: "YYYY-MM"
  final int totalExpected;
  final int paidCount;
  final int waivedCount;
  final int pendingCount;
  final int overdueCount;

  /// Calculate compliance percentage (paid + waived / total expected)
  double get compliancePercentage {
    if (totalExpected == 0) return 0;
    return ((paidCount + waivedCount) / totalExpected) * 100;
  }

  /// Get the month as a DateTime (first day of the month)
  DateTime get monthDate => DateTime.parse('$month-01');
}

/// Main analytics data class aggregating all payment analytics
class PaymentAnalytics {
  const PaymentAnalytics({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averagePaymentAmount,
    required this.overallComplianceRate,
    required this.monthlyRevenues,
    required this.paymentMethodStats,
    required this.complianceRates,
    required this.startMonth,
    required this.endMonth,
  });

  /// Create an empty analytics object
  factory PaymentAnalytics.empty() {
    return const PaymentAnalytics(
      totalRevenue: 0,
      totalTransactions: 0,
      averagePaymentAmount: 0,
      overallComplianceRate: 0,
      monthlyRevenues: [],
      paymentMethodStats: [],
      complianceRates: [],
      startMonth: '',
      endMonth: '',
    );
  }

  final double totalRevenue;
  final int totalTransactions;
  final double averagePaymentAmount;
  final double overallComplianceRate;
  final List<MonthlyRevenue> monthlyRevenues;
  final List<PaymentMethodStats> paymentMethodStats;
  final List<ComplianceRate> complianceRates;
  final String startMonth;
  final String endMonth;

  /// Check if analytics data is available
  bool get isEmpty => totalTransactions == 0;
}
