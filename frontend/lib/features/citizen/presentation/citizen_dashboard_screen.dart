import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_button.dart';
import '../../../core/widgets/ambient_shadow.dart';

/// CitizenDashboardScreen - Main emergency response dashboard
/// Clinical Vanguard Design System Compliance:
/// - No-Line Rule: Tonal depth instead of borders
/// - Color Integrity: Primary Blue (#005EB8) for authority, Emergency Red only for SOS
/// - Ambient Shadows: y: 12, blur: 24, spread: -4 at 6% opacity
/// - Editorial Typography: display-lg for metrics, label-md for micro-copy
class CitizenDashboardScreen extends StatelessWidget {
  const CitizenDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Service Pill - Soft-tonal design
              // Uses surfaceContainerLow with surfaceContainerLowest for depth
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pulsing indicator
                      _PulsingIndicator(),
                      const SizedBox(width: 8),
                      Text(
                        'GPS FIX: HIGH ACCURACY',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title - Editorial Precision Typography
              // Deep Slate (#111827) for primary headings
              Text(
                'Emergency Response',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.headingColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select the incident type for immediate dispatch.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.bodyColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // 2x2 grid of emergency types
              // Uses surfaceContainerLowest with ambient shadows
              // Primary Blue (#005EB8) for authority - NOT Emergency Red
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  _EmergencyCard(
                    label: 'MEDICAL',
                    icon: Icons.medical_services,
                    iconBgColor: AppTheme.primary.withOpacity(0.12),
                    iconColor: AppTheme.primary,
                    onTap: () =>
                        context.push('/citizen/incident-details/medical'),
                  ),
                  _EmergencyCard(
                    label: 'FIRE',
                    icon: Icons.local_fire_department,
                    iconBgColor: AppTheme.emergencyUrl.withOpacity(0.12),
                    iconColor: AppTheme.emergencyUrl,
                    isEmergency: true,
                    onTap: () => context.push('/citizen/incident-details/fire'),
                  ),
                  _EmergencyCard(
                    label: 'ACCIDENT',
                    icon: Icons.car_crash,
                    iconBgColor: AppTheme.primary.withOpacity(0.12),
                    iconColor: AppTheme.primary,
                    onTap: () =>
                        context.push('/citizen/incident-details/accident'),
                  ),
                  _EmergencyCard(
                    label: 'SECURITY',
                    icon: Icons.security,
                    iconBgColor: AppTheme.secondary.withOpacity(0.12),
                    iconColor: AppTheme.secondary,
                    onTap: () =>
                        context.push('/citizen/incident-details/security'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Map preview with frosted glass overlay
              // Uses ambient shadow for floating effect
              GestureDetector(
                onTap: () => context.go('/citizen/active'),
                child: AmbientShadow(
                  borderRadius: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Nigeria_location_map.svg/500px-Nigeria_location_map.svg.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Frosted glass overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppTheme.primary.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.navigation,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '3',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Active Responders Nearby',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Not an emergency card - Uses surfaceContainerLow with tonal depth
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
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
                                  color: AppTheme.headingColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Check report history or view community safety status.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 13,
                                  color: AppTheme.bodyColor.withOpacity(0.6),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RapidAidButton(
                      label: 'View History',
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

/// Pulsing GPS indicator - subtle animation for live status
class _PulsingIndicator extends StatefulWidget {
  @override
  State<_PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<_PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Emergency Type Card - Clinical Vanguard Design
///
/// - surfaceContainerLowest background (not Emergency Red)
/// - Ambient shadows for floating effect
/// - Primary Blue (#005EB8) accents for authority
/// - Emergency Red (#D32F2F) ONLY for FIRE emergency type
class _EmergencyCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isEmergency;
  final VoidCallback onTap;

  const _EmergencyCard({
    required this.label,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isEmergency = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AmbientShadow(
        borderRadius: 16,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.headingColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
