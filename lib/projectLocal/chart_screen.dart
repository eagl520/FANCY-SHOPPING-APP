import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ShoppingAnalyticsScreen extends StatefulWidget {
  const ShoppingAnalyticsScreen({super.key});

  @override
  State<ShoppingAnalyticsScreen> createState() => _ShoppingAnalyticsScreenState();
}

class _ShoppingAnalyticsScreenState extends State<ShoppingAnalyticsScreen> {
  int _selectedPeriodIndex = 0; // 0: Week, 1: Month, 2: Year
  final List<String> _periods = ['Week', 'Month', 'Year'];

  // Sample dynamic data points
  final List<List<FlSpot>> _chartData = [
    // Week (Mon - Sun)
    const [FlSpot(0, 45), FlSpot(1, 80), FlSpot(2, 30), FlSpot(3, 120), FlSpot(4, 95), FlSpot(5, 150), FlSpot(6, 60)],
    // Month (4 Weeks)
    const [FlSpot(0, 320), FlSpot(1, 450), FlSpot(2, 280), FlSpot(3, 510)],
    // Year (4 Quarters)
    const [FlSpot(0, 1200), FlSpot(1, 1900), FlSpot(2, 1400), FlSpot(3, 2200)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Spending Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter Selector
            _buildPeriodSelector(),
            const SizedBox(height: 20),

            // Total Spend Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 24),

            // Line Chart Section
            const Text('Spending Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildChartCard(),
            const SizedBox(height: 28),

            // Category Breakdown List
            const Text('Top Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildCategoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_periods.length, (index) {
        final isSelected = _selectedPeriodIndex == index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text(_periods[index]),
            selected: isSelected,
            selectedColor: Colors.deepPurple,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (selected) {
              if (selected) setState(() => _selectedPeriodIndex = index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Total Expenses', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          Text('\$580.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('↓ 12% compared to last period', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 220,
      padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < days.length && _selectedPeriodIndex == 0) {
                    return Text(days[value.toInt()], style: const TextStyle(fontSize: 12, color: Colors.grey));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _chartData[_selectedPeriodIndex],
              isCurved: true,
              color: Colors.deepPurple,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepPurple.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {'name': 'Electronics', 'amount': '\$320.00', 'icon': Icons.devices, 'color': Colors.blue},
      {'name': 'Clothing', 'amount': '\$180.00', 'icon': Icons.checkroom, 'color': Colors.orange},
      {'name': 'Groceries', 'amount': '\$80.00', 'icon': Icons.shopping_bag, 'color': Colors.green},
    ];

    return Column(
      children: categories.map((cat) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (cat['color'] as Color).withOpacity(0.15),
              child: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
            ),
            title: Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Text(cat['amount'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      }).toList(),
    );
  }
}