import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحليلات المبيعات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSalesChart(),
            const SizedBox(height: 20),
            _buildTopProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'المبيعات الأسبوعية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: StreamBuilder<List<OrderModel>>(
                stream: _db.allOrders,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final orders = snapshot.data!;
                  // Calculate daily sales for last 7 days
                  final now = DateTime.now();
                  final List<double> dailyTotals = List.filled(7, 0.0);
                  final List<String> weekDays = [];

                  for (int i = 6; i >= 0; i--) {
                    final day = now.subtract(Duration(days: i));
                    weekDays.add(DateFormat.E('ar').format(day));

                    final dayOrders = orders.where((o) =>
                        o.date.year == day.year &&
                        o.date.month == day.month &&
                        o.date.day == day.day);

                    double total = 0;
                    for (var o in dayOrders) {
                      total += o.totalAmount;
                    }
                    dailyTotals[6 - i] = total;
                  }

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: dailyTotals.reduce((a, b) => a > b ? a : b) * 1.2 +
                          100, // Dynamic max Y
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()} EGP',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < 0 ||
                                  value.toInt() >= weekDays.length) {
                                return const Text('');
                              }
                              return Text(weekDays[value.toInt()],
                                  style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: dailyTotals[index],
                              color: Colors.red,
                              width: 15,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('سيتم إضافة المنتجات الأكثر مبيعاً لاحقاً',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
