import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/models/payment_statistics.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/app/pages/payment_history_page.dart';

/// Simplified payment status card showing summary with link to detailed page
class PaymentStatusCardNew extends StatefulWidget {
  const PaymentStatusCardNew({required this.userId, super.key});

  final String userId;

  @override
  State<PaymentStatusCardNew> createState() => _PaymentStatusCardNewState();
}

class _PaymentStatusCardNewState extends State<PaymentStatusCardNew> {
  bool _isLoading = true;
  PaymentStatistics? _statistics;

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
      final statistics = await pocketBaseService.getPaymentStatistics(widget.userId);

      if (mounted) {
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        margin: EdgeInsets.all(16.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_statistics == null) {
      return Card(
        margin: EdgeInsets.all(16.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 32.sp, color: Colors.red),
              SizedBox(height: 8.h),
              Text(
                'Unable to load payment data',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                'Please try again later',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      // margin: EdgeInsets.all(16.w),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const PaymentHistoryPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payment, size: 20.sp, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Text(
                    'Payment Status',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
                ],
              ),
              SizedBox(height: 12.h),
              _buildSummaryRow(),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 14.sp),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Tap to view detailed payment history',
                        style: TextStyle(fontSize: 10.sp, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Total',
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
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
      ],
    );
  }
}
