import 'package:flutter/material.dart';

/// Ambient shadow decoration following the Clinical Vanguard Design System.
/// 
/// Floating elements use diffused shadows:
/// - y: 12, blur: 24, spread: -4 at 6% opacity
/// - Pure black shadows are forbidden
/// 
/// Usage: Wrap cards or floating elements with this decoration.
class AmbientShadow extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AmbientShadow({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.surfaceContainerLowest;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Primary ambient shadow: y: 12, blur: 24, spread: -4 at 6% opacity
          BoxShadow(
            color: const Color(0xFF111827).withOpacity(0.06),
            offset: const Offset(0, 12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          // Secondary subtle lift shadow: y: 4, blur: 8, spread: -2 at 4% opacity
          BoxShadow(
            color: const Color(0xFF111827).withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Extension for easy ambient shadow application
extension AmbientShadowExtension on Widget {
  Widget withAmbientShadow({
    double borderRadius = 16,
    Color? backgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AmbientShadow(
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      child: this,
    );
  }
}
