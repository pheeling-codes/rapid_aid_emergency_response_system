import 'package:flutter/material.dart';
import 'dart:ui';

class GlassOverlay extends StatelessWidget {
  final Widget child;

  const GlassOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // 20px Backdrop Blur
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.85), // 85% opacity
          ),
          child: child,
        ),
      ),
    );
  }
}
