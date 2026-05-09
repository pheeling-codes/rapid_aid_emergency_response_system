import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/action_button.dart';

/// CitizenDispatchConfirmScreen - Incident confirmation and dispatch
/// Migrated from dispatch_confirm_screen.dart with Clinical Vanguard design compliance
class CitizenDispatchConfirmScreen extends StatelessWidget {
  final String incidentType;
  final String description;

  const CitizenDispatchConfirmScreen({
    super.key,
    required this.incidentType,
    required this.description,
  });

  IconData get _incidentIcon {
    switch (incidentType.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'accident':
        return Icons.car_crash;
      case 'security':
        return Icons.security;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.headingColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Confirm Dispatch',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map section - Using tonal depth
          Container(
            height: 200,
            width: double.infinity,
            color: AppTheme.surfaceContainerLow,
            child: Stack(
              children: [
                // Map placeholder with grid
                Container(
                  color: AppTheme.surfaceContainerLow,
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                    child: Container(),
                  ),
                ),
                // GPS badge - No borders
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'GPS FIX: HIGH ACCURACY',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Location pin - Emergency Red
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.emergencyUrl.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 16,
                        color: AppTheme.emergencyUrl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details card - Using surfaceContainerLowest
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Incident type header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.emergencyUrl.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _incidentIcon,
                                color: AppTheme.emergencyUrl,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Incident:',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color:
                                          AppTheme.bodyColor.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    incidentType,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'REF ID: RA-992-01',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color:
                                          AppTheme.bodyColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.emergencyUrl.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'URGENT',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppTheme.emergencyUrl,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          height: 1,
                          color: AppTheme.surfaceContainerHigh,
                        ),
                        const SizedBox(height: 16),

                        // Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LOCATION',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color:
                                          AppTheme.bodyColor.withOpacity(0.5),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '123 Third Mainland Bridge',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Lagos, Nigeria • Outer Lane (Southbound)',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color:
                                          AppTheme.bodyColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DESCRIPTION',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color:
                                          AppTheme.bodyColor.withOpacity(0.5),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${description.isNotEmpty ? description : 'Two-car collision with visible injuries. Requesting immediate ambulance support.'}"',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color:
                                          AppTheme.bodyColor.withOpacity(0.6),
                                      fontStyle: FontStyle.italic,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          height: 1,
                          color: AppTheme.surfaceContainerHigh,
                        ),
                        const SizedBox(height: 12),

                        // Responder info - Primary Blue for success states
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Responder pre-allocated',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.bodyColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'ETA: 6 MINS',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Confirm & Dispatch - 56px height ActionButton
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ActionButton(
                      label: 'CONFIRM & DISPATCH',
                      onPressed: () {
                        context.go('/citizen/active');
                      },
                      isEmergency: true,
                      icon: Icons.emergency,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Safety disclaimer - Using surfaceContainerLow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.emergencyUrl,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Safety Disclaimer: False reports are subject to legal penalties under the Emergency Services Act. Help is being pre-allocated to your verified location.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 12,
                                color: AppTheme.bodyColor.withOpacity(0.6),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
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
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.1)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
