import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final colors = moodProvider.auroraColors;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF0F172A), // Base background
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: AuroraPainter(
                      animationValue: _controller.value,
                      colors: colors,
                    ),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
    );
  }
}

class AuroraPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;

  AuroraPainter({required this.animationValue, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    for (int i = 0; i < 3; i++) {
      final color = colors[i % colors.length].withValues(alpha: 0.4);
      paint.color = color;

      final double x = size.width * (0.5 + 0.3 * sin(animationValue * 2 * pi + i));
      final double y = size.height * (0.5 + 0.3 * cos(animationValue * 2 * pi + i * 2));
      final double radius = size.width * (0.4 + 0.1 * sin(animationValue * pi + i));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.colors != colors;
  }
}
