import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/models/payment_analytics.dart';

/// Bar chart widget displaying payment compliance rates by month
class ComplianceChart extends StatelessWidget {
  const ComplianceChart({
    required this.complianceRates,
    super.key,
  });

  final List<ComplianceRate> complianceRates;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (complianceRates.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: Text(
            'No compliance data available',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    // Prepare bar groups
    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < complianceRates.length; i++) {
      final compliance = complianceRates[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: compliance.compliancePercentage,
              color: _getComplianceColor(compliance.compliancePercentage),
              width: 16.w,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.r),
                topRight: Radius.circular(4.r),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Compliance Rate',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Percentage of members who paid on time',
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
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
                      reservedSize: 40.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
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
                        if (index < 0 || index >= complianceRates.length) {
                          return const SizedBox.shrink();
                        }

                        final monthDate = complianceRates[index].monthDate;
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
                barGroups: barGroups,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final index = group.x;
                      if (index < 0 || index >= complianceRates.length) {
                        return null;
                      }

                      final compliance = complianceRates[index];
                      final monthDate = compliance.monthDate;
                      final monthStr = DateFormat('MMM yyyy').format(monthDate);

                      return BarTooltipItem(
                        '$monthStr\n',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${compliance.compliancePercentage.toStringAsFixed(1)}%\n',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${compliance.paidCount + compliance.waivedCount}/${compliance.totalExpected} paid',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Excellent (>90%)', Colors.green),
              SizedBox(width: 16.w),
              _buildLegendItem('Good (70-90%)', Colors.orange),
              SizedBox(width: 16.w),
              _buildLegendItem('Poor (<70%)', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Color _getComplianceColor(double percentage) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
