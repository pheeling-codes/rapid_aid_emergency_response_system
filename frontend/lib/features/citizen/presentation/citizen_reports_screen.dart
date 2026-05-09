import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/citizen_empty_state.dart';

/// CitizenReportsScreen - Report history and search
/// Clinical Vanguard Design System Compliance:
/// - High-density cards with vertical whitespace separation (no divider lines)
/// - StatusChips using Primary Blue for RESOLVED, tonal for CANCELLED
/// - Editorial typography with Deep Slate headings
/// - Empty state with tonal layering
class CitizenReportsScreen extends StatefulWidget {
  const CitizenReportsScreen({super.key});

  @override
  State<CitizenReportsScreen> createState() => _CitizenReportsScreenState();
}

class _CitizenReportsScreenState extends State<CitizenReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _reports = [
    {
      'type': 'Medical Emergency',
      'status': 'RESOLVED',
      'date': 'Oct 24, 2023 • 14:02',
      'location': '123 Third Mainland Bridge, Lagos',
      'icon': Icons.medical_services,
      'iconColor': AppTheme.primary,
      'iconBg': AppTheme.primary.withOpacity(0.12),
      'incidentStatus': IncidentStatus.resolved,
    },
    {
      'type': 'Road Accident',
      'status': 'RESOLVED',
      'date': 'Oct 21, 2023 • 09:15',
      'location': 'Ikeja City Mall, Obafemi Awolowo Way',
      'icon': Icons.car_crash,
      'iconColor': AppTheme.primary,
      'iconBg': AppTheme.primary.withOpacity(0.12),
      'incidentStatus': IncidentStatus.resolved,
    },
    {
      'type': 'Fire Outbreak',
      'status': 'CANCELLED',
      'date': 'Oct 18, 2023 • 23:45',
      'location': 'Block 4, 1004 Estate, Victoria Island',
      'icon': Icons.local_fire_department,
      'iconColor': AppTheme.emergencyUrl,
      'iconBg': AppTheme.emergencyUrl.withOpacity(0.12),
      'incidentStatus': IncidentStatus.cancelled,
    },
    {
      'type': 'Security Concern',
      'status': 'RESOLVED',
      'date': 'Oct 12, 2023 • 18:20',
      'location': 'Lekki Phase 1, Admiralty Way',
      'icon': Icons.security,
      'iconColor': AppTheme.secondary,
      'iconBg': AppTheme.secondary.withOpacity(0.12),
      'incidentStatus': IncidentStatus.resolved,
    },
  ];

  List<Map<String, dynamic>> get _filteredReports {
    if (_searchQuery.isEmpty) return _reports;
    return _reports
        .where(
          (r) =>
              r['type'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
              r['location'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
        )
        .toList();
  }

  IncidentStatus _getStatusFromString(String status) {
    switch (status) {
      case 'RESOLVED':
        return IncidentStatus.resolved;
      case 'CANCELLED':
        return IncidentStatus.cancelled;
      case 'ACTIVE':
        return IncidentStatus.active;
      case 'PENDING':
        return IncidentStatus.pending;
      default:
        return IncidentStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Editorial typography
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'REPORT HISTORY',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.headingColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 13,
                ),
              ),
            ),

            // Search bar - Editorial input style
            // Uses surfaceContainerHigh with bottom-stroke focus
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search reports...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.bodyColor.withOpacity(0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.bodyColor.withOpacity(0.4),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter button with tonal depth
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: AppTheme.bodyColor.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Reports list - High-density cards with vertical whitespace
            // No divider lines - uses spacing for separation
            Expanded(
              child: _filteredReports.isEmpty
                  ? CitizenEmptyState(
                      icon: Icons.folder_open_outlined,
                      title: 'No Reports Found',
                      subtitle:
                          'Your incident report history will appear here.',
                      actionLabel: 'Report an Incident',
                      onAction: () => context.go('/citizen/dashboard'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredReports.length + 1,
                      itemBuilder: (context, index) {
                        // End of list indicator
                        if (index == _filteredReports.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceContainerLow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.access_time,
                                      size: 24,
                                      color:
                                          AppTheme.bodyColor.withOpacity(0.3),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'End of report history',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color:
                                          AppTheme.bodyColor.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final report = _filteredReports[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReportCard(
                            report: report,
                            status: _getStatusFromString(
                                report['status'] as String),
                            onTap: () =>
                                context.push('/citizen/report-details'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Report Card - High-density design with vertical whitespace
///
/// Design System:
/// - surfaceContainerLowest background
/// - No borders, no divider lines
/// - StatusChip widget for consistent status display
/// - 12px vertical spacing between cards
class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final IncidentStatus status;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Incident type icon with tonal background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: report['iconBg'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                report['icon'] as IconData,
                color: report['iconColor'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type and Status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          report['type'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.headingColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(
                        status: status,
                        customLabel: report['status'] as String,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Date - Editorial label style
                  Text(
                    report['date'] as String,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.bodyColor.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.bodyColor.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report['location'] as String,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppTheme.bodyColor.withOpacity(0.4),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
