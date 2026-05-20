import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Premium glassmorphism container for the CIRO command-center UI.
///
/// Features:
/// - Backdrop blur (configurable, default 16px)
/// - Semi-transparent fill with subtle white overlay
/// - Thin glass border (rgba(255,255,255,0.06))
/// - Configurable border radius (default 24px)
/// - Optional gradient overlay for depth
/// - Optional glow effect via [glowColor]
///
/// Usage:
/// ```dart
/// GlassContainer(
///   child: Text('Hello'),
///   borderRadius: 20,
///   glowColor: CiroColors.glowBlue,
/// )
/// ```
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.blurAmount = 16.0,
    this.padding,
    this.margin,
    this.glowColor,
    this.glowRadius = 32.0,
    this.fillColor,
    this.borderColor,
    this.width,
    this.height,
    this.gradient,
  });

  final Widget child;
  final double borderRadius;
  final double blurAmount;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Optional ambient glow color (e.g., for active alerts).
  final Color? glowColor;
  final double glowRadius;

  /// Override the default glass fill color.
  final Color? fillColor;

  /// Override the default glass border color.
  final Color? borderColor;

  final double? width;
  final double? height;

  /// Optional gradient overlay on top of glass fill.
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!,
              blurRadius: glowRadius,
              spreadRadius: 0,
            ),
          // Subtle elevation shadow
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurAmount,
            sigmaY: blurAmount,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor ?? CiroColors.glassWhite,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? CiroColors.glassBorder,
                width: 1,
              ),
              gradient: gradient ?? CiroColors.cardGradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
