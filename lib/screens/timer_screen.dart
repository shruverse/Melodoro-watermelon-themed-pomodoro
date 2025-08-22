import 'package:flutter/material.dart';
import '../widgets/watermelon_timer.dart';

class TimerScreen extends StatefulWidget {
  final Function(int) onTimerComplete;

  const TimerScreen({super.key, required this.onTimerComplete});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final GlobalKey<WatermelonTimerState> _timerKey =
      GlobalKey<WatermelonTimerState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          const Text(
            '🍉 Study Timer',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),

          // Main timer
          Expanded(
            child: Center(
              child: WatermelonTimer(
                key: _timerKey,
                onTimerComplete: widget.onTimerComplete,
              ),
            ),
          ),

          // Quick timer presets
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text(
                  'Quick Start',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPresetButton(context, '15 min', 15),
                    _buildPresetButton(context, '25 min', 25),
                    _buildPresetButton(context, '45 min', 45),
                    _buildPresetButton(context, '60 min', 60),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(BuildContext context, String label, int minutes) {
    return ElevatedButton(
      onPressed: () {
        _timerKey.currentState?.setTimer(minutes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timer set to $minutes minutes'),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
