// lib/features/auth/presentation/widgets/animated_logo.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedLogo extends StatefulWidget {
  final double size;
  final Color color;
  final bool animate;

  const AnimatedLogo({
    Key? key,
    this.size = 100.0,
    this.color = Colors.white,
    this.animate = true,
  }) : super(key: key);

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _waveAnimation = Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    if (widget.animate) {
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer circle
              _buildWavingCircle(_waveAnimation.value, widget.size * 0.9),

              // Inner circle with shadow
              Container(
                width: widget.size * 0.7,
                height: widget.size * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              // Task checkmark
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.black.withOpacity(0.8),
                      size: widget.size * 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWavingCircle(double value, double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WavingCirclePainter(
        color: widget.color,
        wavePhase: value,
      ),
    );
  }
}

class _WavingCirclePainter extends CustomPainter {
  final Color color;
  final double wavePhase;
  final int waveCount = 8;
  final double waveAmplitude = 5.0;

  _WavingCirclePainter({
    required this.color,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    final radiusWithWave = (angle) =>
        baseRadius + waveAmplitude * math.sin(waveCount * angle + wavePhase);

    const step = 0.05;
    double angle = 0;

    bool firstPoint = true;
    while (angle < math.pi * 2) {
      final radius = radiusWithWave(angle);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
      }

      angle += step;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavingCirclePainter oldDelegate) =>
      oldDelegate.wavePhase != wavePhase || oldDelegate.color != color;
}
