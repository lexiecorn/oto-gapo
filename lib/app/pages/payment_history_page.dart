import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/models/payment_statistics.dart';
import 'package:otogapo/models/payment_transaction.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  bool _isLoading = true;
  List<PaymentTransaction> _transactions = [];
  PaymentStatistics? _statistics;
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
      final authState = context.read<AuthBloc>().state;
      if (authState.user?.id == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final pocketBaseService = PocketBaseService();
      final transactions =
          await pocketBaseService.getPaymentTransactions(authState.user!.id);
      final statistics =
          await pocketBaseService.getPaymentStatistics(authState.user!.id);

      if (mounted) {
        setState(() {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading payment data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<PaymentTransaction> _getFilteredTransactions() {
    if (_filterStatus == 'all') return _transactions;

    return _transactions.where((transaction) {
      switch (_filterStatus) {
        case 'paid':
          return transaction.isPaid;
        case 'pending':
          return transaction.isPending;
        case 'overdue':
          return transaction.isOverdue;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaymentData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading payment history...'),
                ],
              ),
            )
          : Column(
              children: [
                _buildSummaryCard(),
                _buildFilterChips(),
                Expanded(child: _buildPaymentList()),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    if (_statistics == null) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Months',
                    _statistics!.totalMonths.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Paid',
                    _statistics!.paidCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Pending',
                    _statistics!.pendingCount.toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Overdue',
                    _statistics!.overdueCount.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Payment Rate: ${_statistics!.paymentPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color,) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
              fontSize: 12.sp, fontWeight: FontWeight.bold, color: color,),
        ),
        Text(label, style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 10.sp)),
      selected: _filterStatus == value,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
    );
  }

  Widget _buildPaymentList() {
    final filteredTransactions = _getFilteredTransactions();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 48.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No payments found',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            if (_filterStatus != 'all')
              Text(
                'Try changing the filter above',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPaymentData,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = filteredTransactions[index];
          return _buildPaymentCard(transaction, index);
        },
      ),
    );
  }

  Widget _buildPaymentCard(PaymentTransaction transaction, int index) {
    final monthDate = transaction.monthDate;
    final monthName = DateFormat('MMMM yyyy').format(monthDate);
    final isPaid = transaction.isPaid;
    final isWaived = transaction.isWaived;
    final isOverdue = transaction.isOverdue;

    final statusColor = isPaid
        ? Colors.green
        : isWaived
            ? Colors.grey
            : isOverdue
                ? Colors.red
                : Colors.orange;

    final statusText = isPaid
        ? 'PAID'
        : isWaived
            ? 'WAIVED'
            : isOverdue
                ? 'OVERDUE'
                : 'PENDING';

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthName,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.bold,),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Amount: ₱${transaction.amount.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isPaid) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.payment, size: 14.sp, color: Colors.green),
                  SizedBox(width: 4.w),
                  Text(
                    'Paid via ${transaction.paymentMethodDisplay}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.green),
                  ),
                ],
              ),
              if (transaction.paymentDate != null) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      'Paid on ${DateFormat('MMM dd, yyyy').format(transaction.paymentDate!)}',
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        transaction.notes!,
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
