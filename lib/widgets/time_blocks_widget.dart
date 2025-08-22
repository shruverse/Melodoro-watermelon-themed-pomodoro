import 'package:flutter/material.dart';
import '../models/study_session.dart';

enum TimeBlockViewType { day, month, year }

class TimeBlocksWidget extends StatelessWidget {
  final List<StudySession> sessions;
  final DateTime selectedDate;
  final TimeBlockViewType viewType;
  final Function(DateTime) onDateChanged;

  const TimeBlocksWidget({
    super.key,
    required this.sessions,
    required this.selectedDate,
    required this.viewType,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewType) {
      case TimeBlockViewType.day:
        return _buildDayView(context);
      case TimeBlockViewType.month:
        return _buildMonthView(context);
      case TimeBlockViewType.year:
        return _buildYearView(context);
    }
  }

  Widget _buildDayView(BuildContext context) {
    return Column(
      children: [
        // Date navigation
        _buildDateNavigation(context),
        const SizedBox(height: 20),

        // 24-hour timeline
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
            child: _buildTimelineView(),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView(BuildContext context) {
    return Column(
      children: [
        _buildMonthNavigation(context),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
            child: _buildCalendarGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildYearView(BuildContext context) {
    return Column(
      children: [
        _buildYearNavigation(context),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
            child: _buildYearGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateNavigation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              onDateChanged(selectedDate.subtract(const Duration(days: 1)));
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            _formatDate(selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              onDateChanged(selectedDate.add(const Duration(days: 1)));
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              final newDate = DateTime(
                selectedDate.year,
                selectedDate.month - 1,
              );
              onDateChanged(newDate);
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            _formatMonth(selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              final newDate = DateTime(
                selectedDate.year,
                selectedDate.month + 1,
              );
              onDateChanged(newDate);
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildYearNavigation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              onDateChanged(
                DateTime(selectedDate.year - 1, selectedDate.month),
              );
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            selectedDate.year.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              onDateChanged(
                DateTime(selectedDate.year + 1, selectedDate.month),
              );
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Timeline header
          Row(
            children: [
              const SizedBox(width: 60),
              Expanded(
                child: Text(
                  _formatDate(selectedDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 24-hour blocks
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                final hour = index;
                final hasSession = _hasSessionAtHour(hour);
                final sessionMinutes = _getSessionMinutesAtHour(hour);

                return Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      // Hour label
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      // Time block
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasSession
                                ? const Color(0xFFD81B60).withValues(alpha: 0.8)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: hasSession
                              ? Center(
                                  child: Text(
                                    '${sessionMinutes}m',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month header
          Text(
            _formatMonth(selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder: (context, index) {
                final dayNumber = index - startingWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox();
                }

                final date = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  dayNumber,
                );
                final studyMinutes = _getStudyMinutesForDate(date);
                final intensity = _getIntensity(studyMinutes);

                return GestureDetector(
                  onTap: () => onDateChanged(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getColorForIntensity(intensity),
                      borderRadius: BorderRadius.circular(8),
                      border: _isSameDay(date, selectedDate)
                          ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: intensity > 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Legend
          const SizedBox(height: 16),
          _buildIntensityLegend(),
        ],
      ),
    );
  }

  Widget _buildYearGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            selectedDate.year.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final monthDate = DateTime(selectedDate.year, month);
                final studyMinutes = _getStudyMinutesForMonth(monthDate);
                final intensity = _getIntensity(studyMinutes);

                return GestureDetector(
                  onTap: () => onDateChanged(monthDate),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getColorForIntensity(intensity),
                      borderRadius: BorderRadius.circular(8),
                      border: month == selectedDate.month
                          ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _getMonthName(month),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: intensity > 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          _buildIntensityLegend(),
        ],
      ),
    );
  }

  Widget _buildIntensityLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Less', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _getColorForIntensity(index),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        const Text('More', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Helper methods
  bool _hasSessionAtHour(int hour) {
    return sessions.any((session) {
      final sessionHour = session.completedAt.hour;
      return _isSameDay(session.completedAt, selectedDate) &&
          sessionHour == hour;
    });
  }

  int _getSessionMinutesAtHour(int hour) {
    return sessions
        .where(
          (session) =>
              _isSameDay(session.completedAt, selectedDate) &&
              session.completedAt.hour == hour,
        )
        .fold(0, (sum, session) => sum + session.duration);
  }

  int _getStudyMinutesForDate(DateTime date) {
    return sessions
        .where((session) => _isSameDay(session.completedAt, date))
        .fold(0, (sum, session) => sum + session.duration);
  }

  int _getStudyMinutesForMonth(DateTime monthDate) {
    return sessions
        .where(
          (session) =>
              session.completedAt.year == monthDate.year &&
              session.completedAt.month == monthDate.month,
        )
        .fold(0, (sum, session) => sum + session.duration);
  }

  int _getIntensity(int minutes) {
    if (minutes == 0) return 0;
    if (minutes < 30) return 1;
    if (minutes < 60) return 2;
    if (minutes < 120) return 3;
    return 4;
  }

  Color _getColorForIntensity(int intensity) {
    switch (intensity) {
      case 0:
        return const Color(0xFFF5F5F5);
      case 1:
        return const Color(0xFFD81B60).withValues(alpha: 0.3);
      case 2:
        return const Color(0xFFD81B60).withValues(alpha: 0.5);
      case 3:
        return const Color(0xFFD81B60).withValues(alpha: 0.7);
      case 4:
        return const Color(0xFFD81B60);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
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
