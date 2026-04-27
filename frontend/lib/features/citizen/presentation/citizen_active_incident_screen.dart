import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_button.dart';

/// CitizenActiveIncidentScreen - Live activity tracking for active incidents
/// Migrated from active_incident_screen.dart with Clinical Vanguard design compliance
class CitizenActiveIncidentScreen extends StatelessWidget {
  const CitizenActiveIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: Column(
        children: [
          // Map - Using tonal depth instead of solid colors
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              children: [
                Container(
                  color: AppTheme.surfaceContainerLow,
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                    child: Container(),
                  ),
                ),
                // Responder en route banner - Emergency Red accent
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: AppTheme.emergencyUrl,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RESPONDER EN ROUTE',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Incident pin - Emergency Red with tonal depth
                Positioned(
                  top: 80,
                  right: 140,
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.emergencyUrl,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.surfaceContainerLowest,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 14,
                        color: AppTheme.emergencyUrl,
                      ),
                    ],
                  ),
                ),
                // User dot - Primary Blue
                Positioned(
                  top: 140,
                  left: 100,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppTheme.primary,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Live Activity Section - Using surfaceContainerLowest for card
          Expanded(
            child: Container(
              color: AppTheme.surfaceContainerLowest,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Live Activity',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.emergencyUrl.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ACTIVE DISPATCH',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppTheme.emergencyUrl,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timeline events - No borders, tonal depth for cards
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: const [
                        _TimelineEvent(
                          time: '14:02',
                          title: 'Dispatch Confirmed',
                          subtitle: null,
                          isActive: false,
                          isUrgent: false,
                        ),
                        _TimelineEvent(
                          time: '14:03',
                          title: 'Unit 402 Departing Station',
                          subtitle:
                              'First responder unit assigned and clear for departure.',
                          isActive: false,
                          isUrgent: false,
                        ),
                        _TimelineEvent(
                          time: '14:05',
                          title: 'En route: Traffic on Third Mainland Bridge.',
                          subtitle:
                              'ETA adjusted. Responder maintains communication.',
                          isActive: true,
                          isUrgent: true,
                        ),
                      ],
                    ),
                  ),

                  // Call Responder button - Using RapidAidButton
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: RapidAidButton(
                      label: 'CALL RESPONDER',
                      onPressed: () {
                        // TODO: Implement call functionality
                      },
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  final String time;
  final String title;
  final String? subtitle;
  final bool isActive;
  final bool isUrgent;

  const _TimelineEvent({
    required this.time,
    required this.title,
    this.subtitle,
    required this.isActive,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppTheme.emergencyUrl
                      : AppTheme.bodyColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              if (subtitle != null || !isUrgent)
                Container(
                  width: 2,
                  height: 50,
                  color: AppTheme.surfaceContainerHigh,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isUrgent
                        ? AppTheme.emergencyUrl
                        : AppTheme.bodyColor.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? AppTheme.emergencyUrl
                        : AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              isUrgent ? Colors.white : AppTheme.headingColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 13,
                            color: isUrgent
                                ? Colors.white.withOpacity(0.85)
                                : AppTheme.bodyColor.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base fill with surface color
    final basePaint = Paint()
      ..color = AppTheme.surfaceContainerLow
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, basePaint);

    // Grid lines with subtle opacity
    final gridPaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
