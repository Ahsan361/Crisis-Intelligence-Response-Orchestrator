import 'package:flutter/material.dart';

/// Animated pulse indicator for live status visualization.
///
/// Shows a solid center dot with expanding ring animation —
/// used for live incident markers, status dots, and emergency indicators.
///
/// Usage:
/// ```dart
/// AnimatedPulse(color: CiroColors.severityCritical, size: 12)
/// AnimatedPulse(color: CiroColors.statusOperational, size: 8)
/// ```
class AnimatedPulse extends StatefulWidget {
  const AnimatedPulse({
    super.key,
    required this.color,
    this.size = 12.0,
    this.pulseSize = 2.5,
    this.duration = const Duration(milliseconds: 1500),
    this.showRing = true,
  });

  /// Color of the dot and pulse ring.
  final Color color;

  /// Diameter of the center dot.
  final double size;

  /// How much larger the ring expands (multiplier of [size]).
  final double pulseSize;

  /// Duration of one pulse cycle.
  final Duration duration;

  /// Whether to show the expanding ring or just the dot.
  final bool showRing;

  @override
  State<AnimatedPulse> createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<AnimatedPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pulseSize).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.showRing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showRing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.showRing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * widget.pulseSize,
      height: widget.size * widget.pulseSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding ring
          if (widget.showRing)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withAlpha(
                          (_opacityAnimation.value * 255).toInt(),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          // Center dot
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Same as AnimatedBuilder but using a different name to avoid
/// confusion with Flutter's built-in AnimatedBuilder.
class AnimatedBuilder extends StatelessWidget {
  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
  });

  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder2(
      listenable: animation,
      builder: builder,
    );
  }
}

/// Internal animated builder to avoid naming conflicts.
class AnimatedBuilder2 extends AnimatedWidget {
  const AnimatedBuilder2({
    super.key,
    required super.listenable,
    required this.builder,
  });

  final Widget Function(BuildContext context, Widget? child) builder;

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
