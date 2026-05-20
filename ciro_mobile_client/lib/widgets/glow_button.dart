import 'package:flutter/material.dart';

/// Premium emergency button with ambient glow, scale micro-interaction,
/// and optional glass background.
///
/// Used for CTA buttons like "Report Emergency" and "Submit Report".
///
/// Features:
/// - Animated ambient glow shadow
/// - Scale press animation (0.97x)
/// - Gradient background option
/// - Configurable glow color and intensity
///
/// Usage:
/// ```dart
/// GlowButton(
///   label: 'Report Emergency',
///   icon: Icons.campaign_rounded,
///   onPressed: () {},
///   glowColor: CiroColors.severityCritical,
///   gradient: CiroColors.emergencyGradient,
/// )
/// ```
class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.glowColor,
    this.glowRadius = 28.0,
    this.borderRadius = 16.0,
    this.height = 56.0,
    this.width,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color foregroundColor;
  final Color? glowColor;
  final double glowRadius;
  final double borderRadius;
  final double height;
  final double? width;
  final bool isLoading;
  final bool enabled;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.glowColor != null && widget.enabled) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && widget.glowColor != null && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!widget.enabled && _glowController.isAnimating) {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _isPressed = false);
  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = widget.glowColor ?? 
        widget.backgroundColor ?? 
        Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: widget.enabled ? _onTapDown : null,
      onTapUp: widget.enabled ? _onTapUp : null,
      onTapCancel: widget.enabled ? _onTapCancel : null,
      onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedBuilder3(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                color: widget.gradient == null
                    ? (widget.backgroundColor ??
                        Theme.of(context).colorScheme.primary)
                    : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.glowColor != null && widget.enabled
                    ? [
                        BoxShadow(
                          color: effectiveGlowColor.withAlpha(
                            (_glowAnimation.value * 80).toInt(),
                          ),
                          blurRadius: widget.glowRadius,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: widget.foregroundColor,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.foregroundColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.foregroundColor
                                  .withAlpha(widget.enabled ? 255 : 128),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Animated builder that works with AnimationController.
class AnimatedBuilder3 extends AnimatedWidget {
  const AnimatedBuilder3({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
