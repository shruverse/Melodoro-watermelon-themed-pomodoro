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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final headerFontSize = isSmallScreen ? 24.0 : 28.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          // Header
          Text(
            '🍉 Study Timer',
            style: TextStyle(
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),

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
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
            child: Column(
              children: [
                Text(
                  'Quick Start',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                // Responsive button layout
                isSmallScreen
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPresetButton(context, '15 min', 15),
                              _buildPresetButton(context, '25 min', 25),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPresetButton(context, '45 min', 45),
                              _buildPresetButton(context, '60 min', 60),
                            ],
                          ),
                        ],
                      )
                    : Row(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final buttonWidth = isSmallScreen ? screenWidth * 0.4 : null;

    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 10 : 12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
