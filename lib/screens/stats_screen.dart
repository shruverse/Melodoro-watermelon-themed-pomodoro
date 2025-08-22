import 'package:flutter/material.dart';
import '../models/study_session.dart';
import '../widgets/stats_charts.dart';
import '../widgets/achievement_widget.dart';
import 'dart:math' as math;

class StatsScreen extends StatefulWidget {
  final List<StudySession> allSessions;

  const StatsScreen({super.key, required this.allSessions});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              '🍉 Study Statistics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFD81B60),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Charts'),
                Tab(text: 'Achievements'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildChartsTab(),
                _buildAchievementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final today = DateTime.now();
    final todaySessions = _getSessionsForDate(today);
    final thisWeekSessions = _getSessionsForWeek(today);
    final thisMonthSessions = _getSessionsForMonth(today);

    final todayMinutes = _getTotalMinutes(todaySessions);
    final weekMinutes = _getTotalMinutes(thisWeekSessions);
    final monthMinutes = _getTotalMinutes(thisMonthSessions);
    final totalMinutes = _getTotalMinutes(widget.allSessions);

    final currentStreak = _getCurrentStreak();
    final longestStreak = _getLongestStreak();
    final averageSessionLength = _getAverageSessionLength();
    final totalSessions = widget.allSessions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Time stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today',
                  _formatDuration(todayMinutes),
                  Icons.today,
                  const Color(0xFFD81B60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'This Week',
                  _formatDuration(weekMinutes),
                  Icons.calendar_view_week,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'This Month',
                  _formatDuration(monthMinutes),
                  Icons.calendar_month,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'All Time',
                  _formatDuration(totalMinutes),
                  Icons.all_inclusive,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Streak and session stats
          Container(
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
                  'Study Habits',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildHabitRow(
                  'Current Streak',
                  '$currentStreak days',
                  Icons.local_fire_department,
                ),
                const SizedBox(height: 12),
                _buildHabitRow(
                  'Longest Streak',
                  '$longestStreak days',
                  Icons.emoji_events,
                ),
                const SizedBox(height: 12),
                _buildHabitRow('Total Sessions', '$totalSessions', Icons.timer),
                const SizedBox(height: 12),
                _buildHabitRow(
                  'Avg Session',
                  _formatDuration(averageSessionLength),
                  Icons.access_time,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Best study times
          _buildBestStudyTimes(),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return StatsCharts(sessions: widget.allSessions);
  }

  Widget _buildAchievementsTab() {
    return AchievementWidget(sessions: widget.allSessions);
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD81B60)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD81B60),
          ),
        ),
      ],
    );
  }

  Widget _buildBestStudyTimes() {
    final hourlyStats = _getHourlyStats();
    final bestHours =
        hourlyStats.entries.where((entry) => entry.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

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
            'Best Study Times',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (bestHours.isEmpty)
            const Text(
              'No study sessions yet!',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...bestHours.take(5).map((entry) {
              final hour = entry.key;
              final minutes = entry.value;
              final timeString = _formatHour(hour);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(timeString, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: minutes / bestHours.first.value,
                        backgroundColor: const Color(0xFFF5F5F5),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFD81B60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _formatDuration(minutes),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD81B60),
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

  // Helper methods
  List<StudySession> _getSessionsForDate(DateTime date) {
    return widget.allSessions.where((session) {
      return session.completedAt.year == date.year &&
          session.completedAt.month == date.month &&
          session.completedAt.day == date.day;
    }).toList();
  }

  List<StudySession> _getSessionsForWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return widget.allSessions.where((session) {
      return session.completedAt.isAfter(
            startOfWeek.subtract(const Duration(days: 1)),
          ) &&
          session.completedAt.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  List<StudySession> _getSessionsForMonth(DateTime date) {
    return widget.allSessions.where((session) {
      return session.completedAt.year == date.year &&
          session.completedAt.month == date.month;
    }).toList();
  }

  int _getTotalMinutes(List<StudySession> sessions) {
    return sessions.fold(0, (sum, session) => sum + session.duration);
  }

  int _getCurrentStreak() {
    if (widget.allSessions.isEmpty) return 0;

    final today = DateTime.now();
    var currentDate = DateTime(today.year, today.month, today.day);
    var streak = 0;

    while (true) {
      final sessionsForDate = _getSessionsForDate(currentDate);
      if (sessionsForDate.isNotEmpty) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  int _getLongestStreak() {
    if (widget.allSessions.isEmpty) return 0;

    final sessionDates =
        widget.allSessions
            .map(
              (session) => DateTime(
                session.completedAt.year,
                session.completedAt.month,
                session.completedAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();

    if (sessionDates.isEmpty) return 0;

    var longestStreak = 1;
    var currentStreak = 1;

    for (int i = 1; i < sessionDates.length; i++) {
      final daysDiff = sessionDates[i].difference(sessionDates[i - 1]).inDays;

      if (daysDiff == 1) {
        currentStreak++;
        longestStreak = math.max(longestStreak, currentStreak);
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  int _getAverageSessionLength() {
    if (widget.allSessions.isEmpty) return 0;
    final totalMinutes = _getTotalMinutes(widget.allSessions);
    return totalMinutes ~/ widget.allSessions.length;
  }

  Map<int, int> _getHourlyStats() {
    final hourlyStats = <int, int>{};

    for (final session in widget.allSessions) {
      final hour = session.completedAt.hour;
      hourlyStats[hour] = (hourlyStats[hour] ?? 0) + session.duration;
    }

    return hourlyStats;
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '${hour}:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}
