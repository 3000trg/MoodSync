import 'dart:math';
import 'package:flutter/material.dart';

class WaveformLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final double speed;
  final Color color;

  const WaveformLoader({
    super.key,
    this.size = 35.0,
    this.strokeWidth = 3.5,
    this.speed = 1.0,
    required this.color,
  });

  @override
  State<WaveformLoader> createState() => _WaveformLoaderState();
}

class _WaveformLoaderState extends State<WaveformLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1000 / widget.speed).round()),
    )..repeat();
  }

  @override
  void didUpdateWidget(WaveformLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speed != oldWidget.speed) {
      _controller.duration = Duration(milliseconds: (1000 / widget.speed).round());
      _controller.repeat();
    }
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
              strokeWidth: widget.strokeWidth,
            ),
            size: Size(widget.size, widget.size),
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;

  WaveformPainter({
    required this.animationValue,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const int barCount = 4;
    final double spacing = size.width / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final double x = i * spacing;
      
      // Calculate phase shift for each bar to create the wave effect
      // ldrs waveform uses a staggered sine/cosine wave
      final double phase = i * (pi / 4);
      final double scale = 0.3 + 0.7 * (sin(animationValue * 2 * pi + phase).abs());
      
      final double barHeight = size.height * scale;
      final double yStart = (size.height - barHeight) / 2;
      final double yEnd = yStart + barHeight;

      canvas.drawLine(
        Offset(x, yStart),
        Offset(x, yEnd),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
