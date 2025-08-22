import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'stats_blocks_screen.dart';
import 'goal_screen.dart';
import '../models/study_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Start with timer (middle) page
  int dailyGoalMinutes = 120; // 2 hours default
  int studiedMinutesToday = 0;
  List<StudySession> todaySessions = [];

  void _onTimerComplete(int minutes) {
    setState(() {
      studiedMinutesToday += minutes;
      todaySessions.add(
        StudySession(duration: minutes, completedAt: DateTime.now()),
      );
    });
  }

  void _onGoalChanged(int newGoalMinutes) {
    setState(() {
      dailyGoalMinutes = newGoalMinutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      StatsBlocksScreen(sessions: todaySessions),
      TimerScreen(onTimerComplete: _onTimerComplete),
      GoalScreen(
        goalMinutes: dailyGoalMinutes,
        studiedMinutes: studiedMinutesToday,
        sessions: todaySessions,
        onGoalChanged: _onGoalChanged,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD81B60), // Darker pink
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: 'Goal'),
        ],
      ),
    );
  }
}
