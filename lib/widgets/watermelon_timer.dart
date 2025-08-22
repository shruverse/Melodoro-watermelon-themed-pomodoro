import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class WatermelonTimer extends StatefulWidget {
  final Function(int) onTimerComplete;

  const WatermelonTimer({super.key, required this.onTimerComplete});

  @override
  State<WatermelonTimer> createState() => WatermelonTimerState();
}

class WatermelonTimerState extends State<WatermelonTimer>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _totalSeconds = 1500; // 25 minutes default
  int _remainingSeconds = 1500;
  bool _isRunning = false;
  bool _isPaused = false;

  late AnimationController _progressController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _progressController.animateTo(
            1 - (_remainingSeconds / _totalSeconds),
          );
        } else {
          _completeTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _totalSeconds;
    });
    _progressController.reset();
  }

  void setTimer(int minutes) {
    if (_isRunning) return; // Don't allow setting timer while running

    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
      _isPaused = false;
    });
    _progressController.reset();
  }

  void _completeTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    widget.onTimerComplete(_totalSeconds ~/ 60);
    _showCompletionDialog();
    _resetTimer();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍉 Great Job!'),
        content: Text(
          'You completed ${_totalSeconds ~/ 60} minutes of focused study!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showTimerPicker() {
    showDialog(
      context: context,
      builder: (context) => _TimerPickerDialog(
        initialMinutes: _totalSeconds ~/ 60,
        onTimeSelected: (minutes) {
          setState(() {
            _totalSeconds = minutes * 60;
            _remainingSeconds = _totalSeconds;
          });
          _progressController.reset();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;

    // Responsive timer size
    final timerSize = isSmallScreen
        ? math.min(screenWidth * 0.7, 240.0)
        : math.min(screenWidth * 0.6, 280.0);

    // Responsive font sizes
    final timeFontSize = isSmallScreen ? 28.0 : 32.0;
    final statusFontSize = isSmallScreen ? 12.0 : 14.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timer display
        GestureDetector(
          onTap: _showTimerPicker,
          child: SizedBox(
            width: timerSize,
            height: timerSize,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _progressController,
                _pulseController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: WatermelonSlicePainter(
                    progress: _progressController.value,
                    isRunning: _isRunning,
                    pulseValue: _pulseController.value,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: timeFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isPaused
                              ? 'Paused'
                              : _isRunning
                              ? 'Studying...'
                              : 'Tap to set time',
                          style: TextStyle(
                            fontSize: statusFontSize,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 24 : 40),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isRunning && !_isPaused)
              _buildControlButton(
                icon: Icons.play_arrow,
                onPressed: _startTimer,
                color: const Color(0xFF4CAF50),
              ),
            if (_isRunning)
              _buildControlButton(
                icon: Icons.pause,
                onPressed: _pauseTimer,
                color: const Color(0xFFFF9800),
              ),
            if (_isPaused) ...[
              _buildControlButton(
                icon: Icons.play_arrow,
                onPressed: _startTimer,
                color: const Color(0xFF4CAF50),
              ),
              SizedBox(width: isSmallScreen ? 12 : 20),
            ],
            if (_isPaused || _isRunning)
              _buildControlButton(
                icon: Icons.stop,
                onPressed: _resetTimer,
                color: const Color(0xFFE91E63),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final buttonPadding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(buttonPadding),
      ),
      child: Icon(icon, size: iconSize),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class WatermelonSlicePainter extends CustomPainter {
  final double progress;
  final bool isRunning;
  final double pulseValue;

  WatermelonSlicePainter({
    required this.progress,
    required this.isRunning,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw watermelon rind (outer green circle)
    final rindPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, rindPaint);

    // Draw white layer
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius - 6, whitePaint);

    // Draw watermelon flesh background
    final fleshBgPaint = Paint()
      ..color = const Color(0xFFFFCDD2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 10, fleshBgPaint);

    // Draw progress (pink flesh) - filling from top, counter-clockwise
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = const Color(0xFFE91E63)
        ..style = PaintingStyle.fill;

      final progressPath = Path();
      progressPath.moveTo(center.dx, center.dy);
      progressPath.arcTo(
        Rect.fromCircle(center: center, radius: radius - 10),
        -math.pi / 2, // Start from top (12 o'clock)
        -2 * math.pi * progress, // Negative angle for counter-clockwise
        false,
      );
      progressPath.close();

      canvas.drawPath(progressPath, progressPaint);
    }

    // Draw seeds
    _drawSeeds(canvas, center, radius - 10);

    // Draw pulse effect when running
    if (isRunning) {
      final pulsePaint = Paint()
        ..color = const Color(
          0xFFE91E63,
        ).withValues(alpha: 0.3 * (1 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawCircle(center, radius + (pulseValue * 20), pulsePaint);
    }
  }

  void _drawSeeds(Canvas canvas, Offset center, double radius) {
    final seedPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.fill;

    final seedPositions = [
      Offset(center.dx - 30, center.dy - 20),
      Offset(center.dx + 25, center.dy - 35),
      Offset(center.dx - 15, center.dy + 30),
      Offset(center.dx + 40, center.dy + 15),
      Offset(center.dx - 45, center.dy + 10),
      Offset(center.dx + 10, center.dy - 50),
    ];

    for (final pos in seedPositions) {
      if ((pos - center).distance < radius - 20) {
        canvas.drawOval(
          Rect.fromCenter(center: pos, width: 8, height: 12),
          seedPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TimerPickerDialog extends StatefulWidget {
  final int initialMinutes;
  final Function(int) onTimeSelected;

  const _TimerPickerDialog({
    required this.initialMinutes,
    required this.onTimeSelected,
  });

  @override
  State<_TimerPickerDialog> createState() => _TimerPickerDialogState();
}

class _TimerPickerDialogState extends State<_TimerPickerDialog> {
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final hours = _selectedMinutes ~/ 60;
    final minutes = _selectedMinutes % 60;

    return AlertDialog(
      title: const Text('🍉 Set Study Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$_selectedMinutes minutes',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _selectedMinutes.toDouble(),
            min: 5,
            max: 300, // 5 hours
            divisions: 59, // 5-minute increments
            activeColor: const Color(0xFFE91E63),
            onChanged: (value) {
              setState(() {
                _selectedMinutes =
                    (value / 5).round() * 5; // Round to 5-minute increments
              });
            },
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5 min', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                '5 hours',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
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
            widget.onTimeSelected(_selectedMinutes);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
          ),
          child: const Text('Set Timer'),
        ),
      ],
    );
  }
}
