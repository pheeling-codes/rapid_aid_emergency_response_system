import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Extended status enum for citizen reports
enum IncidentStatus { pending, active, resolved, cancelled, emergency }

/// Clinical Vanguard Status Chip
///
/// Color Integrity:
/// - RESOLVED: Primary Blue (#005EB8) - Authority/Completion
/// - ACTIVE/PENDING: Secondary Blue-Grey - In Progress
/// - CANCELLED: Deep Slate with opacity - Neutral/Inactive
/// - EMERGENCY: Emergency Red (#D32F2F) - Urgent/SOS only
///
/// Typography: label-md (uppercase, letter-spaced)
class StatusChip extends StatelessWidget {
  final IncidentStatus status;
  final String? customLabel;

  const StatusChip({
    Key? key,
    required this.status,
    this.customLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case IncidentStatus.pending:
        backgroundColor = AppTheme.surfaceContainerHigh;
        textColor = AppTheme.bodyColor.withOpacity(0.7);
        label = "PENDING";
        break;
      case IncidentStatus.active:
        backgroundColor = AppTheme.primary.withOpacity(0.12);
        textColor = AppTheme.primary;
        label = "ACTIVE";
        break;
      case IncidentStatus.resolved:
        backgroundColor = AppTheme.primary.withOpacity(0.12);
        textColor = AppTheme.primary;
        label = "RESOLVED";
        break;
      case IncidentStatus.cancelled:
        backgroundColor = AppTheme.surfaceContainerLow;
        textColor = AppTheme.bodyColor.withOpacity(0.5);
        label = "CANCELLED";
        break;
      case IncidentStatus.emergency:
        backgroundColor = AppTheme.emergencyUrl.withOpacity(0.15);
        textColor = AppTheme.emergencyUrl;
        label = "EMERGENCY";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        customLabel ?? label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          fontSize: 11,
        ),
      ),
    );
  }
}
