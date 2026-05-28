import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../../core/widgets/user_profile_avatar.dart';
import 'critical_incident_popup.dart';
import '../../../main.dart';
import '../../../features/auth/data/token_storage.dart';
import '../../../core/network/network_client.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
class ResponderDashboard extends StatefulWidget {
  const ResponderDashboard({super.key});

  @override
  State<ResponderDashboard> createState() => _ResponderDashboardState();
}

class _ResponderDashboardState extends State<ResponderDashboard>
    with TickerProviderStateMixin {
  bool _isOnDuty = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _dispatchTimer;
  bool _isPopupShowing = false;
  StreamSubscription<Position>? _positionStream;
  DateTime? _lastUploadTime;
  Map<String, dynamic>? _activeIncident;

  // Simulated shift timer state
  int _hours = 4, _minutes = 12, _seconds = 5;
  String _userEmail = '';
  String _userRole = '';
  String _userName = '';

  final List<Map<String, String>> _shiftHistory = [
    {
      'date': 'Oct 24 Shift',
      'range': '08:00 - 18:00 · 10h Total',
      'status': 'COMPLETED'
    },
    {
      'date': 'Oct 23 Shift',
      'range': '08:00 - 18:15 · 10.25h Total',
      'status': 'COMPLETED'
    },
    {
      'date': 'Oct 22 Shift',
      'range': '07:45 - 17:30 · 9.75h Total',
      'status': 'COMPLETED'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Schedule the first popup
    _scheduleDispatchPopup();

    final ts = getIt<TokenStorage>();
    _userEmail = ts.getUserEmail() ?? 'Responder';
    _userRole = ts.getUserRole() ?? 'RESPONDER';
    _userName = ts.getUserName() ?? _userEmail.split('@').first;
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final dio = getIt<NetworkClient>().dio;
      final res = await dio.get('/auth/me/');
      if (mounted) {
        setState(() {
          _isOnDuty = res.data['is_available'] ?? false;
        });
        if (_isOnDuty) _startTelemetry();
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
    }
  }

  Future<void> _toggleDuty(bool value) async {
    setState(() => _isOnDuty = value);
    try {
      final dio = getIt<NetworkClient>().dio;
      await dio.patch('/auth/me/', data: {'is_available': value});
      if (value) {
        _startTelemetry();
      } else {
        _stopTelemetry();
      }
    } catch (e) {
      debugPrint('Toggle duty error: $e');
      setState(() => _isOnDuty = !value);
    }
  }

  void _startTelemetry() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _uploadLocation(position);
    });
  }

  void _stopTelemetry() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  void _uploadLocation(Position pos) async {
    final now = DateTime.now();
    if (_lastUploadTime != null && now.difference(_lastUploadTime!).inSeconds < 15) return;
    _lastUploadTime = now;
    
    try {
      final dio = getIt<NetworkClient>().dio;
      await dio.patch('/auth/location/', data: {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });
    } catch (e) {
      debugPrint('Location upload error: $e');
    }
  }

  void _scheduleDispatchPopup() {
    _dispatchTimer?.cancel();
    _dispatchTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!mounted || !_isOnDuty || _activeIncident != null || _isPopupShowing) return;

      try {
        final dio = getIt<NetworkClient>().dio;
        final res = await dio.get('/incidents/', queryParameters: {'feed': 'global'});
        final emergencies = (res.data is List) ? res.data as List : res.data['results'] ?? [];
        if (emergencies.isEmpty) return;

        final now = DateTime.now();
        final recentEmergencies = emergencies.where((e) {
          final createdAt = DateTime.tryParse(e['created_at'] ?? '');
          if (createdAt == null) return false;
          // Only show if created within the last 2 minutes
          return now.difference(createdAt).inMinutes <= 2;
        }).toList();

        if (recentEmergencies.isEmpty) return;

        if (mounted) {
          _isPopupShowing = true;
          await CriticalIncidentPopup.show(context, incident: recentEmergencies.first);
          if (mounted) _isPopupShowing = false;
        }
      } catch (e) {
        debugPrint('Popup poll error: $e');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dispatchTimer?.cancel();
    _stopTelemetry();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed Topbar ──────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              color: Colors.white,
              child: Row(
                children: [
                  const RapidAidLogo(size: 32, iconSize: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'RAPID AID',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _userName,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _userRole,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      _ProfileAvatar(cs: cs),
                    ],
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Active Deployment Toggle
                    _DeploymentToggle(
                      isOnDuty: _isOnDuty,
                      onChanged: _toggleDuty,
                      cs: cs,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),

                    // Background Location pill
                    _LocationActivePill(theme: theme, cs: cs),
                    const SizedBox(height: 20),

                    // Unit Identity Card
                    _UnitIdentityCard(cs: cs, theme: theme),
                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'TODAY SHIFT',
                            value:
                                '${_twoDigits(_hours)}:${_twoDigits(_minutes)}:${_twoDigits(_seconds)}',
                            cs: cs,
                            theme: theme,
                            isMonospace: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'INCIDENTS',
                            value: '03',
                            trailing: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F),
                                shape: BoxShape.circle,
                              ),
                            ),
                            cs: cs,
                            theme: theme,
                            isMonospace: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Map Preview Card
                    _MapPreviewCard(
                        pulseAnimation: _pulseAnimation, cs: cs, theme: theme),
                    const SizedBox(height: 20),

                    // Emergency Assist CTA
                    _EmergencyAssistButton(
                      onTap: () async {
                        _dispatchTimer?.cancel();
                        await context.push('/responder/active-emergencies');
                        if (mounted) _scheduleDispatchPopup();
                      },
                      theme: theme,
                    ),
                    const SizedBox(height: 28),

                    // Shift History
                    Text(
                      'SHIFT HISTORY',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._shiftHistory.map(
                      (s) => _ShiftHistoryItem(shift: s, theme: theme, cs: cs),
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final ColorScheme cs;
  const _ProfileAvatar({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.surfaceContainerHigh, width: 2),
      ),
      child: const UserProfileAvatar(radius: 16, defaultIcon: Icons.person_rounded),
    );
  }
}

class _DeploymentToggle extends StatelessWidget {
  final bool isOnDuty;
  final ValueChanged<bool> onChanged;
  final ColorScheme cs;
  final ThemeData theme;

  const _DeploymentToggle({
    required this.isOnDuty,
    required this.onChanged,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'ACTIVE DEPLOYMENT',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: cs.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Switch(
            value: isOnDuty,
            onChanged: onChanged,
            activeColor: cs.primary,
            // thumbColor: WidgetStateProperty.all(Colors.white),
            activeThumbColor: Colors.white,
            activeTrackColor: cs.primary,
            inactiveThumbColor: AppTheme.primary,
            inactiveTrackColor: const Color(0xFFEEF2F6),
          ),
          const SizedBox(width: 6),
          Text(
            isOnDuty ? 'On Duty' : 'Off Duty',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isOnDuty ? cs.primary : cs.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationActivePill extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  const _LocationActivePill({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded, size: 14, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            'BACKGROUND LOCATION ACTIVE',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cs.primary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitIdentityCard extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  const _UnitIdentityCard({required this.cs, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit 402',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.headingColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Responder Rank II',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medical_services_rounded,
                color: cs.primary, size: 26),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final ColorScheme cs;
  final ThemeData theme;
  final bool isMonospace;

  const _StatCard({
    required this.label,
    required this.value,
    required this.cs,
    required this.theme,
    required this.isMonospace,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: cs.onSurface.withOpacity(0.45),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: isMonospace ? 'monospace' : 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.headingColor,
                  letterSpacing: isMonospace ? 1.0 : -0.5,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final ColorScheme cs;
  final ThemeData theme;

  const _MapPreviewCard({
    required this.pulseAnimation,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2A3A), Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A3A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid pattern overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              painter: _GridPainter(),
              child: const SizedBox.expand(),
            ),
          ),

          // Pulsing location ring
          Center(
            child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring
                    Container(
                      width: 80 * pulseAnimation.value,
                      height: 80 * pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary
                            .withOpacity(0.12 * (2 - pulseAnimation.value)),
                      ),
                    ),
                    // Pin body (coral/red)
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE05345),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE05345).withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.person_pin,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Unit label tag
          Center(
            child: Transform.translate(
              offset: const Offset(0, 44),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 402',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),

          // GPS Accuracy label
          Positioned(
            bottom: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE GPS · 1.2m ACCURACY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmergencyAssistButton extends StatefulWidget {
  final VoidCallback onTap;
  final ThemeData theme;

  const _EmergencyAssistButton({required this.onTap, required this.theme});

  @override
  State<_EmergencyAssistButton> createState() => _EmergencyAssistButtonState();
}

class _EmergencyAssistButtonState extends State<_EmergencyAssistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.emergencyUrl,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.emergencyUrl.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '✱',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 12),
              Text(
                'EMERGENCY ASSIST',
                style: widget.theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftHistoryItem extends StatelessWidget {
  final Map<String, String> shift;
  final ThemeData theme;
  final ColorScheme cs;

  const _ShiftHistoryItem(
      {required this.shift, required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded,
                size: 18, color: cs.onSurface.withOpacity(0.4)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift['date']!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.headingColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  shift['range']!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              shift['status']!,
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
    );
  }
}
