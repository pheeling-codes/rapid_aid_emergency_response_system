import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/action_button.dart';

/// Emergency Category Model
class EmergencyCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final String description;

  EmergencyCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

/// Citizen Dashboard Screen
/// Step 1: The Trigger - 4-category grid (Medical, Fire, Accident, Security)
/// Clicking a card passes the Category object to the next screen
class CitizenDashboardScreen extends StatelessWidget {
  CitizenDashboardScreen({super.key});

  final List<EmergencyCategory> _categories = [
    EmergencyCategory(
      id: 'medical',
      name: 'Medical',
      icon: '🏥',
      color: const Color(0xFF005EB8), // Primary Blue
      description: 'Medical emergencies, injuries, health crises',
    ),
    EmergencyCategory(
      id: 'fire',
      name: 'Fire',
      icon: '🔥',
      color: const Color(0xFFD32F2F), // Emergency Red
      description: 'Fire outbreaks, explosions, smoke hazards',
    ),
    EmergencyCategory(
      id: 'accident',
      name: 'Accident',
      icon: '🚗',
      color: const Color(0xFF445E91), // Secondary
      description: 'Vehicle collisions, traffic incidents',
    ),
    EmergencyCategory(
      id: 'security',
      name: 'Security',
      icon: '🛡️',
      color: const Color(0xFF111827), // Deep Slate
      description: 'Threats, assaults, suspicious activity',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Header
                Text(
                  'EMERGENCY',
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Report an Emergency',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.headingColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the type of emergency to begin reporting',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.bodyColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Category Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _CategoryCard(
                      category: category,
                      onTap: () {
                        context.push(
                          '/citizen/incident-details',
                          extra: category,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Quick SOS Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        offset: const Offset(0, 12),
                        blurRadius: 24,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IMMEDIATE SOS',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.emergencyUrl,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Skip details and dispatch immediately',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.bodyColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ActionButton(
                        label: 'SOS DISPATCH',
                        isEmergency: true,
                        icon: Icons.emergency,
                        onPressed: () {
                          // TODO: Wire to DispatchService
                          context.push('/citizen/dispatch-confirm', extra: {
                            'type': 'SOS',
                            'description': 'Immediate SOS dispatch',
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final EmergencyCategory category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 12),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                category.name.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: category.color,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.bodyColor.withOpacity(0.6),
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
