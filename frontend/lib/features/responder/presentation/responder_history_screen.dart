import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import 'responder_incident_detail.dart';

import '../../../main.dart';
import '../../../core/network/network_client.dart';
import '../../../core/widgets/premium_empty_state.dart';

class ResponderHistoryScreen extends StatefulWidget {
  const ResponderHistoryScreen({super.key});

  @override
  State<ResponderHistoryScreen> createState() => _ResponderHistoryScreenState();
}

class _ResponderHistoryScreenState extends State<ResponderHistoryScreen> {
  int _selectedFilter = 0;
  List<_IncidentRecord> _incidents = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final List<String> _filters = [
    'All Incidents',
    'Medical',
    'Fire',
    'Accidents',
    'Security',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final dio = getIt<NetworkClient>().dio;
      final response = await dio.get('/incidents/');
      final data = response.data as List<dynamic>;

      setState(() {
        _incidents = data.map((json) {
          final type = json['category'] ?? 'OTHER';
          return _IncidentRecord(
            category: _capitalize(type),
            icon: _getCategoryIcon(type),
            iconBg: _getCategoryBg(type),
            iconColor: _getCategoryColor(type),
            title: json['title'] ?? 'Emergency: $type',
            address: json['address'] ?? 'Unknown Location',
            time: _formatDate(json['created_at']),
            status: json['status'] ?? 'PENDING',
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load history.';
      });
    }
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : '';

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medical': return Icons.medical_services_rounded;
      case 'fire': return Icons.local_fire_department_rounded;
      case 'accident': return Icons.car_crash;
      case 'security': return Icons.security_rounded;
      default: return Icons.emergency;
    }
  }

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'medical': return const Color(0xFFD32F2F);
      case 'fire': return const Color(0xFFE65100);
      case 'accident': return const Color(0xFF1565C0);
      case 'security': return const Color(0xFF2E7D32);
      default: return Colors.grey.shade700;
    }
  }

  Color _getCategoryBg(String type) {
    switch (type.toLowerCase()) {
      case 'medical': return const Color(0xFFFFEBEE);
      case 'fire': return const Color(0xFFFFF3E0);
      case 'accident': return const Color(0xFFE3F2FD);
      case 'security': return const Color(0xFFE8F5E9);
      default: return Colors.grey.shade200;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  List<_IncidentRecord> get _filtered {
    if (_selectedFilter == 0) return _incidents;
    final label = _filters[_selectedFilter];
    return _incidents
        .where((i) => i.category.toLowerCase() == label.toLowerCase() || (label.toLowerCase() == 'accidents' && i.category.toLowerCase() == 'accident'))
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

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage.isNotEmpty)
                      PremiumEmptyState(
                        icon: Icons.error_outline,
                        title: 'Failed to Load History',
                        message: _errorMessage,
                        actionLabel: 'Try Again',
                        onAction: _fetchHistory,
                      )
                    else if (filtered.isEmpty)
                      PremiumEmptyState(
                        icon: Icons.history,
                        title: 'No Incidents',
                        message: 'There are no incidents matching this category.',
                        actionLabel: 'Refresh',
                        onAction: _fetchHistory,
                      )
                    else
                      ...filtered.map(
                        (incident) => _IncidentCard(
                          incident: incident,
                          theme: theme,
                          cs: cs,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResponderIncidentDetail(
                                title: incident.title,
                                category: incident.category,
                                address: incident.address,
                                time: incident.time,
                                status: incident.status,
                                icon: incident.icon,
                                iconBg: incident.iconBg,
                                iconColor: incident.iconColor,
                              ),
                            ),
                          ),
                        ),
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
  final VoidCallback onTap;

  const _IncidentCard({
    required this.incident,
    required this.theme,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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

                    // Time + chevron
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          incident.time,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.4),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 16, color: cs.onSurface.withOpacity(0.3)),
                      ],
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
