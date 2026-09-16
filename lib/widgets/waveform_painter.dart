import 'dart:math';
import 'package:flutter/material.dart';

class WaveformWidget extends StatefulWidget {
  final Color color;
  const WaveformWidget({super.key, required this.color});

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: WaveformPainter(
              animationValue: _controller.value,
              color: widget.color,
            ),
            size: const Size(40, 20),
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WaveformPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double width = size.width;
    double height = size.height;
    int barCount = 5;
    double spacing = width / (barCount + 1);

    for (int i = 0; i < barCount; i++) {
      double x = spacing * (i + 1);
      double barHeight = (height * 0.3) + (height * 0.7 * sin((animationValue * 2 * pi) + (i * 1.5)).abs());
      canvas.drawLine(
        Offset(x, height / 2 - barHeight / 2),
        Offset(x, height / 2 + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}
