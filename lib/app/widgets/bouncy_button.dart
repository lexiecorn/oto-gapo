import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A button widget with bouncy scale animation and haptic feedback
class BouncyButton extends StatefulWidget {
  const BouncyButton({
    required this.onPressed,
    required this.child,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.hapticFeedback = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double scale;
  final Duration duration;
  final bool hapticFeedback;

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails details) async {
    if (widget.onPressed != null) {
      await _controller.forward();
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    await _controller.reverse();
  }

  Future<void> _onTapCancel() async {
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// A bouncy icon button
class BouncyIconButton extends StatelessWidget {
  const BouncyIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = BouncyButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// A bouncy elevated button
class BouncyElevatedButton extends StatelessWidget {
  const BouncyElevatedButton({
    required this.onPressed,
    required this.child,
    this.style,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onPressed: onPressed,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// A bouncy text button
class BouncyTextButton extends StatelessWidget {
  const BouncyTextButton({
    required this.onPressed,
    required this.child,
    this.style,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onPressed: onPressed,
      child: TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
