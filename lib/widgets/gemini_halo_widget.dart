import 'dart:math';
import 'package:flutter/material.dart';

class GeminiHaloWidget extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool isActive;

  const GeminiHaloWidget({
    super.key,
    required this.child,
    required this.color,
    this.isActive = true,
  });

  @override
  State<GeminiHaloWidget> createState() => _GeminiHaloWidgetState();
}

class _GeminiHaloWidgetState extends State<GeminiHaloWidget> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _entranceController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    if (widget.isActive) {
      _entranceController.forward();
    }
  }

  @override
  void didUpdateWidget(GeminiHaloWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _entranceController.forward();
      } else {
        _entranceController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _entranceController]),
      child: widget.child,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. The Song Card (Base layer - built once & reused)
            child!,

            // 2. The Halo Overlay (Top layer - animates independently)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.2 * _opacityAnimation.value),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: HaloPainter(
                            animationValue: _rotationController.value,
                            color: widget.color,
                            opacity: _opacityAnimation.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class HaloPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double opacity;

  HaloPainter({required this.animationValue, required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.1 * opacity),
          color.withValues(alpha: 0.8 * opacity),
          color.withValues(alpha: 0.1 * opacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
        transform: GradientRotation(animationValue * 2 * pi),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final blurPaint = Paint()
      ..shader = paint.shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(rRect, blurPaint);
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant HaloPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity;
  }
}
