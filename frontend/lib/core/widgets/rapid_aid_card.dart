import 'package:flutter/material.dart';

class RapidAidCard extends StatelessWidget {
  final Widget child;

  const RapidAidCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The Container Rule: Fill: surfaceContainerLowest. Radius: 16px (lg).
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24), // Strict 24px (xl) padding
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest, // Pure white active background
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
