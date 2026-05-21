import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';

/// Responder Map Screen
/// Shows live tactical map with active incident panel and route animation.
class ResponderMapScreen extends StatefulWidget {
  const ResponderMapScreen({super.key});

  @override
  State<ResponderMapScreen> createState() => _ResponderMapScreenState();
}

class _ResponderMapScreenState extends State<ResponderMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _routeController;
  late Animation<double> _routeAnimation;

  int _statusIndex = 0; // 0=EN ROUTE, 1=ON SCENE, 2=RESOLVED
  final List<String> _statusLabels = ['EN ROUTE', 'ON SCENE', 'RESOLVED'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _routeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _routeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF1A2535),
      body: Stack(
        children: [
          // ── Dark Tactical Map Background ─────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _TacticalGridPainter()),
          ),

          // ── Animated Cyan Route Arc ───────────────────────────────────────
          Positioned(
            left: size.width * 0.18,
            top: size.height * 0.19,
            width: size.width * 0.55,
            height: size.height * 0.20,
            child: AnimatedBuilder(
              animation: _routeAnimation,
              builder: (_, __) => CustomPaint(
                painter: _RoutePainter(progress: _routeAnimation.value),
              ),
            ),
          ),

          // ── Incident Location Pin (Red pulsing) ───────────────────────────
          Positioned(
            right: size.width * 0.18,
            top: size.height * 0.142,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 20 + (40 * _pulseAnimation.value),
                    height: 20 + (40 * _pulseAnimation.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.emergencyUrl.withOpacity(
                        0.35 * (1 - _pulseAnimation.value),
                      ),
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.emergencyUrl,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.emergencyUrl.withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Unit 402 Location Pin (Blue) ──────────────────────────────────
          Positioned(
            left: size.width * 0.14,
            top: size.height * 0.36,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 30 + (20 * _pulseAnimation.value),
                      height: 30 + (20 * _pulseAnimation.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withOpacity(
                          0.3 * (1 - _pulseAnimation.value),
                        ),
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 14),
              color: Colors.white,
              child: Row(
                children: [
                  const RapidAidLogo(size: 32, iconSize: 18),
                  // Centered: text + LIVE badge on same line
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ACTIVE EMERGENCY · UNIT 402',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.emergencyUrl,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFFE5E7EB), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFF3F4F6),
                      child: Icon(Icons.person_rounded,
                          color: Color(0xFF9CA3AF), size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── ETA Pill ──────────────────────────────────────────────────────
          Positioned(
            top: topPad + 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.navigation_rounded, color: cs.primary, size: 18),
                    const SizedBox(width: 10),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'ESTIMATED ARRIVAL: ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppTheme.headingColor.withOpacity(0.7),
                            ),
                          ),
                          TextSpan(
                            text: '3 MINS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Side Controls ─────────────────────────────────────────────────
          Positioned(
            right: 14,
            top: topPad + 130,
            child: Column(
              children: [
                _MapControlButton(
                  icon: Icons.layers_rounded,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _MapControlButton(
                  icon: Icons.my_location_rounded,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _MapControlButton(
                  icon: Icons.chat_rounded,
                  color: cs.primary,
                  iconColor: Colors.white,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ── Bottom Incident Sheet ─────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.50,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB).withOpacity(0.97),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Active Incident label + Priority
                              Row(
                                children: [
                                  Text(
                                    'ACTIVE INCIDENT',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: cs.onSurface.withOpacity(0.45),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.emergencyUrl
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'PRIORITY 1',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: AppTheme.emergencyUrl,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Cardiac Arrest',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.emergencyUrl,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Patient card + Location card
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoCard(
                                      label: 'PATIENT',
                                      title: 'Male, ~65yrs',
                                      subtitle: 'Unresponsive',
                                      theme: theme,
                                      cs: cs,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoCard(
                                      label: 'LOCATION',
                                      title: 'Grand Central',
                                      subtitle: 'Platform 4B',
                                      theme: theme,
                                      cs: cs,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Description
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DESCRIPTION',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.4),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '65-year-old male collapsed on Platform 4B. Bystander performing CPR. AED on-site requested. Heavy crowd — clear path needed.',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.65),
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Scene Attachments
                              Text(
                                'SCENE ATTACHMENTS (3)',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.45),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _AttachmentThumb(
                                      color: const Color(0xFF263238)),
                                  const SizedBox(width: 8),
                                  _AttachmentThumb(
                                      color: const Color(0xFF37474F)),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: cs.onSurface.withOpacity(0.1),
                                          width: 1.5),
                                    ),
                                    child: Icon(Icons.add_a_photo_rounded,
                                        color: cs.onSurface.withOpacity(0.3),
                                        size: 22),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Status Toggle Row
                              _StatusToggle(
                                selectedIndex: _statusIndex,
                                labels: _statusLabels,
                                onSelect: (i) =>
                                    setState(() => _statusIndex = i),
                                cs: cs,
                                theme: theme,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;

  const _MapControlButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? const Color(0xFF374151),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final ThemeData theme;
  final ColorScheme cs;

  const _InfoCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.headingColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  final Color color;
  const _AttachmentThumb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_rounded, color: Colors.white54, size: 24),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelect;
  final ColorScheme cs;
  final ThemeData theme;

  const _StatusToggle({
    required this.selectedIndex,
    required this.labels,
    required this.onSelect,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEFF1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (i == 0
                          ? AppTheme.emergencyUrl
                          : i == 1
                              ? AppTheme.primary
                              : const Color(0xFF2E7D32))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (i == 0
                                    ? AppTheme.emergencyUrl
                                    : AppTheme.primary)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : cs.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Custom Painters ───────────────────────────────────────────────────────────

class _TacticalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dark base fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A2535),
    );

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Road-like horizontal band
    final roadPaint = Paint()
      ..color = const Color(0xFF243044)
      ..strokeWidth = 20;
    canvas.drawLine(
      Offset(0, size.height * 0.28),
      Offset(size.width, size.height * 0.28),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.38),
      Offset(size.width, size.height * 0.38),
      roadPaint,
    );

    // Vertical road
    final vRoadPaint = Paint()
      ..color = const Color(0xFF243044)
      ..strokeWidth = 14;
    canvas.drawLine(
      Offset(size.width * 0.38, 0),
      Offset(size.width * 0.38, size.height),
      vRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  final double progress;
  const _RoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.9)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Route goes from Unit 402 pin position (bottom-left)
    // to Incident pin position (top-right)
    // Matching Positioned offsets:
    //   Unit pin: left=14%, top=36%  -> canvas coords ~(0.14*W, 0.36*H)
    //   Incident: right=17% -> left=83%, top=17% -> (0.83*W, 0.17*H)
    // The RoutePainter is positioned left=18%, top=17%, width=55%, height=30%
    // So inside painter canvas: start=(0,1.0) end=(1.0,0) is already close.
    // We use absolute proportions within the canvas box:
    final start = Offset(0, size.height); // bottom-left (Unit 402)
    final end = Offset(size.width, 0); // top-right (Incident)

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.75,
      size.height * 0.3,
      end.dx,
      end.dy,
    );

    // Animated partial draw
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }

    // Glowing dot at current progress position
    final pathMetrics2 = path.computeMetrics();
    for (final metric in pathMetrics2) {
      final tangent = metric.getTangentForOffset(metric.length * progress);
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          6,
          Paint()
            ..color = const Color(0xFF00E5FF)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          tangent.position,
          10,
          Paint()
            ..color = const Color(0xFF00E5FF).withOpacity(0.25)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.progress != progress;
}
