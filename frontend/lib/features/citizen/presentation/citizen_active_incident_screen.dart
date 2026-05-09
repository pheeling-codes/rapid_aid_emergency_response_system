import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/action_button.dart';

/// CitizenActiveIncidentScreen - Live activity tracking for active incidents
/// Clinical Vanguard Design System Compliance:
/// - Frosted Glass (Backdrop Blur) overlay for live map activity
/// - Timeline with tonal depth cards (no borders)
/// - 56px height emergency button
/// - Editorial typography throughout
class CitizenActiveIncidentScreen extends StatelessWidget {
  const CitizenActiveIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: Column(
        children: [
          // Map with Frosted Glass overlay
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              children: [
                // Base map grid
                Container(
                  color: AppTheme.surfaceContainerLow,
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                    child: Container(),
                  ),
                ),
                // Frosted Glass overlay at bottom for text legibility
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.surfaceContainerLow.withOpacity(0.0),
                              AppTheme.surfaceContainerLow.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Responder en route banner - Emergency Red accent with tonal depth
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emergencyUrl,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.emergencyUrl.withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ],
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
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Incident pin - Emergency Red with tonal ring (not border)
                Positioned(
                  top: 80,
                  right: 140,
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.emergencyUrl,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.emergencyUrl.withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 24,
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
                // User dot - Primary Blue with pulsing effect
                Positioned(
                  top: 140,
                  left: 100,
                  child: _PulsingUserDot(),
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
                  // Header with editorial typography
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Live Activity',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.headingColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
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
                              letterSpacing: 0.8,
                              fontSize: 11,
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

                  // Call Responder button - 56px height ActionButton
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ActionButton(
                      label: 'CALL RESPONDER',
                      onPressed: () {
                        // TODO: Implement call functionality
                      },
                      isEmergency: true,
                      icon: Icons.phone,
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

/// Pulsing User Dot - Animated indicator for live tracking
class _PulsingUserDot extends StatefulWidget {
  @override
  State<_PulsingUserDot> createState() => _PulsingUserDotState();
}

class _PulsingUserDotState extends State<_PulsingUserDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring
            Container(
              width: 24 * _pulseAnimation.value,
              height: 24 * _pulseAnimation.value,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            // Core dot
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
