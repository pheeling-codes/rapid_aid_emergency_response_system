import 'package:flutter/material.dart';

enum IncidentStatus { pending, emergency, resolved }

class StatusChip extends StatelessWidget {
  final IncidentStatus status;

  const StatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case IncidentStatus.pending:
        backgroundColor = Colors.amber.withOpacity(0.2);
        textColor = Colors.amber.shade900;
        label = "PENDING";
        break;
      case IncidentStatus.emergency:
        backgroundColor = theme.colorScheme.error.withOpacity(0.2);
        textColor = theme.colorScheme.error;
        label = "EMERGENCY";
        break;
      case IncidentStatus.resolved:
        backgroundColor = Colors.green.shade100; // Low-saturation Green
        textColor = Colors.green.shade800;
        label = "RESOLVED";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
