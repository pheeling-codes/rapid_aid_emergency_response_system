import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// CitizenReportDetailsScreen - Detailed view of a specific report
/// Migrated from report_details_screen.dart with Clinical Vanguard design compliance
class CitizenReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const CitizenReportDetailsScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        title: Text(
          'Incident Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title card - Using surfaceContainerLowest
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Incident Report',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Date',
                    value: data['date'] ?? 'Unknown',
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Location',
                    value: data['location'] ?? 'Unknown',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Status',
                    value: data['status'] ?? 'Unknown',
                    icon: Icons.info_outline,
                    valueColor: _getStatusColor(data['status']),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Map snapshot placeholder - Using surfaceContainerLow
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: AppTheme.bodyColor.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Incident Location Map',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.bodyColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
        return AppTheme.primary;
      case 'cancelled':
        return AppTheme.bodyColor.withOpacity(0.5);
      case 'active':
      case 'pending':
        return AppTheme.emergencyUrl;
      default:
        return AppTheme.bodyColor.withOpacity(0.6);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.bodyColor.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.headingColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
