import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/models/payment_analytics.dart';

/// Line chart widget displaying monthly revenue trends
class RevenueTrendChart extends StatelessWidget {
  const RevenueTrendChart({
    required this.monthlyRevenues,
    super.key,
  });

  final List<MonthlyRevenue> monthlyRevenues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (monthlyRevenues.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: Text(
            'No revenue data available',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    // Prepare data points
    final spots = <FlSpot>[];
    for (var i = 0; i < monthlyRevenues.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyRevenues[i].totalAmount));
    }

    // Calculate max Y value with some padding
    final maxY = monthlyRevenues.isEmpty
        ? 1000.0
        : monthlyRevenues.map((e) => e.totalAmount).reduce((a, b) => a > b ? a : b) * 1.2;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Revenue Trend',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₱${(value / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.h,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyRevenues.length) {
                          return const SizedBox.shrink();
                        }

                        // Show month abbreviation
                        final monthDate = monthlyRevenues[index].monthDate;
                        final monthStr = DateFormat('MMM').format(monthDate);

                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            monthStr,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                    left: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                minX: 0,
                maxX: (monthlyRevenues.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: theme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: theme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= monthlyRevenues.length) {
                          return null;
                        }

                        final revenue = monthlyRevenues[index];
                        final monthDate = revenue.monthDate;
                        final monthStr = DateFormat('MMM yyyy').format(monthDate);

                        return LineTooltipItem(
                          '$monthStr\n₱${revenue.totalAmount.toStringAsFixed(2)}',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

