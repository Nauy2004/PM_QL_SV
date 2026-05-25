import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../domain/models/bmi_record.dart';

class ChartsTab extends StatefulWidget {
  const ChartsTab({super.key});

  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  String _filter = 'All';

  List<BmiRecord> _filterRecords(List<BmiRecord> records) {
    DateTime now = DateTime.now();
    if (_filter == 'Week') {
      return records.where((r) => now.difference(r.timestamp).inDays <= 7).toList();
    } else if (_filter == 'Month') {
      return records.where((r) => now.difference(r.timestamp).inDays <= 30).toList();
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) return const Center(child: Text('Vui lòng đăng nhập'));

    return StreamBuilder<List<BmiRecord>>(
      stream: DatabaseService(uid: user.uid).bmiHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu để phân tích'));
        }

        List<BmiRecord> allRecords = snapshot.data!.reversed.toList();
        List<BmiRecord> filteredRecords = _filterRecords(allRecords);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (filteredRecords.isNotEmpty) ...[
                const Text('Biến động BMI', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(height: 200, child: _lineChart(filteredRecords, context)),
                const SizedBox(height: 40),
                const Text('Biến động Cân nặng (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(height: 200, child: _barChart(filteredRecords, context)),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _lineChart(List<BmiRecord> records, BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: records.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.bmi)).toList(),
            isCurved: true,
            color: primaryColor,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            // ĐÃ SỬA LỖI Ở ĐÂY: belowBarData thay vì belowArea
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barChart(List<BmiRecord> records, BuildContext context) {
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: records.asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value.weight,
              color: tertiaryColor,
              width: 20,
            )
          ],
        )).toList(),
      ),
    );
  }
}