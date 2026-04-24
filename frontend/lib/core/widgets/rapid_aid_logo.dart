import 'package:flutter/material.dart';

class RapidAidLogo extends StatelessWidget {
  final double size;
  final double iconSize;

  const RapidAidLogo({
    Key? key,
    this.size = 36,
    this.iconSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.16), // Adaptive radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(0, iconSize * 0.12), // Nudge down perfectly into optical center
        child: Text(
          '✱',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: iconSize * 1.25, // Safely scaled up
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
