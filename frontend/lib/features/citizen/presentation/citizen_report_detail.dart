import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Citizen Report Detail Screen
/// Shown when a user taps on a report card in their history.
class CitizenReportDetail extends StatelessWidget {
  final Map<String, dynamic> report;

  const CitizenReportDetail({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final color = report['color'] as Color;
    final statusColor = report['statusColor'] as Color;
    final statusBg = report['statusBg'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Topbar ───────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  // Back button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: cs.onSurface.withOpacity(0.7)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'REPORT DETAILS',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // Balance spacer — same width as back button
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Identity Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: icon + type + status
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(report['icon'] as IconData, color: color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (report['category'] as String).toUpperCase(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.4),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      report['type'] as String,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.headingColor,
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  report['status'] as String,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          const SizedBox(height: 14),

                          // Location
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 14, color: cs.onSurface.withOpacity(0.4)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  report['address'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 14, color: cs.onSurface.withOpacity(0.4)),
                              const SizedBox(width: 6),
                              Text(
                                report['date'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ID #${report['id']}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurface.withOpacity(0.45),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Status Tracking ────────────────────────────────────
                    Text(
                      'STATUS TRACKING',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: cs.onSurface.withOpacity(0.45),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusTracker(
                      theme: theme,
                      cs: cs,
                      isResolved: report['status'] == 'RESOLVED',
                    ),
                    const SizedBox(height: 24),

                    // ── Provided Details ──────────────────────────────────
                    Text(
                      'PROVIDED DETAILS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: cs.onSurface.withOpacity(0.45),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Notes',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Incident reported via the RapidAid mobile application. Emergency services were requested at the specified location.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.headingColor,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          const SizedBox(height: 16),
                          Text(
                            'Attachments',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.videocam_rounded, size: 16, color: color),
                              const SizedBox(width: 8),
                              Text(
                                'video_evidence_1.mp4',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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

class _StatusTracker extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  final bool isResolved;

  const _StatusTracker({
    required this.theme,
    required this.cs,
    required this.isResolved,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Report Submitted', 'System received your emergency report.', true),
      ('Reviewed by Dispatch', 'A dispatcher has assessed the situation.', true),
      ('Responder Assigned', 'Unit 402 has been assigned to your location.', isResolved),
      ('Incident Resolved', 'Emergency services have cleared the scene.', isResolved),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline spine
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: step.$3
                          ? AppTheme.primary
                          : cs.onSurface.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.$3
                            ? AppTheme.primary.withOpacity(0.3)
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: step.$3 
                        ? AppTheme.primary.withOpacity(0.5) 
                        : cs.onSurface.withOpacity(0.1),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.$1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: step.$3 
                            ? AppTheme.headingColor 
                            : cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.$2,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
