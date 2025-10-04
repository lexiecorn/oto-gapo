import 'package:pocketbase/pocketbase.dart';

class MonthlyDues {
  final String id;
  final double amount;
  final DateTime? dueForMonth;
  final String status;
  final DateTime? paymentDate;
  final String? notes;
  final String userId;
  final DateTime created;
  final DateTime updated;

  const MonthlyDues({
    required this.id,
    required this.amount,
    this.dueForMonth,
    required this.status,
    this.paymentDate,
    this.notes,
    required this.userId,
    required this.created,
    required this.updated,
  });

  factory MonthlyDues.fromRecord(RecordModel record) {
    return MonthlyDues(
      id: record.id,
      amount: (record.data['amount'] as num?)?.toDouble() ?? 0.0,
      dueForMonth: record.data['due_for_month'] != null ? _parseDate(record.data['due_for_month'] as String) : null,
      status: (record.data['status'] as String?) ?? 'Unpaid',
      paymentDate: record.data['payment_date'] != null ? _parseDate(record.data['payment_date'] as String) : null,
      notes: record.data['notes'] as String?,
      userId: record.data['user'] as String,
      created: _parseDate(record.created),
      updated: _parseDate(record.updated),
    );
  }

  // Helper method to safely parse dates from PocketBase
  static DateTime _parseDate(String dateString) {
    try {
      // Handle different date formats from PocketBase
      if (dateString.contains('T')) {
        // ISO 8601 format with time: "2025-11-01T12:00:00.000Z" or "2025-11-01T00:00:00.000Z"
        return DateTime.parse(dateString);
      } else if (dateString.contains(' ')) {
        // Format with space: "2025-11-01 12:00:00.000Z"
        // Convert to ISO format by replacing space with T
        String isoFormat = dateString.replaceFirst(' ', 'T');
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
      'status': status,
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
    String? status,
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
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  bool get isPaid => status == 'Paid';
  bool get isUnpaid => status == 'Unpaid';
  bool get isOverdue => status == 'Overdue';
}
