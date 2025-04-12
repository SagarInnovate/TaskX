// lib/common/widgets/animated_card.dart
import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final double elevation;
  final bool isActive;
  final Duration animationDuration;
  final BorderSide? border;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(0),
    this.onTap,
    this.elevation = 2.0,
    this.isActive = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.border,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Theme.of(context).cardColor;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.onTap != null ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onTap != null) {
            setState(() => _isPressed = true);
            _controller.forward();
          }
        },
        onTapUp: (_) {
          if (widget.onTap != null) {
            setState(() => _isPressed = false);
            _controller.reverse();
            widget.onTap!();
          }
        },
        onTapCancel: () {
          if (widget.onTap != null) {
            setState(() => _isPressed = false);
            _controller.reverse();
          }
        },
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeInOut,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.08),
                blurRadius: widget.elevation * (_isPressed ? 3 : 5),
                spreadRadius: widget.elevation * (_isPressed ? 0.2 : 0.5),
                offset: Offset(0, widget.elevation * (_isPressed ? 1 : 2)),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
                if (widget.isActive)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                if (widget.onTap != null)
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        onTap: () {}, // Handled by GestureDetector
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
