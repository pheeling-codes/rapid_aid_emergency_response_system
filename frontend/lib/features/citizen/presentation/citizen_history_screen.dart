import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';

/// Citizen History Screen
/// High-density list of past reports using tonal cards (no divider lines)
/// Uses 8dp grid system for vertical rhythm
class CitizenHistoryScreen extends StatelessWidget {
  CitizenHistoryScreen({super.key});

  // Mock data for history
  final List<Map<String, dynamic>> _reports = [
    {
      'id': 'RA-992-01',
      'type': 'Medical',
      'icon': '🏥',
      'color': const Color(0xFF005EB8),
      'date': 'Jan 15, 2026',
      'status': 'Resolved',
      'description': 'Medical emergency at home',
    },
    {
      'id': 'RA-991-03',
      'type': 'Fire',
      'icon': '🔥',
      'color': const Color(0xFFD32F2F),
      'date': 'Jan 10, 2026',
      'status': 'Resolved',
      'description': 'Small kitchen fire',
    },
    {
      'id': 'RA-988-02',
      'type': 'Accident',
      'icon': '🚗',
      'color': const Color(0xFF445E91),
      'date': 'Dec 28, 2025',
      'status': 'Resolved',
      'description': 'Vehicle collision on highway',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'HISTORY',
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Past Reports',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.headingColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Reports List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _reports.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return _ReportCard(
                    report: report,
                    onTap: () {
                      // TODO: Navigate to report details
                      context.push(
                        '/citizen/report-details',
                        extra: report,
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Report Card Widget
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  report['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        report['type'] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.headingColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report['status'] as String,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppTheme.primary,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['description'] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.bodyColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report['id'] as String,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.bodyColor.withOpacity(0.5),
                    ),
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
