import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/models/payment_analytics.dart';

/// Pie chart widget displaying payment method distribution
class PaymentMethodPieChart extends StatelessWidget {
  const PaymentMethodPieChart({
    required this.paymentMethodStats,
    super.key,
  });

  final List<PaymentMethodStats> paymentMethodStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (paymentMethodStats.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: Text(
            'No payment method data available',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Methods Distribution',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h, // Fixed height to prevent overflow
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 2,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 150.w, // Constrain pie chart width
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sections: _buildSections(paymentMethodStats),
                          sectionsSpace: 2,
                          centerSpaceRadius: 30.r, // Reduced center space
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w), // Reduced spacing
                // Legend
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < paymentMethodStats.length; i++)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.h), // Reduced padding
                          child: _buildLegendItem(
                            paymentMethodStats[i],
                            _getMethodColor(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    List<PaymentMethodStats> stats,
  ) {
    return stats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;

      return PieChartSectionData(
        value: stat.percentage,
        title: '${stat.percentage.toStringAsFixed(1)}%',
        color: _getMethodColor(index),
        radius: 50.r, // Reduced radius
        titleStyle: TextStyle(
          fontSize: 10.sp, // Smaller font
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(PaymentMethodStats stat, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w, // Smaller indicator
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w), // Reduced spacing
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.displayName,
                style: TextStyle(
                  fontSize: 11.sp, // Smaller font
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${stat.count} payments • ₱${stat.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 9.sp, // Smaller font
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getMethodColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}
