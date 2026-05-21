import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class ResponderActiveEmergencies extends StatelessWidget {
  const ResponderActiveEmergencies({super.key});

  static final List<_EmergencyItem> _emergencies = [
    _EmergencyItem(
      category: 'FIRE OUTBREAK',
      title: 'High-Rise Residential Complex',
      distance: '0.8km',
      eta: '04:12 mins',
      description:
          'Smoke reported on 14th floor, Tower B. Fire suppression systems active but spreading...',
      categoryColor: Color(0xFFD32F2F),
    ),
    _EmergencyItem(
      category: 'CARDIAC ARREST',
      title: 'Public Transit Station',
      distance: '2.4km',
      eta: '08:45 mins',
      description:
          '65yo Male collapsed on Platform 4. Bystander performing CPR. AED requested at site.',
      categoryColor: Color(0xFF1565C0),
    ),
    _EmergencyItem(
      category: 'VEHICLE COLLISION',
      title: 'Interstate 405 Southbound',
      distance: '5.2km',
      eta: '12:30 mins',
      description:
          'Multi-vehicle pileup. 3 victims reported with head injuries. Heavy traffic delaying backup...',
      categoryColor: Color(0xFFE65100),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Topbar ─────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 20, color: cs.onSurface.withOpacity(0.7)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'ACTIVE EMERGENCIES',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppTheme.headingColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: cs.surfaceContainerHigh, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.surfaceContainerLow,
                      child: Icon(Icons.person_rounded,
                          color: cs.onSurface.withOpacity(0.6), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Live Queue Pill
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: const Color(0xFFFFCC02).withOpacity(0.4),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFA000),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LIVE QUEUE: ${_emergencies.length} PENDING',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: const Color(0xFF795548),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emergency Cards
                    ..._emergencies.map(
                      (e) => _EmergencyCard(item: e, theme: theme, cs: cs),
                    ),
                    const SizedBox(height: 4),

                    // Tactical Map Banner
                    _TacticalMapBanner(theme: theme, cs: cs),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyItem {
  final String category;
  final String title;
  final String distance;
  final String eta;
  final String description;
  final Color categoryColor;

  const _EmergencyItem({
    required this.category,
    required this.title,
    required this.distance,
    required this.eta,
    required this.description,
    required this.categoryColor,
  });
}

class _EmergencyCard extends StatelessWidget {
  final _EmergencyItem item;
  final ThemeData theme;
  final ColorScheme cs;

  const _EmergencyCard(
      {required this.item, required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category + Live dot
          Row(
            children: [
              Text(
                item.category,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: item.categoryColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            item.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppTheme.headingColor,
            ),
          ),
          const SizedBox(height: 10),

          // Distance + ETA
          Row(
            children: [
              _InfoBadge(
                icon: Icons.navigation_rounded,
                text: item.distance,
                theme: theme,
                cs: cs,
              ),
              const SizedBox(width: 12),
              _InfoBadge(
                icon: Icons.timer_rounded,
                text: item.eta,
                theme: theme,
                cs: cs,
                iconColor: const Color(0xFFD32F2F),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Action Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Accept Dispatch',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.map_rounded,
                    size: 20, color: cs.onSurface.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;
  final ColorScheme cs;
  final Color? iconColor;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.theme,
    required this.cs,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14, color: iconColor ?? cs.onSurface.withOpacity(0.45)),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.65),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TacticalMapBanner extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;

  const _TacticalMapBanner({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: cs.onSurface.withOpacity(0.3),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              "You've reached the end of active emergencies.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
