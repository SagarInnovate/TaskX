// lib/common/widgets/animated_button.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

enum ButtonStyle { primary, secondary, success, danger, ghost }

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle style;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;

  const AnimatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.style = ButtonStyle.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.height = 56.0,
    this.width,
    this.borderRadius = 16.0,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getButtonColor() {
    final theme = Theme.of(context);
    switch (widget.style) {
      case ButtonStyle.primary:
        return theme.primaryColor;
      case ButtonStyle.secondary:
        return theme.colorScheme.secondary;
      case ButtonStyle.success:
        return Colors.green.shade600;
      case ButtonStyle.danger:
        return Colors.red.shade600;
      case ButtonStyle.ghost:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (widget.style) {
      case ButtonStyle.primary:
      case ButtonStyle.secondary:
      case ButtonStyle.success:
      case ButtonStyle.danger:
        return Colors.white;
      case ButtonStyle.ghost:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.isLoading) {
            setState(() => _isPressed = true);
            _controller.forward();
          }
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          if (!widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _getButtonColor(),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.style != ButtonStyle.ghost
                ? [
                    BoxShadow(
                      color:
                          _getButtonColor().withOpacity(_isPressed ? 0.3 : 0.2),
                      blurRadius: _isPressed ? 8 : 12,
                      offset: Offset(0, _isPressed ? 2 : 4),
                      spreadRadius: 0,
                    )
                  ]
                : null,
            border: widget.style == ButtonStyle.ghost
                ? Border.all(color: Theme.of(context).primaryColor)
                : null,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: widget.isLoading
                  ? _LoadingIndicator(color: _getTextColor())
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: _getTextColor(),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: _getTextColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  final Color color;

  const _LoadingIndicator({Key? key, required this.color}) : super(key: key);

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final opacity = math.sin((_controller.value - delay) * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Transform.scale(
                scale: math.max(0.5, opacity),
                child: Opacity(
                  opacity: math.max(0.5, opacity),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
