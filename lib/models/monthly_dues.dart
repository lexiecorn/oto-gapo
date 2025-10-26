import 'package:pocketbase/pocketbase.dart';

/// @deprecated Use PaymentTransaction instead. This model is from the old
/// monthly_dues system and will be removed in a future version.
///
/// Represents a monthly dues record for a user in the association.
///
/// This model tracks payment obligations and payments for association members.
/// Each record represents a single month's dues for a specific user.
///
/// Key features:
/// - Payment tracking with `paymentDate`
/// - Automatic overdue calculation
/// - Support for advance payments
/// - Integration with PocketBase backend
///
/// Example:
/// ```dart
/// final dues = MonthlyDues(
///   id: '123',
///   userId: 'user123',
///   amount: 100.0,
///   dueForMonth: DateTime(2025, 11),
///   paymentDate: null, // Not yet paid
///   created: DateTime.now(),
///   updated: DateTime.now(),
/// );
///
/// // Check payment status
/// if (dues.isPaid) {
///   print('Payment completed');
/// } else if (dues.isOverdue) {
///   print('Payment is overdue');
/// }
/// ```
@Deprecated('Use PaymentTransaction from payment_transaction.dart instead')
class MonthlyDues {
  const MonthlyDues({
    required this.id,
    required this.amount,
    required this.userId,
    required this.created,
    required this.updated,
    this.dueForMonth,
    this.paymentDate,
    this.notes,
  });

  factory MonthlyDues.fromRecord(RecordModel record) {
    print('MonthlyDues.fromRecord - Raw data: ${record.data}');
    print(
        'MonthlyDues.fromRecord - payment_date raw: ${record.data['payment_date']}');

    final paymentDateRaw = record.data['payment_date'];
    final paymentDate =
        paymentDateRaw != null ? _parseDate(paymentDateRaw as String) : null;

    print('MonthlyDues.fromRecord - payment_date parsed: $paymentDate');
    print(
        'MonthlyDues.fromRecord - payment_date != null: ${paymentDate != null}');

    return MonthlyDues(
      id: record.id,
      amount: (record.data['amount'] as num?)?.toDouble() ?? 0.0,
      dueForMonth: record.data['due_for_month'] != null
          ? _parseDate(record.data['due_for_month'] as String)
          : null,
      paymentDate: paymentDate,
      notes: record.data['notes'] as String?,
      userId: record.data['user'] as String,
      created: _parseDate(record.created),
      updated: _parseDate(record.updated),
    );
  }
  final String id;
  final double amount;
  final DateTime? dueForMonth;
  final DateTime? paymentDate;
  final String? notes;
  final String userId;
  final DateTime created;
  final DateTime updated;

  // Helper method to safely parse dates from PocketBase
  static DateTime _parseDate(String dateString) {
    try {
      // Handle empty or null date strings
      if (dateString.isEmpty || dateString.trim().isEmpty) {
        print('Empty date string provided to _parseDate');
        return DateTime.now();
      }

      // Handle different date formats from PocketBase
      if (dateString.contains('T')) {
        // ISO 8601 format with time: "2025-11-01T12:00:00.000Z" or "2025-11-01T00:00:00.000Z"
        return DateTime.parse(dateString);
      } else if (dateString.contains(' ')) {
        // Format with space: "2025-11-01 12:00:00.000Z"
        // Convert to ISO format by replacing space with T
        final isoFormat = dateString.replaceFirst(' ', 'T');
        return DateTime.parse(isoFormat);
      } else {
        // Date only format: "2025-11-01"
        return DateTime.parse(dateString);
      }
    } catch (e) {
      print('Error parsing date "$dateString": $e');
      // Return current date as fallback
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'due_for_month': dueForMonth?.toIso8601String().split('T')[0],
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'notes': notes,
      'user': userId,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  MonthlyDues copyWith({
    String? id,
    double? amount,
    DateTime? dueForMonth,
    DateTime? paymentDate,
    String? notes,
    String? userId,
    DateTime? created,
    DateTime? updated,
  }) {
    return MonthlyDues(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      dueForMonth: dueForMonth ?? this.dueForMonth,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  bool get isPaid => paymentDate != null;
  bool get isUnpaid => paymentDate == null;

  // Calculate overdue based on due date vs current date
  bool get isOverdue {
    if (paymentDate != null) return false; // Already paid
    if (dueForMonth == null) return false; // No due date set

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final dueMonth = DateTime(dueForMonth!.year, dueForMonth!.month);

    return currentMonth.isAfter(dueMonth);
  }
}
