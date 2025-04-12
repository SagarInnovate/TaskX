// lib/common/widgets/futuristic_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FuturisticTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool enabled;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final Color? accentColor;

  const FuturisticTextField({
    Key? key,
    required this.label,
    this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.enabled = true,
    this.onChanged,
    this.inputFormatters,
    this.autofocus = false,
    this.accentColor,
  }) : super(key: key);

  @override
  State<FuturisticTextField> createState() => _FuturisticTextFieldState();
}

class _FuturisticTextFieldState extends State<FuturisticTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Color _getAccentColor() {
    if (!widget.enabled) return Colors.grey.shade400;
    if (_hasError) return Theme.of(context).colorScheme.error;
    return widget.accentColor ?? Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _getAccentColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _isFocused ? accentColor : Colors.grey.shade700,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text(widget.label),
            ),
          ),
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        accentColor.withOpacity(0.1 * _borderAnimation.value),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
              TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                validator: (value) {
                  final error = widget.validator?.call(value);
                  setState(() {
                    _hasError = error != null;
                  });
                  return error;
                },
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                onChanged: widget.onChanged,
                inputFormatters: widget.inputFormatters,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: widget.enabled ? Colors.black87 : Colors.grey.shade600,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400,
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: widget.enabled
                      ? Colors.grey.shade50
                      : Colors.grey.shade100,
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color:
                              _isFocused ? accentColor : Colors.grey.shade600,
                          size: 22,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            widget.suffixIcon,
                            color:
                                _isFocused ? accentColor : Colors.grey.shade600,
                            size: 22,
                          ),
                          onPressed: widget.onSuffixIconPressed,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: accentColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (_isFocused)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: _borderAnimation,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _CornerHighlightPainter(
                          color: accentColor,
                          progress: _borderAnimation.value,
                        ),
                        size: const Size(30, 30),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerHighlightPainter extends CustomPainter {
  final Color color;
  final double progress;

  _CornerHighlightPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = color.withOpacity(0.5 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width, size.height - 10 * progress)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - 10 * progress, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerHighlightPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
