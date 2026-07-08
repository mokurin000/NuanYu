import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/mood_utils.dart';
import 'providers/mood_provider.dart';

class MoodTrendChart extends ConsumerStatefulWidget {
  const MoodTrendChart({super.key});

  @override
  ConsumerState<MoodTrendChart> createState() => _MoodTrendChartState();
}

class _MoodTrendChartState extends ConsumerState<MoodTrendChart> {
  bool _isWeekly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final now = DateTime.now();
    if (_isWeekly) {
      final start = now.subtract(const Duration(days: 6));
      ref.read(moodProvider.notifier).loadByDateRange(start, now);
    } else {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      ref.read(moodProvider.notifier).loadByDateRange(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodProvider);
    final entries = state.entries;

    // Group entries by date and take average
    final groupedByDate = <String, List<int>>{};
    for (final e in entries) {
      groupedByDate.putIfAbsent(e.date, () => []).add(e.moodScore);
    }

    final dailyAverages = groupedByDate.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return MapEntry(e.key, avg);
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = <FlSpot>[];
    for (var i = 0; i < dailyAverages.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyAverages[i].value));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('情绪趋势'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ToggleChip(
                  label: '本周',
                  isSelected: _isWeekly,
                  onTap: () {
                    setState(() => _isWeekly = true);
                    _loadData();
                  },
                ),
                const SizedBox(width: 12),
                _ToggleChip(
                  label: '本月',
                  isSelected: !_isWeekly,
                  onTap: () {
                    setState(() => _isWeekly = false);
                    _loadData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Chart
            Expanded(
              child: spots.isEmpty
                  ? const Center(
                      child: Text('暂无数据', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 2,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: AppColors.textSecondary.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          ),
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= 0 && idx < dailyAverages.length) {
                                  final date = dailyAverages[idx].key;
                                  final parts = date.split('-');
                                  return Text(
                                    '${parts[1]}/${parts[2]}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 2,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: AppColors.primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: moodColor(spot.y.round()),
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                            ),
                          ),
                          // Average line
                          if (dailyAverages.isNotEmpty)
                            LineChartBarData(
                              spots: [
                                FlSpot(0, _averageScore(dailyAverages)),
                                FlSpot(
                                  (dailyAverages.length - 1).toDouble(),
                                  _averageScore(dailyAverages),
                                ),
                              ],
                              isCurved: false,
                              color: AppColors.accentColor.withValues(alpha: 0.5),
                              barWidth: 1,
                              dotData: const FlDotData(show: false),
                              dashArray: [5, 5],
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _averageScore(List<MapEntry<String, double>> dailyAverages) {
    if (dailyAverages.isEmpty) return 5;
    return dailyAverages.map((e) => e.value).reduce((a, b) => a + b) / dailyAverages.length;
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

