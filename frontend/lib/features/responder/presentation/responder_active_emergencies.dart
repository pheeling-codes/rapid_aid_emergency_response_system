import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/network/network_client.dart';
import 'package:dio/dio.dart';
import '../../../main.dart';
import '../../auth/data/token_storage.dart';
import '../../../core/widgets/user_profile_avatar.dart';

class ResponderActiveEmergencies extends StatefulWidget {
  const ResponderActiveEmergencies({super.key});

  @override
  State<ResponderActiveEmergencies> createState() =>
      _ResponderActiveEmergenciesState();
}

class _ResponderActiveEmergenciesState
    extends State<ResponderActiveEmergencies> {
  List<dynamic> _emergencies = [];
  bool _isLoading = true;
  bool _hasActiveIncident = false;

  @override
  void initState() {
    super.initState();
    _fetchEmergencies();
  }

  Future<void> _fetchEmergencies() async {
    try {
      final dio = getIt<NetworkClient>().dio;
      final res =
          await dio.get('/incidents/', queryParameters: {'feed': 'global'});
      final activeRes = await dio.get('/incidents/');

      if (mounted) {
        setState(() {
          _emergencies =
              (res.data is List) ? res.data : res.data['results'] ?? [];
          final myIncidents = (activeRes.data is List)
              ? activeRes.data as List
              : activeRes.data['results'] ?? [];
          _hasActiveIncident = myIncidents.any((inc) =>
              inc['status'] == 'EN_ROUTE' || inc['status'] == 'ON_SCENE');
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch global feed error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Topbar ─────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 20, color: cs.onSurface.withOpacity(0.7)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'ACTIVE EMERGENCIES',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppTheme.headingColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: cs.surfaceContainerHigh, width: 2),
                    ),
                    child: const UserProfileAvatar(radius: 16),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Live Queue Pill
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: const Color(0xFFFFCC02).withOpacity(0.4),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFA000),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LIVE QUEUE: ${_emergencies.length} PENDING',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: const Color(0xFF795548),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_emergencies.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            'No active emergencies at this time.',
                            style:
                                TextStyle(color: cs.onSurface.withOpacity(0.5)),
                          ),
                        ),
                      )
                    else
                      ..._emergencies.map(
                        (e) => _EmergencyCard(
                          item: e,
                          theme: theme,
                          cs: cs,
                          isDisabled: _hasActiveIncident,
                        ),
                      ),
                    const SizedBox(height: 4),

                    // Tactical Map Banner
                    _TacticalMapBanner(theme: theme, cs: cs),
                    const SizedBox(height: 16),
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

class _EmergencyCard extends StatefulWidget {
  final dynamic item;
  final ThemeData theme;
  final ColorScheme cs;
  final bool isDisabled;

  const _EmergencyCard({
    required this.item,
    required this.theme,
    required this.cs,
    this.isDisabled = false,
  });

  @override
  State<_EmergencyCard> createState() => _EmergencyCardState();
}

class _EmergencyCardState extends State<_EmergencyCard> {
  bool _isAccepting = false;

  Future<void> _acceptDispatch() async {
    setState(() => _isAccepting = true);
    try {
      final dio = getIt<NetworkClient>().dio;
      final ts = getIt<TokenStorage>();
      final userId = ts
          .getUserId(); // We need to store user ID in TokenStorage, but actually django auth uses JWT user_id implicitly.
      // Wait, we need the integer ID. We can extract it from the JWT. Or the backend uses request.user!
      // In IncidentSerializer, `assigned_responder` is a user ID. So we need to pass it.
      // Wait, if I just send `PATCH` with `{"status": "EN_ROUTE"}` and let the backend handle the assignment?
      // No, `assigned_responder` must be provided. Let me just use `ts.getUserId()`.

      await dio.patch('/incidents/${widget.item['id']}/', data: {
        'status': 'EN_ROUTE',
        'assigned_responder': ts.getUserId(),
      });
      if (mounted) {
        context.go('/responder/map');
      }
    } catch (e) {
      debugPrint('Accept error: $e');
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = widget.theme;
    final cs = widget.cs;

    // Parse the item
    final category = item['category'] ?? 'EMERGENCY';
    final title = item['title'] ?? 'Emergency';
    final address = item['address'] ?? 'Unknown location';
    final desc = item['description'] ?? '';
    final createdAt = item['created_at'];
    final timeAgo = createdAt != null
        ? '${DateTime.now().difference(DateTime.parse(createdAt)).inMinutes}m ago'
        : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category + Live dot
          Row(
            children: [
              Text(
                category,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.emergencyUrl,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppTheme.headingColor,
            ),
          ),
          const SizedBox(height: 10),

          // Distance + ETA
          Row(
            children: [
              _InfoBadge(
                icon: Icons.navigation_rounded,
                text: address.length > 20
                    ? '${address.substring(0, 20)}...'
                    : address,
                theme: theme,
                cs: cs,
              ),
              const SizedBox(width: 12),
              _InfoBadge(
                icon: Icons.timer_rounded,
                text: timeAgo,
                theme: theme,
                cs: cs,
                iconColor: const Color(0xFFD32F2F),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Action Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (widget.isDisabled || _isAccepting)
                      ? null
                      : _acceptDispatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isAccepting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Accept Dispatch',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: widget.isDisabled
                                ? cs.onSurface.withOpacity(0.5)
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.map_rounded,
                    size: 20, color: cs.onSurface.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;
  final ColorScheme cs;
  final Color? iconColor;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.theme,
    required this.cs,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14, color: iconColor ?? cs.onSurface.withOpacity(0.45)),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.65),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TacticalMapBanner extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;

  const _TacticalMapBanner({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: cs.onSurface.withOpacity(0.3),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              "You've reached the end of active emergencies.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
