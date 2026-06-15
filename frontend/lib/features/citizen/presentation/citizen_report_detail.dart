import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/network_client.dart';
import '../../../main.dart';

/// Citizen Report Detail Screen
/// Shown when a user taps on a report card in their history.
class CitizenReportDetail extends StatefulWidget {
  final Map<String, dynamic> report;

  const CitizenReportDetail({
    super.key,
    required this.report,
  });

  @override
  State<CitizenReportDetail> createState() => _CitizenReportDetailState();
}

class _CitizenReportDetailState extends State<CitizenReportDetail> {
  late Timer _timer;
  int _secondsLeft = 0;
  bool _canCancel = false;
  bool _isCancelling = false;
  List<dynamic> _loadedEvidences = [];

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
    
    _loadedEvidences = widget.report['evidences'] as List<dynamic>? ?? [];
    if (_loadedEvidences.isEmpty) {
      _fetchIncidentDetails();
    }
  }

  Future<void> _fetchIncidentDetails() async {
    try {
      final dio = getIt<NetworkClient>().dio;
      final res = await dio.get('/incidents/${widget.report['id']}/');
      if (res.data != null && res.data['evidences'] != null) {
        if (mounted) {
          setState(() {
            _loadedEvidences = res.data['evidences'] as List<dynamic>;
          });
        }
      }
    } catch (_) {}
  }

  void _calculateTimeLeft() {
    if (widget.report['status'] != 'ACTIVE') {
      if (_canCancel) setState(() => _canCancel = false);
      return;
    }
    try {
      final createdAt = DateTime.parse(widget.report['created_at'] as String).toLocal();
      final difference = DateTime.now().difference(createdAt).inSeconds;
      if (difference < 120) {
        if (mounted) {
          setState(() {
            _secondsLeft = 120 - difference;
            _canCancel = true;
          });
        }
      } else {
        if (_canCancel && mounted) {
          setState(() {
            _canCancel = false;
            _secondsLeft = 0;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _cancelEmergency() async {
    setState(() => _isCancelling = true);
    try {
      final dio = getIt<NetworkClient>().dio;
      await dio.patch('/incidents/${widget.report['id']}/cancel/');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Emergency cancelled successfully.'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel emergency.'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final color = widget.report['color'] as Color;
    final statusColor = widget.report['statusColor'] as Color;
    final statusBg = widget.report['statusBg'] as Color;
    final evidences = _loadedEvidences;

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
                                child: Icon(widget.report['icon'] as IconData, color: color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (widget.report['category'] as String).toUpperCase(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.4),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.report['type'] as String,
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
                                  widget.report['status'] as String,
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
                                  widget.report['address'] as String,
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
                                widget.report['date'] as String,
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
                                  'REF #${widget.report['ref_id']}',
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
                      isResolved: widget.report['status'] == 'RESOLVED',
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
                            widget.report['description'] as String,
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
                          if (evidences.isEmpty)
                            Text(
                              'No evidence attached.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.4),
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: evidences.map((base64Str) {
                                  // Determine if we need to split data URI scheme
                                  String pureBase64 = base64Str;
                                  if (pureBase64.contains(',')) {
                                    pureBase64 = pureBase64.split(',')[1];
                                  }
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.memory(
                                      base64Decode(pureBase64.replaceAll(RegExp(r'\s+'), '')),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (widget.report['status'] == 'ACTIVE') ...[
                      InkWell(
                        onTap: _canCancel && !_isCancelling ? _cancelEmergency : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          decoration: BoxDecoration(
                            color: _canCancel ? Colors.red.shade600 : cs.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: _isCancelling
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  _canCancel ? 'Cancel Emergency ($_secondsLeft\s)' : 'Cancel Emergency',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: _canCancel ? Colors.white : cs.onSurface.withOpacity(0.4),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                      if (!_canCancel)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            '2 full minutes have passed since the incident has been reported and hence the emergency can\'t be cancelled anymore.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                              height: 1.4,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
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
