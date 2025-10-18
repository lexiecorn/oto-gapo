import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/models/payment_statistics.dart';
import 'package:otogapo/models/payment_transaction.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo_core/otogapo_core.dart';

/// Payment status card showing detailed payment history for users
class PaymentStatusCardNew extends StatefulWidget {
  const PaymentStatusCardNew({required this.userId, super.key});

  final String userId;

  @override
  State<PaymentStatusCardNew> createState() => _PaymentStatusCardNewState();
}

class _PaymentStatusCardNewState extends State<PaymentStatusCardNew> {
  bool _isLoading = true;
  PaymentStatistics? _statistics;
  List<PaymentTransaction> _transactions = [];
  List<String> _expectedMonths = [];
  String _filterStatus = 'all'; // all, paid, pending, overdue

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final pocketBaseService = PocketBaseService();

      // Get user to find join date
      final userRecord = await pocketBaseService.getUser(widget.userId);
      if (userRecord == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final joinedDateString = userRecord.data['joinedDate'] as String?;
      if (joinedDateString == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final joinedDate = DateTime.parse(joinedDateString);

      // Get expected months and transactions
      final expectedMonths = pocketBaseService.getExpectedMonths(joinedDate);
      final transactions = await pocketBaseService.getPaymentTransactions(widget.userId);
      final statistics = await pocketBaseService.getPaymentStatistics(widget.userId);

      if (mounted) {
        setState(() {
          _expectedMonths = expectedMonths;
          _transactions = transactions;
          _statistics = statistics;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading payment data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<MapEntry<String, PaymentTransaction?>> _getFilteredMonths() {
    final transactionMap = {for (var t in _transactions) t.month: t};
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    final monthsWithTransactions = _expectedMonths.map((month) {
      final transaction = transactionMap[month];
      return MapEntry(month, transaction);
    }).toList();

    // Apply filter
    if (_filterStatus == 'paid') {
      return monthsWithTransactions.where((e) => e.value?.isPaid ?? false).toList();
    } else if (_filterStatus == 'pending') {
      return monthsWithTransactions.where((e) => e.value == null || e.value!.isPending).toList();
    } else if (_filterStatus == 'overdue') {
      return monthsWithTransactions.where((e) {
        if (e.value == null || e.value!.isPending) {
          final monthDate = DateTime.parse('${e.key}-01');
          return monthDate.isBefore(currentMonth);
        }
        return false;
      }).toList();
    }

    return monthsWithTransactions;
  }

  Color _getStatusColor(PaymentTransaction? transaction, String month) {
    if (transaction == null) {
      // No record - check if overdue
      final monthDate = DateTime.parse('$month-01');
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      return monthDate.isBefore(currentMonth) ? Colors.red : Colors.orange;
    }

    if (transaction.isPaid) return Colors.green;
    if (transaction.isWaived) return Colors.grey;
    if (transaction.isOverdue) return Colors.red;
    return Colors.orange;
  }

  IconData _getStatusIcon(PaymentTransaction? transaction, String month) {
    if (transaction == null) {
      final monthDate = DateTime.parse('$month-01');
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      return monthDate.isBefore(currentMonth) ? Icons.error : Icons.schedule;
    }

    if (transaction.isPaid) return Icons.check_circle;
    if (transaction.isWaived) return Icons.block;
    if (transaction.isOverdue) return Icons.error;
    return Icons.schedule;
  }

  String _getStatusText(PaymentTransaction? transaction, String month) {
    if (transaction == null) {
      final monthDate = DateTime.parse('$month-01');
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      return monthDate.isBefore(currentMonth) ? 'Overdue' : 'Pending';
    }

    if (transaction.isPaid) return 'Paid';
    if (transaction.isWaived) return 'Waived';
    if (transaction.isOverdue) return 'Overdue';
    return 'Pending';
  }

  IconData _getPaymentMethodIcon(PaymentMethod? method) {
    if (method == null) return Icons.payment;

    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.gcash:
        return Icons.phone_android;
      case PaymentMethod.other:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        margin: EdgeInsets.all(16.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_statistics == null) {
      return Card(
        margin: EdgeInsets.all(16.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: const Center(
            child: Text('Unable to load payment data'),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCard(),
        SizedBox(height: 16.h),
        _buildFilterChips(),
        SizedBox(height: 16.h),
        _buildPaymentHistory(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final stats = _statistics!;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: OpstechColors.accentRed, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Paid',
                    '${stats.paidCount}/${stats.totalMonths}',
                    '${stats.paymentPercentage.toStringAsFixed(1)}%',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    stats.pendingCount.toString(),
                    stats.overdueCount > 0 ? '${stats.overdueCount} overdue' : '',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildAmountItem(
                    'Amount Paid',
                    '₱${stats.totalPaidAmount.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildAmountItem(
                    'Total Expected',
                    '₱${stats.totalExpectedAmount.toStringAsFixed(2)}',
                    Colors.grey,
                  ),
                ),
              ],
            ),
            if (stats.lastPaymentDate != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Last payment: ${DateFormat('MMM dd, yyyy').format(stats.lastPaymentDate!)} ${stats.lastPaymentMethod != null ? '(${stats.lastPaymentMethod})' : ''}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildStatItem(String label, String value, String subtitle, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildAmountItem(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 4.h),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8.w),
          _buildFilterChip('Paid', 'paid'),
          SizedBox(width: 8.w),
          _buildFilterChip('Pending', 'pending'),
          SizedBox(width: 8.w),
          _buildFilterChip('Overdue', 'overdue'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: OpstechColors.accentRed.withOpacity(0.2),
      checkmarkColor: OpstechColors.accentRed,
    );
  }

  Widget _buildPaymentHistory() {
    final filteredMonths = _getFilteredMonths();

    if (filteredMonths.isEmpty) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Center(
            child: Text(
              'No payment records found',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPaymentData,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: filteredMonths.length,
        itemBuilder: (context, index) {
          final entry = filteredMonths[index];
          return _buildPaymentMonthCard(entry.key, entry.value, index);
        },
      ),
    );
  }

  Widget _buildPaymentMonthCard(String month, PaymentTransaction? transaction, int index) {
    final monthDate = DateTime.parse('$month-01');
    final monthName = DateFormat('MMMM yyyy').format(monthDate);
    final statusColor = _getStatusColor(transaction, month);
    final statusIcon = _getStatusIcon(transaction, month);
    final statusText = _getStatusText(transaction, month);

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(statusIcon, color: statusColor, size: 20.sp),
          ),
          title: Text(
            monthName,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '₱${transaction?.amount.toStringAsFixed(2) ?? '100.00'}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          children: [
            if (transaction != null) _buildTransactionDetails(transaction),
            if (transaction == null) _buildNoRecordDetails(month),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms);
  }

  Widget _buildTransactionDetails(PaymentTransaction transaction) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          if (transaction.paymentDate != null) ...[
            _buildDetailRow(
              Icons.calendar_today,
              'Payment Date',
              DateFormat('MMMM dd, yyyy').format(transaction.paymentDate!),
            ),
            SizedBox(height: 8.h),
          ],
          if (transaction.paymentMethod != null) ...[
            _buildDetailRow(
              _getPaymentMethodIcon(transaction.paymentMethod),
              'Payment Method',
              transaction.paymentMethodDisplay,
            ),
            SizedBox(height: 8.h),
          ],
          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            _buildDetailRow(
              Icons.note,
              'Notes',
              transaction.notes!,
            ),
            SizedBox(height: 8.h),
          ],
          if (transaction.recordedBy != null) ...[
            FutureBuilder<String>(
              future: PocketBaseService().getRecordedByName(transaction.recordedBy),
              builder: (context, snapshot) {
                final adminName = snapshot.data ?? 'Loading...';
                return _buildDetailRow(
                  Icons.person,
                  'Recorded By',
                  adminName,
                );
              },
            ),
            SizedBox(height: 8.h),
          ],
          _buildDetailRow(
            Icons.access_time,
            'Last Updated',
            DateFormat('MMM dd, yyyy hh:mm a').format(transaction.updated),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRecordDetails(String month) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            'No payment record for this month',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
