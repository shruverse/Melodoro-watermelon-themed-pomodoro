import 'package:flutter/material.dart';
import '../models/study_session.dart';

class AchievementWidget extends StatelessWidget {
  final List<StudySession> sessions;

  const AchievementWidget({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress overview
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
                  'Achievement Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '${achievements.where((a) => a.isUnlocked).length}/${achievements.length} achievements unlocked',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Achievement list
          ...achievements.map(
            (achievement) => _buildAchievementCard(achievement),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: achievement.isUnlocked
            ? Border.all(color: const Color(0xFFD81B60), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? const Color(0xFFD81B60)
                  : Colors.grey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement.isUnlocked
                        ? Colors.grey
                        : Colors.grey.withValues(alpha: 0.7),
                  ),
                ),
                if (achievement.progress < achievement.target) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement.progress / achievement.target,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFD81B60),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.progress}/${achievement.target}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),

          // Unlocked indicator
          if (achievement.isUnlocked)
            const Icon(Icons.check_circle, color: Color(0xFFD81B60), size: 20),
        ],
      ),
    );
  }

  List<Achievement> _getAchievements() {
    final totalMinutes = sessions.fold(
      0,
      (sum, session) => sum + session.duration,
    );
    final totalSessions = sessions.length;
    final currentStreak = _getCurrentStreak();
    final longestStreak = _getLongestStreak();

    return [
      Achievement(
        title: 'First Steps',
        description: 'Complete your first study session',
        icon: Icons.play_arrow,
        target: 1,
        progress: totalSessions,
        isUnlocked: totalSessions >= 1,
      ),
      Achievement(
        title: 'Getting Started',
        description: 'Study for 1 hour total',
        icon: Icons.access_time,
        target: 60,
        progress: totalMinutes,
        isUnlocked: totalMinutes >= 60,
      ),
      Achievement(
        title: 'Dedicated Learner',
        description: 'Study for 10 hours total',
        icon: Icons.school,
        target: 600,
        progress: totalMinutes,
        isUnlocked: totalMinutes >= 600,
      ),
      Achievement(
        title: 'Study Master',
        description: 'Study for 50 hours total',
        icon: Icons.emoji_events,
        target: 3000,
        progress: totalMinutes,
        isUnlocked: totalMinutes >= 3000,
      ),
      Achievement(
        title: 'Consistency',
        description: 'Study for 3 days in a row',
        icon: Icons.local_fire_department,
        target: 3,
        progress: currentStreak,
        isUnlocked: currentStreak >= 3,
      ),
      Achievement(
        title: 'Week Warrior',
        description: 'Study for 7 days in a row',
        icon: Icons.calendar_view_week,
        target: 7,
        progress: currentStreak,
        isUnlocked: currentStreak >= 7,
      ),
      Achievement(
        title: 'Marathon Runner',
        description: 'Complete a 2-hour study session',
        icon: Icons.timer,
        target: 120,
        progress: sessions.isNotEmpty
            ? sessions.map((s) => s.duration).reduce((a, b) => a > b ? a : b)
            : 0,
        isUnlocked: sessions.any((session) => session.duration >= 120),
      ),
      Achievement(
        title: 'Century Club',
        description: 'Complete 100 study sessions',
        icon: Icons.stars,
        target: 100,
        progress: totalSessions,
        isUnlocked: totalSessions >= 100,
      ),
    ];
  }

  int _getCurrentStreak() {
    if (sessions.isEmpty) return 0;

    final today = DateTime.now();
    var currentDate = DateTime(today.year, today.month, today.day);
    var streak = 0;

    while (true) {
      final sessionsForDate = sessions.where((session) {
        final sessionDate = session.completedAt;
        return sessionDate.year == currentDate.year &&
            sessionDate.month == currentDate.month &&
            sessionDate.day == currentDate.day;
      }).toList();

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
    if (sessions.isEmpty) return 0;

    final sessionDates =
        sessions
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
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final int target;
  final int progress;
  final bool isUnlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.progress,
    required this.isUnlocked,
  });
}
