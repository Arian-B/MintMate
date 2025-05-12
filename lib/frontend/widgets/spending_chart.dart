import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SpendingChart extends StatelessWidget {
  final List<Map<String, dynamic>> spendingData;
  final String period;
  final bool isLoading;

  const SpendingChart({
    super.key,
    required this.spendingData,
    required this.period,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (spendingData.isEmpty) {
      return Center(
        child: Text(
          'No spending data available',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending Overview',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
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
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= spendingData.length) {
                        return const Text('');
                      }
                      final date = DateTime.parse(spendingData[value.toInt()]['date']);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          period == 'week'
                              ? DateFormat('E').format(date)
                              : DateFormat('MMM d').format(date),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spendingData.asMap().entries.map((e) {
                    return FlSpot(
                      e.key.toDouble(),
                      (e.value['amount'] as num).toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ),
              ],
              minY: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSpendingSummary(),
      ],
    );
  }

  Widget _buildSpendingSummary() {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    double totalSpent = 0;
    double averageSpent = 0;
    double highestSpent = 0;

    for (var data in spendingData) {
      final amount = (data['amount'] as num).toDouble();
      totalSpent += amount;
      if (amount > highestSpent) {
        highestSpent = amount;
      }
    }

    averageSpent = totalSpent / spendingData.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem('Total', currencyFormat.format(totalSpent)),
        _buildSummaryItem('Average', currencyFormat.format(averageSpent)),
        _buildSummaryItem('Highest', currencyFormat.format(highestSpent)),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 