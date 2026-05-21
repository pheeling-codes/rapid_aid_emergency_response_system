import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';

class ResponderHistoryScreen extends StatefulWidget {
  const ResponderHistoryScreen({super.key});

  @override
  State<ResponderHistoryScreen> createState() => _ResponderHistoryScreenState();
}

class _ResponderHistoryScreenState extends State<ResponderHistoryScreen> {
  int _selectedFilter = 0;

  final List<String> _filters = [
    'All Incidents',
    'Medical',
    'Fire',
    'Accidents',
    'Security',
  ];

  final List<_IncidentRecord> _incidents = [
    _IncidentRecord(
      category: 'Medical',
      icon: Icons.medical_services_rounded,
      iconBg: Color(0xFFFFEBEE),
      iconColor: Color(0xFFD32F2F),
      title: 'Cardiac Arrest',
      address: '452 Oak Avenue, Medical Center District',
      time: 'Today • 14:22',
      status: 'RESOLVED',
    ),
    _IncidentRecord(
      category: 'Fire',
      icon: Icons.local_fire_department_rounded,
      iconBg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
      title: 'Kitchen Fire (Code 2)',
      address: '881 West Side Plaza, Apt 402',
      time: 'Today • 11:05',
      status: 'RESOLVED',
    ),
    _IncidentRecord(
      category: 'Accidents',
      icon: Icons.car_crash,
      iconBg: Color(0xFFE3F2FD),
      iconColor: Color(0xFF1565C0),
      title: 'Traffic Collision',
      address: 'Intersection of 5th & Broadway',
      time: 'Yesterday • 23:45',
      status: 'RESOLVED',
    ),
    _IncidentRecord(
      category: 'Medical',
      icon: Icons.medical_services,
      iconBg: Color(0xFFFFEBEE),
      iconColor: Color(0xFFD32F2F),
      title: 'Respiratory Distress',
      address: 'Golden Years Nursing Home, Wing B',
      time: 'Yesterday • 19:10',
      status: 'RESOLVED',
    ),
    _IncidentRecord(
      category: 'Security',
      icon: Icons.security_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
      title: 'Threat Assessment',
      address: 'Central Park Precinct, Gate 3',
      time: '2 days ago • 09:30',
      status: 'RESOLVED',
    ),
    _IncidentRecord(
      category: 'Fire',
      icon: Icons.local_fire_department_rounded,
      iconBg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
      title: 'Chemical Plant Leak',
      address: 'Industrial District, Sector 7',
      time: '3 days ago • 15:55',
      status: 'RESOLVED',
    ),
  ];

  List<_IncidentRecord> get _filtered {
    if (_selectedFilter == 0) return _incidents;
    final label = _filters[_selectedFilter];
    return _incidents
        .where((i) =>
            i.category.toLowerCase() == label.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Topbar ─────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 14.0),
              child: Row(
                children: [
                  const RapidAidLogo(size: 32, iconSize: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Incidents History',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 15,
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Stats Cards ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'TOTAL RESOLVED',
                            value: '24',
                            badge: '+2 today',
                            badgeColor: const Color(0xFF4CAF50),
                            theme: theme,
                            cs: cs,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'EFFICIENCY',
                            value: '98%',
                            badge: 'Peak',
                            badgeColor: cs.primary,
                            theme: theme,
                            cs: cs,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Filter Chips ─────────────────────────────────────────
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final active = i == _selectedFilter;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: active
                                    ? cs.primary
                                    : cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                _filters[i],
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: active
                                      ? Colors.white
                                      : cs.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Recent Activity ──────────────────────────────────────
                    Text(
                      'RECENT ACTIVITY',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No incidents in this category.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ),
                      )
                    else
                      ...filtered.map(
                        (incident) => _IncidentCard(
                            incident: incident, theme: theme, cs: cs),
                      ),

                    const SizedBox(height: 12),
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

// ── Data Model ────────────────────────────────────────────────────────────────

class _IncidentRecord {
  final String category;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String address;
  final String time;
  final String status;

  const _IncidentRecord({
    required this.category,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.address,
    required this.time,
    required this.status,
  });
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String badge;
  final Color badgeColor;
  final ThemeData theme;
  final ColorScheme cs;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cs.onSurface.withOpacity(0.45),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.headingColor,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  badge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final _IncidentRecord incident;
  final ThemeData theme;
  final ColorScheme cs;

  const _IncidentCard(
      {required this.incident, required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: incident.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(incident.icon, color: incident.iconColor, size: 20),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Status chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        incident.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.headingColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        incident.status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Address
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 12, color: cs.onSurface.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        incident.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Time
                Text(
                  incident.time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
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
