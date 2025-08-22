import 'package:flutter/material.dart';
import '../widgets/daily_goal_widget.dart';
import '../widgets/task_list_widget.dart';
import '../models/study_session.dart';

class GoalScreen extends StatelessWidget {
  final int goalMinutes;
  final int studiedMinutes;
  final List<StudySession> sessions;
  final Function(int) onGoalChanged;

  const GoalScreen({
    super.key,
    required this.goalMinutes,
    required this.studiedMinutes,
    required this.sessions,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final headerFontSize = isSmallScreen ? 24.0 : 28.0;
    final iconSize = isSmallScreen ? 24.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with settings button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '🍉 Daily Goal',
                  style: TextStyle(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showGoalSettingDialog(context),
                icon: Icon(
                  Icons.settings,
                  color: const Color(0xFF2E7D32),
                  size: iconSize,
                ),
                tooltip: 'Set Daily Goal',
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),

          // Daily goal widget
          DailyGoalWidget(
            goalMinutes: goalMinutes,
            studiedMinutes: studiedMinutes,
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Today's sessions
          if (sessions.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                    'Today\'s Sessions',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  ...sessions.map((session) => _buildSessionItem(session)),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
          ],

          // Task list - now with constrained height
          Container(
            height:
                MediaQuery.of(context).size.height *
                0.7, // Take 50% of screen height
            child: const TaskListWidget(),
          ),

          // Add bottom padding for better scrolling experience
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildSessionItem(StudySession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD81B60).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFD81B60),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${session.duration} minutes',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            _formatTime(session.completedAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showGoalSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _GoalSettingDialog(
        currentGoalMinutes: goalMinutes,
        onGoalSet: onGoalChanged,
      ),
    );
  }
}

class _GoalSettingDialog extends StatefulWidget {
  final int currentGoalMinutes;
  final Function(int) onGoalSet;

  const _GoalSettingDialog({
    required this.currentGoalMinutes,
    required this.onGoalSet,
  });

  @override
  State<_GoalSettingDialog> createState() => _GoalSettingDialogState();
}

class _GoalSettingDialogState extends State<_GoalSettingDialog> {
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.currentGoalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final hours = _selectedMinutes ~/ 60;
    final minutes = _selectedMinutes % 60;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Text('🍉'),
          SizedBox(width: 8),
          Text('Set Daily Study Goal'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${hours}h ${minutes}m',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_selectedMinutes minutes',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Slider for goal setting
          Slider(
            value: _selectedMinutes.toDouble(),
            min: 15,
            max: 480, // 8 hours max
            divisions: 31, // 15-minute increments
            activeColor: const Color(0xFFD81B60),
            inactiveColor: const Color(0xFFD81B60).withValues(alpha: 0.3),
            onChanged: (value) {
              setState(() {
                _selectedMinutes =
                    (value / 15).round() * 15; // Round to 15-minute increments
              });
            },
          ),
          const SizedBox(height: 10),

          // Min/Max labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '15 min',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '8 hours',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick preset buttons
          const Text(
            'Quick Presets',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetButton('30m', 30),
              _buildPresetButton('1h', 60),
              _buildPresetButton('1.5h', 90),
              _buildPresetButton('2h', 120),
              _buildPresetButton('3h', 180),
              _buildPresetButton('4h', 240),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onGoalSet(_selectedMinutes);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Daily goal set to ${hours}h ${minutes}m!'),
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD81B60),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Set Goal'),
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, int minutes) {
    final isSelected = _selectedMinutes == minutes;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMinutes = minutes;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD81B60)
              : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD81B60)
                : Colors.grey.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
