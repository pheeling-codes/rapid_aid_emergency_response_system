import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_button.dart';
import '../../../core/widgets/rapid_aid_card.dart';

/// CitizenDashboardScreen - Main emergency response dashboard
/// Migrated from home_screen.dart with Clinical Vanguard design compliance
class CitizenDashboardScreen extends StatelessWidget {
  const CitizenDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location badge - No-Line Rule: Removed border, use tonal depth
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    // Border removed per No-Line Rule
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
                      const SizedBox(width: 8),
                      Text(
                        'LOCATION SERVICE: ACTIVE',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title - Editorial Precision Typography
              Text(
                'Emergency Response',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select the incident type for immediate dispatch.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),

              // 2x2 grid of emergency types
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _EmergencyCard(
                    label: 'MEDICAL',
                    icon: Icons.medical_services,
                    onTap: () => context.push('/citizen/incident-details/medical'),
                  ),
                  _EmergencyCard(
                    label: 'FIRE',
                    icon: Icons.local_fire_department,
                    onTap: () => context.push('/citizen/incident-details/fire'),
                  ),
                  _EmergencyCard(
                    label: 'ACCIDENT',
                    icon: Icons.car_crash,
                    onTap: () => context.push('/citizen/incident-details/accident'),
                  ),
                  _EmergencyCard(
                    label: 'SECURITY',
                    icon: Icons.security,
                    onTap: () => context.push('/citizen/incident-details/security'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Map preview - Uses surfaceContainerLow for depth
              GestureDetector(
                onTap: () => context.go('/citizen/active'),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.surfaceContainerLow,
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Nigeria_location_map.svg/500px-Nigeria_location_map.svg.png',
                      ),
                      fit: BoxFit.cover,
                      opacity: 0.3,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppTheme.primary.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.navigation,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '3 Active Responders Nearby',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Not an emergency card - Uses RapidAidCard widget
              RapidAidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Not an Emergency?',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Report non-urgent incidents or check regional safety status through our community portal.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 12,
                                  color: cs.onSurface.withOpacity(0.6),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Using RapidAidButton per Widget Substitution rule
                    RapidAidButton(
                      label: 'View Reports',
                      onPressed: () => context.go('/citizen/reports'),
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _EmergencyCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.emergencyUrl,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 1.0,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
