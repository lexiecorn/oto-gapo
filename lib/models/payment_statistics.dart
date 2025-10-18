/// Statistics data for user payment information
class PaymentStatistics {
  const PaymentStatistics({
    required this.totalMonths,
    required this.paidCount,
    required this.pendingCount,
    required this.waivedCount,
    required this.overdueCount,
    required this.totalPaidAmount,
    required this.totalExpectedAmount,
    this.lastPaymentDate,
    this.lastPaymentMethod,
  });

  final int totalMonths;
  final int paidCount;
  final int pendingCount;
  final int waivedCount;
  final int overdueCount;
  final double totalPaidAmount;
  final double totalExpectedAmount;
  final DateTime? lastPaymentDate;
  final String? lastPaymentMethod;

  /// Calculate payment percentage
  double get paymentPercentage {
    if (totalMonths == 0) return 0;
    return (paidCount / totalMonths) * 100;
  }

  /// Check if user is up to date with payments
  bool get isUpToDate => overdueCount == 0;

  @override
  String toString() {
    return 'PaymentStatistics(totalMonths: $totalMonths, paid: $paidCount, '
        'pending: $pendingCount, overdue: $overdueCount)';
  }
}
