import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsDetailScreen extends StatefulWidget {
  final String title;
  final Color themeColor;
  final bool isBmi;
  final double todayValue; // Nhận giá trị thực tế truyền từ Dashboard sang

  const StatsDetailScreen({
    super.key,
    required this.title,
    required this.themeColor,
    this.isBmi = false,
    required this.todayValue, // Bắt buộc truyền giá trị
  });

  @override
  State<StatsDetailScreen> createState() => _StatsDetailScreenState();
}

class _StatsDetailScreenState extends State<StatsDetailScreen> {
  int _selectedTimeIndex = 0; // Mặc định hiển thị Tab "Ngày" để thấy ngay dữ liệu hôm nay

  @override
  Widget build(BuildContext context) {
    // Tạo mảng dữ liệu dựa trên giá trị thực tế truyền sang
    List<double> chartData = _processData();
    double summaryValue = _selectedTimeIndex == 0 ? widget.todayValue : _calculateSummaryValue(chartData);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(widget.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildTimeSelector(),
          const SizedBox(height: 40),
          _buildTotalSummary(summaryValue),
          const SizedBox(height: 40),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 24, left: 16),
              child: summaryValue == 0 && _selectedTimeIndex == 0
                  ? Center(child: Text('Không có dữ liệu ghi nhận', style: TextStyle(color: Colors.grey[400])))
                  : _buildBarChart(chartData),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // --- PHÂN PHỐI DỮ LIỆU ĐỒNG BỘ TỪ NGÀY SANG TUẦN/THÁNG ---
  List<double> _processData() {
    DateTime now = DateTime.now();

    // 1. TAB NGÀY: Hiển thị chuẩn xác con số hôm nay
    if (_selectedTimeIndex == 0) {
      return [widget.todayValue];
    }

    // 2. TAB TUẦN: Đặt dữ liệu hôm nay vào đúng thứ trong tuần thực tế
    if (_selectedTimeIndex == 1) {
      List<double> weekData = List.filled(7, 0.0);
      int currentDayIndex = now.weekday - 1; // Thứ 2 = 0, CN = 6
      weekData[currentDayIndex] = widget.todayValue;
      return weekData;
    }

    // 3. TAB THÁNG: Đặt dữ liệu vào tuần hiện tại của tháng
    List<double> monthData = List.filled(4, 0.0);
    monthData[3] = widget.todayValue; // Giả định nằm ở mốc tuần gần nhất
    return monthData;
  }

  double _calculateSummaryValue(List<double> data) {
    if (data.isEmpty) return 0.0;
    double sum = data.fold(0, (p, c) => p + c);
    int activeDays = data.where((v) => v > 0).length;
    return activeDays > 0 ? sum / activeDays : 0.0;
  }

  Widget _buildTimeSelector() {
    List<String> times = ['Ngày', 'Tuần', 'Tháng'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(times.length, (index) {
          bool isSelected = _selectedTimeIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    times[index],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTotalSummary(double value) {
    String unit = widget.isBmi ? '' : 'kcal';
    String formattedValue = widget.isBmi ? value.toStringAsFixed(1) : value.toInt().toString();

    String subtitle = _selectedTimeIndex == 0
        ? (widget.isBmi ? 'Chỉ số BMI hôm nay' : 'Tổng calo hôm nay')
        : (widget.isBmi ? 'BMI trung bình khoảng này' : 'Trung bình mỗi ngày');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formattedValue, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1)),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(unit, style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      ],
    );
  }

  Widget _buildBarChart(List<double> currentData) {
    double maxY = widget.isBmi ? 40 : (widget.todayValue > 4000 ? widget.todayValue + 1000 : 4000);
    double intervalY = widget.isBmi ? 10 : (maxY / 4);

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(widget.isBmi ? 1 : 0)} ${widget.isBmi ? '' : 'kcal'}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: intervalY,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > maxY) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                List<String> labels;
                if (_selectedTimeIndex == 0) {
                  labels = ['Hôm nay'];
                } else if (_selectedTimeIndex == 1) {
                  labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                } else {
                  labels = ['Tuần 1', 'Tuần 2', 'Tuần 3', 'Tuần 4'];
                }

                if (value.toInt() < 0 || value.toInt() >= labels.length) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    labels[value.toInt()],
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: intervalY,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[200], strokeWidth: 1, dashArray: [4, 4]);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(currentData.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: currentData[index],
                color: widget.themeColor,
                width: _selectedTimeIndex == 0 ? 32 : 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 300),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}