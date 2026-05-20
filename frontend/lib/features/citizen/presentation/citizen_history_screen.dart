import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';

/// Citizen History Screen (Reports)
class CitizenHistoryScreen extends StatefulWidget {
  const CitizenHistoryScreen({super.key});

  @override
  State<CitizenHistoryScreen> createState() => _CitizenHistoryScreenState();
}

class _CitizenHistoryScreenState extends State<CitizenHistoryScreen> {
  String _selectedFilter = 'All';

  // Extended mock data to make it scrollable
  final List<Map<String, dynamic>> _reports = [
    {
      'id': 'RA-992-01',
      'type': 'Medical Emergency',
      'category': 'Medical',
      'icon': Icons.medical_services,
      'color': AppTheme.emergencyUrl,
      'date': 'Oct 24, 2023 • 14:02',
      'status': 'RESOLVED',
      'statusColor': Colors.green.shade700,
      'statusBg': Colors.green.shade50,
      'address': '123 Third Mainland Bridge, Lagos',
    },
    {
      'id': 'RA-988-02',
      'type': 'Road Accident',
      'category': 'Accident',
      'icon': Icons.car_crash,
      'color': const Color(0xFF1E3A8A), // Deep Blue
      'date': 'Oct 21, 2023 • 09:15',
      'status': 'RESOLVED',
      'statusColor': Colors.green.shade700,
      'statusBg': Colors.green.shade50,
      'address': 'Ikeja City Mall, Obafemi Awolowo Way',
    },
    {
      'id': 'RA-991-03',
      'type': 'Fire Outbreak',
      'category': 'Fire',
      'icon': Icons.local_fire_department,
      'color': const Color(0xFFEA580C), // Orange
      'date': 'Oct 18, 2023 • 23:45',
      'status': 'CANCELLED',
      'statusColor': Colors.grey.shade700,
      'statusBg': Colors.grey.shade200,
      'address': 'Block 4, 1004 Estate, Victoria Island',
    },
    {
      'id': 'RA-975-04',
      'type': 'Security Concern',
      'category': 'Security',
      'icon': Icons.security,
      'color': const Color(0xFF7E22CE), // Purple
      'date': 'Oct 12, 2023 • 18:20',
      'status': 'RESOLVED',
      'statusColor': Colors.green.shade700,
      'statusBg': Colors.green.shade50,
      'address': 'Lekki Phase 1, Admiralty Way',
    },
    {
      'id': 'RA-960-05',
      'type': 'Medical Emergency',
      'category': 'Medical',
      'icon': Icons.medical_services,
      'color': AppTheme.emergencyUrl,
      'date': 'Sep 30, 2023 • 10:15',
      'status': 'RESOLVED',
      'statusColor': Colors.green.shade700,
      'statusBg': Colors.green.shade50,
      'address': 'Yaba College of Technology',
    },
    {
      'id': 'RA-955-06',
      'type': 'Road Accident',
      'category': 'Accident',
      'icon': Icons.car_crash,
      'color': const Color(0xFF1E3A8A),
      'date': 'Sep 25, 2023 • 16:40',
      'status': 'CANCELLED',
      'statusColor': Colors.grey.shade700,
      'statusBg': Colors.grey.shade200,
      'address': 'Berger Bus Stop, Lagos',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Filter reports
    final filteredReports = _selectedFilter == 'All'
        ? _reports
        : _reports.where((r) => r['category'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest, // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Topbar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const RapidAidLogo(size: 32, iconSize: 30),
                  Text(
                    'REPORT HISTORY',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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
                      child: Icon(Icons.person,
                          color: cs.onSurface.withOpacity(0.7), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Search and Filter Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search reports...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(Icons.search,
                              color: cs.onSurface.withOpacity(0.6)),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.tune,
                          color: cs.onSurface.withOpacity(0.8)),
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (String result) {
                        setState(() {
                          _selectedFilter = result;
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'All',
                          child: Text('All'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Medical',
                          child: Text('Medical'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Fire',
                          child: Text('Fire'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Accident',
                          child: Text('Accident'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Security',
                          child: Text('Security'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable List
            Expanded(
              child: filteredReports.isEmpty
                  ? Center(
                      child: Text(
                        'No reports found.',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: cs.onSurface.withOpacity(0.5)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 8.0),
                      itemCount:
                          filteredReports.length + 1, // +1 for end indicator
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index == filteredReports.length) {
                          // End of report history indicator
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Column(
                              children: [
                                Divider(color: cs.onSurface.withOpacity(0.1)),
                                const SizedBox(height: 32),
                                Icon(Icons.access_time,
                                    size: 48,
                                    color: cs.onSurface.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  'End of report history',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurface.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 48), // Bottom padding
                              ],
                            ),
                          );
                        }

                        final report = filteredReports[index];
                        return _ReportCard(
                          report: report,
                          onTap: () {
                            // Currently no-op or navigate
                          },
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

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = report['color'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                report['icon'] as IconData,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          report['type'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: report['statusBg'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          report['status'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: report['statusColor'] as Color,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Date Time
                  Text(
                    report['date'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: cs.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report['address'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
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
