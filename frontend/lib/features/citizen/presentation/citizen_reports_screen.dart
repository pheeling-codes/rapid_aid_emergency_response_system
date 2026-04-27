import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// CitizenReportsScreen - Report history and search
/// Migrated from reports_screen.dart with Clinical Vanguard design compliance
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
      'iconColor': AppTheme.emergencyUrl,
      'iconBg': AppTheme.emergencyUrl.withOpacity(0.1),
    },
    {
      'type': 'Road Accident',
      'status': 'RESOLVED',
      'date': 'Oct 21, 2023 • 09:15',
      'location': 'Ikeja City Mall, Obafemi Awolowo Way',
      'icon': Icons.car_crash,
      'iconColor': AppTheme.primary,
      'iconBg': AppTheme.primary.withOpacity(0.1),
    },
    {
      'type': 'Fire Outbreak',
      'status': 'CANCELLED',
      'date': 'Oct 18, 2023 • 23:45',
      'location': 'Block 4, 1004 Estate, Victoria Island',
      'icon': Icons.local_fire_department,
      'iconColor': AppTheme.emergencyUrl,
      'iconBg': AppTheme.emergencyUrl.withOpacity(0.1),
    },
    {
      'type': 'Security Concern',
      'status': 'RESOLVED',
      'date': 'Oct 12, 2023 • 18:20',
      'location': 'Lekki Phase 1, Admiralty Way',
      'icon': Icons.security,
      'iconColor': AppTheme.secondary,
      'iconBg': AppTheme.secondary.withOpacity(0.1),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar - Using surfaceContainerLow with tonal depth
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        // No border per No-Line Rule
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search reports...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: cs.onSurface.withOpacity(0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: cs.onSurface.withOpacity(0.4),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Reports list - Using surfaceContainerLowest cards with no borders
            Expanded(
              child: _filteredReports.isEmpty
                  ? Center(
                      child: Text(
                        'No reports found.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredReports.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _filteredReports.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 40,
                                  color: cs.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'End of report history',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: cs.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        final report = _filteredReports[index];
                        return _ReportItem(report: report);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final Map<String, dynamic> report;
  const _ReportItem({required this.report});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'RESOLVED':
        return AppTheme.primary;
      case 'CANCELLED':
        return AppTheme.bodyColor.withOpacity(0.5);
      default:
        return AppTheme.emergencyUrl;
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'RESOLVED':
        return AppTheme.primary.withOpacity(0.1);
      case 'CANCELLED':
        return AppTheme.surfaceContainerLow;
      default:
        return AppTheme.emergencyUrl.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        // No shadow per design system (elevation 0)
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: report['iconBg'] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              report['icon'] as IconData,
              color: report['iconColor'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report['type'] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBg(report['status'] as String),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report['status'] as String,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _getStatusColor(report['status'] as String),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  report['date'] as String,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: cs.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        report['location'] as String,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onSurface.withOpacity(0.4),
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
    );
  }
}
