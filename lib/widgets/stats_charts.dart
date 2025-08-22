import 'package:flutter/material.dart';
import '../models/study_session.dart';
import 'dart:math' as math;

class StatsCharts extends StatefulWidget {
  final List<StudySession> sessions;

  const StatsCharts({super.key, required this.sessions});

  @override
  State<StatsCharts> createState() => _StatsChartsState();
}

class _StatsChartsState extends State<StatsCharts> {
  String _selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: ['Week', 'Month', 'Year'].map((period) {
                final isSelected = _selectedPeriod == period;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD81B60)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        period,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Study time chart
          _buildStudyTimeChart(),

          const SizedBox(height: 20),

          // Daily pattern chart
          _buildDailyPatternChart(),

          const SizedBox(height: 20),

          // Session length distribution
          _buildSessionLengthChart(),
        ],
      ),
    );
  }

  Widget _buildStudyTimeChart() {
    final data = _getStudyTimeData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Time - $_selectedPeriod',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: BarChartPainter(data: data),
              size: const Size(double.infinity, 200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPatternChart() {
    final hourlyData = _getHourlyData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Study Pattern',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: LineChartPainter(data: hourlyData),
              size: const Size(double.infinity, 150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionLengthChart() {
    final lengthData = _getSessionLengthData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Length Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ...lengthData.entries.map((entry) {
            final maxValue = lengthData.values.reduce(math.max);
            final percentage = maxValue > 0 ? entry.value / maxValue : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 14)),
                      Text(
                        '${entry.value} sessions',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: const Color(0xFFF5F5F5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFD81B60),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<ChartData> _getStudyTimeData() {
    final now = DateTime.now();
    final data = <ChartData>[];

    switch (_selectedPeriod) {
      case 'Week':
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final sessions = widget.sessions
              .where(
                (session) =>
                    session.completedAt.year == date.year &&
                    session.completedAt.month == date.month &&
                    session.completedAt.day == date.day,
              )
              .toList();

          final totalMinutes = sessions.fold(
            0,
            (sum, session) => sum + session.duration,
          );
          data.add(
            ChartData(
              label: _getDayName(date.weekday),
              value: totalMinutes.toDouble(),
            ),
          );
        }
        break;

      case 'Month':
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final weeksInMonth = (daysInMonth / 7).ceil();

        for (int week = 0; week < weeksInMonth; week++) {
          final startDay = week * 7 + 1;
          final endDay = math.min((week + 1) * 7, daysInMonth);

          var totalMinutes = 0;
          for (int day = startDay; day <= endDay; day++) {
            final date = DateTime(now.year, now.month, day);
            final sessions = widget.sessions
                .where(
                  (session) =>
                      session.completedAt.year == date.year &&
                      session.completedAt.month == date.month &&
                      session.completedAt.day == date.day,
                )
                .toList();

            totalMinutes += sessions.fold(
              0,
              (sum, session) => sum + session.duration,
            );
          }

          data.add(
            ChartData(
              label: 'Week ${week + 1}',
              value: totalMinutes.toDouble(),
            ),
          );
        }
        break;

      case 'Year':
        for (int month = 1; month <= 12; month++) {
          final sessions = widget.sessions
              .where(
                (session) =>
                    session.completedAt.year == now.year &&
                    session.completedAt.month == month,
              )
              .toList();

          final totalMinutes = sessions.fold(
            0,
            (sum, session) => sum + session.duration,
          );
          data.add(
            ChartData(
              label: _getMonthName(month),
              value: totalMinutes.toDouble(),
            ),
          );
        }
        break;
    }

    return data;
  }

  Map<int, double> _getHourlyData() {
    final hourlyData = <int, double>{};

    // Initialize all hours with 0
    for (int hour = 0; hour < 24; hour++) {
      hourlyData[hour] = 0;
    }

    // Aggregate session data by hour
    for (final session in widget.sessions) {
      final hour = session.completedAt.hour;
      hourlyData[hour] = (hourlyData[hour] ?? 0) + session.duration.toDouble();
    }

    return hourlyData;
  }

  Map<String, int> _getSessionLengthData() {
    final lengthData = <String, int>{
      '0-15 min': 0,
      '15-30 min': 0,
      '30-60 min': 0,
      '60-90 min': 0,
      '90+ min': 0,
    };

    for (final session in widget.sessions) {
      if (session.duration <= 15) {
        lengthData['0-15 min'] = lengthData['0-15 min']! + 1;
      } else if (session.duration <= 30) {
        lengthData['15-30 min'] = lengthData['15-30 min']! + 1;
      } else if (session.duration <= 60) {
        lengthData['30-60 min'] = lengthData['30-60 min']! + 1;
      } else if (session.duration <= 90) {
        lengthData['60-90 min'] = lengthData['60-90 min']! + 1;
      } else {
        lengthData['90+ min'] = lengthData['90+ min']! + 1;
      }
    }

    return lengthData;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData({required this.label, required this.value});
}

class BarChartPainter extends CustomPainter {
  final List<ChartData> data;

  BarChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFD81B60)
      ..style = PaintingStyle.fill;

    final maxValue = data.map((d) => d.value).reduce(math.max);
    if (maxValue == 0) return;

    final barWidth = size.width / data.length * 0.7;
    final spacing = size.width / data.length * 0.3;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i].value / maxValue) * (size.height - 40);
      final x = i * (barWidth + spacing) + spacing / 2;
      final y = size.height - barHeight - 20;

      // Draw bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].label,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineChartPainter extends CustomPainter {
  final Map<int, double> data;

  LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFD81B60)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFFD81B60)
      ..style = PaintingStyle.fill;

    final maxValue = data.values.reduce(math.max);
    if (maxValue == 0) return;

    final path = Path();
    final points = <Offset>[];

    for (int hour = 0; hour < 24; hour++) {
      final x = (hour / 23) * size.width;
      final y = size.height - ((data[hour] ?? 0) / maxValue) * size.height;

      points.add(Offset(x, y));

      if (hour == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
