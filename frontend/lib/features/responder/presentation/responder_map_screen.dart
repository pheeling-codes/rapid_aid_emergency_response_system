import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../../core/network/network_client.dart';
import '../../../main.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/user_profile_avatar.dart';

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

  final Completer<GoogleMapController> _mapController = Completer();
  Map<String, dynamic>? _activeIncident;
  bool _isLoading = true;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _fetchActiveIncident();
    _startLocationTracking();
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
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _fetchActiveIncident() async {
    try {
      final dio = getIt<NetworkClient>().dio;
      // responders automatically get assigned incidents
      final res = await dio.get('/incidents/');
      final dataList = (res.data is List)
          ? res.data as List
          : res.data['results'] as List? ?? [];

      final active = dataList
          .where((inc) =>
              inc['status'] == 'EN_ROUTE' || inc['status'] == 'ON_SCENE')
          .toList();

      if (active.isNotEmpty) {
        final activeId = active.first['id'];
        final detailRes = await dio.get('/incidents/$activeId/');
        final incident = detailRes.data;
        if (mounted) {
          setState(() {
            _activeIncident = incident;
            _statusIndex = incident['status'] == 'ON_SCENE' ? 1 : 0;
            _isLoading = false;
          });
          if (_currentPosition != null) _setupMapElements();
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Fetch active incident error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _currentPosition = await Geolocator.getCurrentPosition();
    if (_activeIncident != null && _markers.isEmpty) {
      _setupMapElements();
    }
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      if (mounted) {
        setState(() => _currentPosition = position);
        _updateResponderMarker();
      }
    });
  }

  void _setupMapElements() async {
    if (_activeIncident == null || _currentPosition == null) return;

    final loc = _activeIncident!['location_coords'];
    if (loc == null) return;

    final incLat = loc['lat'];
    final incLng = loc['lng'];

    _markers.add(Marker(
      markerId: const MarkerId('incident'),
      position: LatLng(incLat, incLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _updateResponderMarker();

    // Fit map bounds
    final map = await _mapController.future;
    map.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(
          incLat < _currentPosition!.latitude
              ? incLat
              : _currentPosition!.latitude,
          incLng < _currentPosition!.longitude
              ? incLng
              : _currentPosition!.longitude,
        ),
        northeast: LatLng(
          incLat > _currentPosition!.latitude
              ? incLat
              : _currentPosition!.latitude,
          incLng > _currentPosition!.longitude
              ? incLng
              : _currentPosition!.longitude,
        ),
      ),
      100,
    ));

    _fetchRoute(incLat, incLng);
  }

  void _updateResponderMarker() {
    if (_currentPosition == null) return;
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'responder');
      _markers.add(Marker(
        markerId: const MarkerId('responder'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }

  Future<void> _fetchRoute(double destLat, double destLng) async {
    if (_currentPosition == null) return;
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) return;

    final origin =
        '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final dest = '$destLat,$destLng';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&key=$apiKey';

    try {
      final dio = getIt<NetworkClient>().dio;
      final response = await dio.get(url);
      final routes = response.data['routes'] as List;
      if (routes.isNotEmpty) {
        final polylineStr = routes[0]['overview_polyline']['points'];
        final points = _decodePolyline(polylineStr);
        if (mounted) {
          setState(() {
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              color: AppTheme.primary,
              width: 5,
              points: points,
            ));
          });
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Future<void> _updateStatus(int newIndex) async {
    if (_activeIncident == null || newIndex == 0) return;

    // Progression Rule: Cannot resolve unless previously on scene
    if (newIndex == 2 && _activeIncident!['status'] != 'ON_SCENE') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You must mark the incident as On Scene before resolving it.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final theme = Theme.of(context);
    String newStatusStr = newIndex == 1 ? 'ON_SCENE' : 'RESOLVED';
    String actionName = newIndex == 1 ? 'On Scene' : 'Resolved';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Confirm Status',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        content:
            Text('Are you sure you want to mark this incident as $actionName?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    newIndex == 1 ? Colors.green : AppTheme.primary),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _statusIndex = newIndex);

    try {
      final dio = getIt<NetworkClient>().dio;
      await dio.patch('/incidents/${_activeIncident!['id']}/', data: {
        'status': newStatusStr,
      });

      if (mounted) {
        setState(() {
          _activeIncident!['status'] = newStatusStr;
        });
      }

      if (newIndex == 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Incident Resolved successfully'),
                backgroundColor: Colors.green),
          );
          context.go('/responder/history');
        }
        setState(() {
          _activeIncident = null;
          _statusIndex = 0;
          _markers.clear();
          _polylines.clear();
        });
      }
    } catch (e) {
      debugPrint('Update status error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red));
        setState(() =>
            _statusIndex = _activeIncident!['status'] == 'ON_SCENE' ? 1 : 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF1A2535),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeIncident == null
              ? _buildStandbyMap()
              : _buildActiveMap(theme, cs, size, topPad),
    );
  }

  Widget _buildStandbyMap() {
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(6.5244, 3.3792),
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                const RapidAidLogo(size: 32, iconSize: 18),
                Expanded(
                    child: Center(
                        child: Text('STANDBY MODE',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.headingColor,
                                letterSpacing: 1.0)))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveMap(
      ThemeData theme, ColorScheme cs, Size size, double topPad) {
    return Stack(
      children: [
        // ── Dark Tactical Map Background ─────────────────────────────────
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5244, 3.3792),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
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
                  child: const UserProfileAvatar(radius: 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          text: 'ESTIMATED ETA: ',
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
                                    color:
                                        AppTheme.emergencyUrl.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'PRIORITY 1',
                                    style: theme.textTheme.labelSmall?.copyWith(
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
                              _activeIncident!['title'] ?? 'Emergency',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.emergencyUrl,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Location card
                            SizedBox(
                              width: double.infinity,
                              child: _InfoCard(
                                label: 'LOCATION',
                                title: _activeIncident!['address'] ??
                                    'Unknown location',
                                subtitle: 'Active Incident',
                                theme: theme,
                                cs: cs,
                              ),
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
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: cs.onSurface.withOpacity(0.4),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      fontSize: 9,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _activeIncident!['description'] ??
                                        'No description provided.',
                                    style: theme.textTheme.bodySmall?.copyWith(
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
                              'SCENE ATTACHMENTS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.45),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Builder(builder: (context) {
                              final List evidences =
                                  _activeIncident!['evidences'] ?? [];
                              if (evidences.isEmpty) {
                                return Text('No evidence attached',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.5)));
                              }
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: evidences.map((e) {
                                  try {
                                    final imgBytes = e.toString().contains(',')
                                        ? base64Decode(
                                            e.toString().split(',').last)
                                        : base64Decode(e.toString());
                                    return Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                            image: MemoryImage(imgBytes),
                                            fit: BoxFit.cover),
                                      ),
                                    );
                                  } catch (_) {
                                    return const SizedBox();
                                  }
                                }).toList(),
                              );
                            }),
                            const SizedBox(height: 18),

                            // Status Toggle Row
                            _StatusToggle(
                              selectedIndex: _statusIndex,
                              labels: _statusLabels,
                              disabledIndices:
                                  _activeIncident!['status'] != 'ON_SCENE'
                                      ? [2]
                                      : [],
                              onSelect: _updateStatus,
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
  final List<int> disabledIndices;
  final ValueChanged<int> onSelect;
  final ColorScheme cs;
  final ThemeData theme;

  const _StatusToggle({
    required this.selectedIndex,
    required this.labels,
    this.disabledIndices = const [],
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
          final isDisabled = disabledIndices.contains(i);
          return Expanded(
            child: GestureDetector(
              onTap: isDisabled ? null : () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (i == 0
                          ? AppTheme.emergencyUrl
                          : i == 1
                              ? const Color(0xFF2E7D32)
                              : AppTheme.primary)
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
                          : (isDisabled
                              ? cs.onSurface.withOpacity(0.2)
                              : cs.onSurface.withOpacity(0.5)),
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
