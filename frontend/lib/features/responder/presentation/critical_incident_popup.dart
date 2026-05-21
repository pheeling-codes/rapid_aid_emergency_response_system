import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Critical Incident Popup — centered dialog with blur overlay.
class CriticalIncidentPopup extends StatefulWidget {
  const CriticalIncidentPopup({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (ctx, _, __) => const CriticalIncidentPopup(),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.93, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CriticalIncidentPopup> createState() => _CriticalIncidentPopupState();
}

class _CriticalIncidentPopupState extends State<CriticalIncidentPopup>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  late AnimationController _barCtrl;
  late Animation<double> _barPulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _barPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isAccept = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isAccept ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor:
            isAccept ? AppTheme.primary : const Color(0xFF374151),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ── Full-screen blur overlay (non-dismissible) ───────────────
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          // ── Centered dialog card ────────────────────────────────────────
          Center(
            child: Container(
              width: size.width * 0.92,
              constraints: BoxConstraints(maxHeight: size.height * 0.88),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Red Alert Banner with inline X button ─────────────
                    AnimatedBuilder(
                      animation: _barPulse,
                      builder: (_, __) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        color: AppTheme.emergencyUrl
                            .withOpacity(0.85 + 0.15 * _barPulse.value),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'CRITICAL DISPATCH: INCOMING ALERT',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // X close button — inside the banner
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.22),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Scrollable body ─────────────────────────────────────
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Priority + ID row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.emergencyUrl,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'PRIORITY 1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'ID #RA-9412',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Incident Title
                            Text(
                              'Medical Emergency',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.headingColor,
                                letterSpacing: -1.0,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Description
                            Text(
                              '65-year-old male collapsed at Grand Central Station, Platform 4B. Bystander CPR in progress. AED on-site. Heavy crowd — clear path needed urgently.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6B7280),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Zone / Distance info cards
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoTile(
                                    label: 'ZONE',
                                    icon: Icons.location_on_rounded,
                                    iconColor: AppTheme.primary,
                                    value: 'SECTOR 4G',
                                    theme: theme,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _InfoTile(
                                    label: 'DISTANCE',
                                    icon: Icons.straighten_rounded,
                                    iconColor: AppTheme.primary,
                                    value: '1.2km away',
                                    theme: theme,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Tactical Dark Map Preview
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 160,
                                child: Stack(
                                  children: [
                                    // Dark background + grid
                                    Container(
                                      color: const Color(0xFF0D1B2A),
                                      child: CustomPaint(
                                        painter: _DispatchGridPainter(),
                                        child: const SizedBox.expand(),
                                      ),
                                    ),
                                    // Unit 402 dot
                                    const Positioned(
                                      left: 60,
                                      top: 85,
                                      child: _UnitDot(),
                                    ),
                                    // Incident pin (pulsing)
                                    Positioned(
                                      right: 60,
                                      top: 26,
                                      child: AnimatedBuilder(
                                        animation: _pulse,
                                        builder: (_, __) => Transform.scale(
                                          scale: _pulse.value,
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: AppTheme.emergencyUrl,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.emergencyUrl
                                                      .withOpacity(0.5),
                                                  blurRadius: 14,
                                                  spreadRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                                Icons.location_pin,
                                                color: Colors.white,
                                                size: 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // ETA pill
                                    Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.access_time_rounded,
                                                  size: 13,
                                                  color:
                                                      AppTheme.emergencyUrl),
                                              const SizedBox(width: 6),
                                              Text.rich(
                                                TextSpan(children: [
                                                  TextSpan(
                                                    text:
                                                        'ESTIMATED ARRIVAL: ',
                                                    style: theme
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppTheme
                                                          .headingColor
                                                          .withOpacity(0.6),
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: '4 MINS',
                                                    style: theme
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: AppTheme
                                                          .emergencyUrl,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // ACCEPT button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: () => _showToast(
                                  'Incident accepted — dispatching Unit 402.',
                                  isAccept: true,
                                ),
                                icon: const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 20),
                                label: const Text(
                                  'ACCEPT INCIDENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.emergencyUrl,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // DECLINE
                            Center(
                              child: TextButton(
                                onPressed: () => _showToast(
                                  'Incident declined.',
                                  isAccept: false,
                                ),
                                child: Text(
                                  'DECLINE',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            // Hint
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Text(
                                  'HOLD ACCEPT TO CONFIRM DEPLOYMENT',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFFD1D5DB),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _UnitDot extends StatelessWidget {
  const _UnitDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primary, width: 2),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor;
  final ThemeData theme;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.headingColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DispatchGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00B4D8).withOpacity(0.07)
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFF112233)
      ..strokeWidth = 18;
    canvas.drawLine(Offset(0, size.height * 0.55),
        Offset(size.width, size.height * 0.55), roadPaint);
    canvas.drawLine(Offset(size.width * 0.42, 0),
        Offset(size.width * 0.42, size.height), roadPaint);

    final accentPaint = Paint()
      ..color = const Color(0xFF00B4D8).withOpacity(0.15)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height * 0.55),
        Offset(size.width, size.height * 0.55), accentPaint);
    canvas.drawLine(Offset(size.width * 0.42, 0),
        Offset(size.width * 0.42, size.height), accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
