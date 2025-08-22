import 'package:flutter/material.dart';
import 'dart:math' as math;

class DailyGoalWidget extends StatefulWidget {
  final int goalMinutes;
  final int studiedMinutes;

  const DailyGoalWidget({
    super.key,
    required this.goalMinutes,
    required this.studiedMinutes,
  });

  @override
  State<DailyGoalWidget> createState() => _DailyGoalWidgetState();
}

class _DailyGoalWidgetState extends State<DailyGoalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fillAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.studiedMinutes / widget.goalMinutes,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(DailyGoalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studiedMinutes != widget.studiedMinutes) {
      _fillAnimation =
          Tween<double>(
            begin: _fillAnimation.value,
            end: math.min(1.0, widget.studiedMinutes / widget.goalMinutes),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.studiedMinutes / widget.goalMinutes;
    final isCompleted = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🍉 Daily Study Goal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Watermelon glass with juice
          Center(
            child: Container(
              width: 120,
              height: 140,
              child: AnimatedBuilder(
                animation: _fillAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WatermelonGlassPainter(
                      fillLevel: _fillAnimation.value,
                      isCompleted: isCompleted,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.studiedMinutes ~/ 60}h ${widget.studiedMinutes % 60}m studied',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Goal: ${widget.goalMinutes ~/ 60}h ${widget.goalMinutes % 60}m',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress bar
          LinearProgressIndicator(
            value: math.min(1.0, progress),
            backgroundColor: const Color(0xFFE8F5E8),
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFE91E63),
            ),
            minHeight: 6,
          ),

          const SizedBox(height: 8),

          // Percentage text
          Text(
            '${(progress * 100).toInt()}% complete',
            style: TextStyle(
              fontSize: 12,
              color: isCompleted
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE91E63),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class WatermelonGlassPainter extends CustomPainter {
  final double fillLevel;
  final bool isCompleted;

  WatermelonGlassPainter({required this.fillLevel, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw glass outline
    final glassPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final glassPath = Path();
    glassPath.moveTo(size.width * 0.2, size.height * 0.1);
    glassPath.lineTo(size.width * 0.8, size.height * 0.1);
    glassPath.lineTo(size.width * 0.75, size.height * 0.9);
    glassPath.lineTo(size.width * 0.25, size.height * 0.9);
    glassPath.close();

    canvas.drawPath(glassPath, glassPaint);

    // Draw juice fill
    if (fillLevel > 0) {
      final juicePaint = Paint()
        ..color = isCompleted
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE91E63)
        ..style = PaintingStyle.fill;

      final fillHeight = (size.height * 0.8) * fillLevel;
      final juicePath = Path();

      final bottomY = size.height * 0.9;
      final topY = bottomY - fillHeight;

      juicePath.moveTo(size.width * 0.25, bottomY);
      juicePath.lineTo(size.width * 0.75, bottomY);

      // Calculate the width at the fill level
      final fillRatio = (bottomY - topY) / (size.height * 0.8);
      final topWidth = 0.2 + (0.55 * (1 - fillRatio));

      juicePath.lineTo(size.width * (1 - topWidth), topY);
      juicePath.lineTo(size.width * topWidth, topY);
      juicePath.close();

      canvas.drawPath(juicePath, juicePaint);

      // Add juice surface with slight wave
      final surfacePaint = Paint()
        ..color =
            (isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFE91E63))
                .withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      final wavePath = Path();
      wavePath.moveTo(size.width * topWidth, topY);

      // Create a subtle wave effect
      for (
        double x = size.width * topWidth;
        x <= size.width * (1 - topWidth);
        x += 2
      ) {
        final waveY = topY + math.sin((x / size.width) * 4 * math.pi) * 2;
        wavePath.lineTo(x, waveY);
      }

      wavePath.lineTo(size.width * (1 - topWidth), topY);
      wavePath.lineTo(size.width * (1 - topWidth), topY + 4);
      wavePath.lineTo(size.width * topWidth, topY + 4);
      wavePath.close();

      canvas.drawPath(wavePath, surfacePaint);
    }

    // Draw watermelon seeds in the juice
    if (fillLevel > 0.3) {
      final seedPaint = Paint()
        ..color = const Color(0xFF1B5E20)
        ..style = PaintingStyle.fill;

      final seedPositions = [
        Offset(size.width * 0.4, size.height * 0.7),
        Offset(size.width * 0.6, size.height * 0.8),
        Offset(size.width * 0.5, size.height * 0.75),
      ];

      for (final pos in seedPositions) {
        if (pos.dy >= size.height * 0.9 - (size.height * 0.8) * fillLevel) {
          canvas.drawOval(
            Rect.fromCenter(center: pos, width: 4, height: 6),
            seedPaint,
          );
        }
      }
    }

    // Draw glass shine
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final shinePath = Path();
    shinePath.moveTo(size.width * 0.22, size.height * 0.12);
    shinePath.lineTo(size.width * 0.35, size.height * 0.12);
    shinePath.lineTo(size.width * 0.32, size.height * 0.4);
    shinePath.lineTo(size.width * 0.24, size.height * 0.4);
    shinePath.close();

    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
