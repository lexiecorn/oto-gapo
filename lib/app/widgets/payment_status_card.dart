import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class PaymentStatusCard extends StatefulWidget {
  const PaymentStatusCard({required this.userId, super.key});
  final String userId;

  @override
  State<PaymentStatusCard> createState() => _PaymentStatusCardState();
}

class _PaymentStatusCardState extends State<PaymentStatusCard> {
  bool _isLoading = true;
  int _paidCount = 0;
  int _unpaidCount = 0;
  int _advanceCount = 0;
  double _totalAmount = 0;
  List<Map<String, dynamic>> _recentPayments = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    try {
      // Check if widget is still mounted before starting
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      print('PaymentStatusCard - Loading payment data for userId: "${widget.userId}"');
      final pocketBaseService = PocketBaseService();

      // Debug: Let's see ALL monthly dues records first
      await pocketBaseService.debugAllMonthlyDues();

      // Check if still mounted after async operation
      if (!mounted) return;

      // If no records exist, create test records
      final allDues = await pocketBaseService.getAllMonthlyDues();
      if (allDues.isEmpty) {
        print('No monthly dues records found, creating test records...');
        await pocketBaseService.createTestMonthlyDues(widget.userId);
      }

      // Check if still mounted after async operation
      if (!mounted) return;

      // First, let's check what user data we have
      try {
        final userRecord = await pocketBaseService.pb.collection('users').getOne(widget.userId);
        print('PaymentStatusCard - User record data: ${userRecord.data}');
        print('PaymentStatusCard - User record ID: ${userRecord.id}');

        // Check all possible user identifiers
        final userEmail = userRecord.data['email'] as String?;
        final userFirstName = userRecord.data['firstName'] as String?;
        final userMemberNumber = userRecord.data['memberNumber']?.toString();
        final userEmailPrefix = userEmail?.split('@').first;

        print('PaymentStatusCard - User email: $userEmail');
        print('PaymentStatusCard - User firstName: $userFirstName');
        print('PaymentStatusCard - User memberNumber: $userMemberNumber');
        print('PaymentStatusCard - User emailPrefix: $userEmailPrefix');
      } catch (e) {
        print('PaymentStatusCard - Error getting user record: $e');
      }

      // Check if still mounted after async operation
      if (!mounted) return;

      // Get payment statistics
      final stats = await pocketBaseService.getPaymentStatistics(widget.userId);
      print('PaymentStatusCard - Payment statistics: $stats');

      // Get all monthly dues for the user
      final monthlyDues = await pocketBaseService.getMonthlyDuesForUser(widget.userId);
      print('PaymentStatusCard - Monthly dues count: ${monthlyDues.length}');
      for (final due in monthlyDues) {
        print('PaymentStatusCard - Due: ${due.id}, Paid: ${due.isPaid}, Amount: ${due.amount}, User: ${due.userId}');
      }

      // Also check all monthly dues records to see what user identifiers exist
      try {
        final allMonthlyDues = await pocketBaseService.getAllMonthlyDues();
        print('PaymentStatusCard - Total monthly dues records in database: ${allMonthlyDues.length}');
        for (final due in allMonthlyDues) {
          print('PaymentStatusCard - All dues - ID: ${due.id}, User: ${due.userId}, Paid: ${due.isPaid}');
        }
      } catch (e) {
        print('PaymentStatusCard - Error getting all monthly dues: $e');
      }

      // Check if still mounted after async operations
      if (!mounted) return;

      final recentPayments = <Map<String, dynamic>>[];

      // Convert monthly dues to recent payments format
      for (final due in monthlyDues) {
        if (due.dueForMonth != null) {
          final displayText = DateFormat('MMMM yyyy').format(due.dueForMonth!);
          final isAdvance = due.dueForMonth!.isAfter(DateTime.now());

          recentPayments.add({
            'month': displayText,
            'isPaid': due.isPaid,
            'amount': due.amount,
            'updatedAt': due.paymentDate,
            'isAdvance': isAdvance,
          });
        }
      }

      // Sort recent payments by date (newest first)
      recentPayments.sort((a, b) {
        final aDate = a['updatedAt'] as DateTime?;
        final bDate = b['updatedAt'] as DateTime?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      // Take only the last 6 payments for display
      final displayPayments = recentPayments.take(6).toList();

      // Final mounted check before setState
      if (!mounted) return;

      setState(() {
        _paidCount = stats['paid'] ?? 0;
        _unpaidCount = stats['unpaid'] ?? 0;
        _advanceCount = stats['advance'] ?? 0;
        _totalAmount = (stats['paid']! + stats['advance']!) * 100.0;
        _recentPayments = displayPayments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading payment data: $e');
      // Check mounted before setState in error handler
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 8.sp),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            children: [
              SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12.sp),
              Text(
                'Loading payment status...',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.sp),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: Colors.blue,
                  size: 20.sp,
                ),
                SizedBox(width: 8.sp),
                Text(
                  'Monthly Dues',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadPaymentData,
                  icon: Icon(
                    Icons.refresh,
                    size: 18.sp,
                  ),
                  tooltip: 'Refresh payment status',
                ),
              ],
            ),
            SizedBox(height: 8.sp),
            // Summary Row - Always visible
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Paid',
                      _paidCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Unpaid',
                      _unpaidCount.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Advance',
                      _advanceCount.toString(),
                      Icons.fast_forward,
                      Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Total',
                      '₱${_totalAmount.toInt()}',
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Payments
                Text(
                  'Recent Payments',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.sp),

                if (_recentPayments.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.sp),
                    child: Center(
                      child: Text(
                        'No payment records found',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: _recentPayments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final payment = entry.value;
                      final isPaid = payment['isPaid'] as bool? ?? false;
                      final isAdvance = payment['isAdvance'] as bool? ?? false;
                      final month = payment['month'] as String? ?? '';
                      final amount = payment['amount'] as double? ?? 0.0;

                      // Determine icon and color based on payment status
                      IconData icon;
                      Color color;
                      String statusText;
                      Color statusColor;

                      if (isAdvance) {
                        icon = Icons.fast_forward;
                        color = Colors.purple;
                        statusText = 'ADVANCE';
                        statusColor = Colors.purple;
                      } else if (isPaid) {
                        icon = Icons.check_circle;
                        color = Colors.green;
                        statusText = 'PAID';
                        statusColor = Colors.green;
                      } else {
                        icon = Icons.cancel;
                        color = Colors.red;
                        statusText = 'UNPAID';
                        statusColor = Colors.red;
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.sp),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: color,
                              size: 16.sp,
                            )
                                .animate()
                                .fadeIn(delay: (800 + (index * 100)).ms, duration: 400.ms)
                                .scale(delay: (900 + (index * 100)).ms, duration: 300.ms, curve: Curves.easeOutBack),
                            SizedBox(width: 8.sp),
                            Expanded(
                              child: Text(
                                month,
                                style: TextStyle(fontSize: 12.sp),
                              )
                                  .animate()
                                  .fadeIn(delay: (850 + (index * 100)).ms, duration: 400.ms)
                                  .slideX(begin: 0.2, duration: 400.ms),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.sp,
                                vertical: 2.sp,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.sp),
                                border: Border.all(
                                  color: statusColor,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: (900 + (index * 100)).ms, duration: 400.ms)
                                .scale(delay: (950 + (index * 100)).ms, duration: 300.ms, curve: Curves.easeOutBack),
                            SizedBox(width: 8.sp),
                            Text(
                              '₱${amount.toInt()}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: (950 + (index * 100)).ms, duration: 400.ms)
                                .slideX(begin: 0.2, duration: 400.ms),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                SizedBox(height: 12.sp),

                // Payment Status Summary
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: _unpaidCount > 0 ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(
                      color: _unpaidCount > 0 ? Colors.orange : Colors.green,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _unpaidCount > 0 ? Icons.warning : Icons.check_circle,
                        color: _unpaidCount > 0 ? Colors.orange : Colors.green,
                        size: 16.sp,
                      )
                          .animate()
                          .fadeIn(delay: 1200.ms, duration: 400.ms)
                          .scale(delay: 1250.ms, duration: 300.ms, curve: Curves.easeOutBack),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Text(
                          _unpaidCount > 0
                              ? 'You have $_unpaidCount unpaid monthly due(s)'
                              : 'All payments are up to date!',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: _unpaidCount > 0 ? Colors.orange : Colors.green,
                          ),
                        ).animate().fadeIn(delay: 1250.ms, duration: 400.ms).slideX(begin: 0.2, duration: 400.ms),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1100.ms, duration: 600.ms).slideY(begin: 0.2, duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 250),
        )
        .fadeIn(
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 250),
        );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18.sp)
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
        SizedBox(height: 4.sp),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.2, duration: 600.ms),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey,
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, duration: 600.ms),
      ],
    );
  }
}
