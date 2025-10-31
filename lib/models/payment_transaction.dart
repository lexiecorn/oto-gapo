import 'package:pocketbase/pocketbase.dart';

/// Payment status enum
enum PaymentStatus {
  pending('pending'),
  paid('paid'),
  waived('waived');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Payment method enum
enum PaymentMethod {
  cash('cash', 'Cash'),
  bankTransfer('bank_transfer', 'Bank Transfer'),
  gcash('gcash', 'GCash'),
  other('other', 'Other');

  const PaymentMethod(this.value, this.displayName);
  final String value;
  final String displayName;

  static PaymentMethod? fromString(String? value) {
    if (value == null) return null;
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.other,
    );
  }
}

/// Represents a payment transaction for monthly club dues.
///
/// This model tracks payment records for association members with:
/// - Explicit status field (pending/paid/waived)
/// - Payment method tracking
/// - Admin audit trail (recorded_by)
/// - Support for notes and amounts
///
/// Example:
/// ```dart
/// final transaction = PaymentTransaction(
///   id: '123',
///   userId: 'user123',
///   month: '2025-10',
///   amount: 100.0,
///   status: PaymentStatus.paid,
///   paymentDate: DateTime.now(),
///   paymentMethod: PaymentMethod.cash,
///   created: DateTime.now(),
///   updated: DateTime.now(),
/// );
///
/// if (transaction.isPaid) {
///   print('Payment completed on ${transaction.paymentDate}');
/// }
/// ```
class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.userId,
    required this.month,
    required this.amount,
    required this.status,
    required this.created,
    required this.updated,
    this.paymentDate,
    this.paymentMethod,
    this.recordedBy,
    this.notes,
  });

  factory PaymentTransaction.fromRecord(RecordModel record) {
    return PaymentTransaction(
      id: record.id,
      userId: record.data['user'] as String,
      month: record.data['month'] as String,
      amount: (record.data['amount'] as num?)?.toDouble() ?? 100.0,
      status: PaymentStatus.fromString(
          record.data['status'] as String? ?? 'pending',),
      paymentDate: record.data['payment_date'] != null
          ? DateTime.parse(record.data['payment_date'] as String)
          : null,
      paymentMethod:
          PaymentMethod.fromString(record.data['payment_method'] as String?),
      recordedBy: record.data['recorded_by'] as String?,
      notes: record.data['notes'] as String?,
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
    );
  }

  final String id;
  final String userId;
  final String month; // Format: "YYYY-MM"
  final double amount;
  final PaymentStatus status;
  final DateTime? paymentDate;
  final PaymentMethod? paymentMethod;
  final String? recordedBy;
  final String? notes;
  final DateTime created;
  final DateTime updated;

  /// Computed properties
  bool get isPaid => status == PaymentStatus.paid;
  bool get isPending => status == PaymentStatus.pending;
  bool get isWaived => status == PaymentStatus.waived;

  /// Get the month as a DateTime (first day of the month)
  DateTime get monthDate => DateTime.parse('$month-01');

  /// Check if this payment is overdue (pending and month is in the past)
  bool get isOverdue {
    if (!isPending) return false;
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    return monthDate.isBefore(currentMonth);
  }

  /// Get display text for payment method
  String get paymentMethodDisplay {
    return paymentMethod?.displayName ?? '-';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'month': month,
      'amount': amount,
      'status': status.value,
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'payment_method': paymentMethod?.value,
      'recorded_by': recordedBy,
      'notes': notes,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  PaymentTransaction copyWith({
    String? id,
    String? userId,
    String? month,
    double? amount,
    PaymentStatus? status,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    String? recordedBy,
    String? notes,
    DateTime? created,
    DateTime? updated,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recordedBy: recordedBy ?? this.recordedBy,
      notes: notes ?? this.notes,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'PaymentTransaction(id: $id, userId: $userId, month: $month, '
        'amount: $amount, status: ${status.value}, paymentDate: $paymentDate)';
  }
}
