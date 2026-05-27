import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../../core/network/network_client.dart';
import '../../../core/widgets/user_profile_avatar.dart';
import '../../../main.dart';
import '../../../features/auth/data/token_storage.dart';

class CitizenMapScreen extends StatefulWidget {
  const CitizenMapScreen({super.key});

  @override
  State<CitizenMapScreen> createState() => _CitizenMapScreenState();
}

class _CitizenMapScreenState extends State<CitizenMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  String _userName = '';
  String _userRole = '';
  bool _isLoading = true;

  List<dynamic> _activeIncidents = [];
  Map<String, dynamic>? _selectedIncident;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    final ts = getIt<TokenStorage>();
    final email = ts.getUserEmail() ?? 'Citizen';
    _userRole = ts.getUserRole() ?? 'CITIZEN';
    _userName = ts.getUserName() ?? email.split('@').first;
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    try {
      final dio = getIt<NetworkClient>().dio;
      final res = await dio.get('/incidents/');
      final dataList = (res.data is List)
          ? res.data as List
          : res.data['results'] as List? ?? [];

      final active = dataList
          .where((inc) =>
              inc['status'] == 'PENDING' ||
              inc['status'] == 'ACTIVE' ||
              inc['status'] == 'IN_PROGRESS')
          .toList();

      if (mounted) {
        setState(() {
          _activeIncidents = active;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onIncidentSelected(Map<String, dynamic> incident) {
    setState(() {
      _selectedIncident = incident;
      _markers.clear();
      _polylines.clear();

      final coords = incident['location_coords'];
      final respCoords = incident['responder_location'];

      LatLng? incLatLng;
      if (coords != null) {
        incLatLng = LatLng(coords['lat'], coords['lng']);
        _markers.add(Marker(
          markerId: MarkerId('incident_${incident['id']}'),
          position: incLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow:
              InfoWindow(title: 'Emergency', snippet: incident['title']),
        ));
      }

      LatLng? respLatLng;
      if (respCoords != null) {
        respLatLng = LatLng(respCoords['lat'], respCoords['lng']);
        _markers.add(Marker(
          markerId: MarkerId('responder_${incident['id']}'),
          position: respLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
              title: 'Responder',
              snippet: incident['responder_name'] ?? 'Assigned Unit'),
        ));
      }

      if (incLatLng != null && respLatLng != null) {
        _polylines.add(Polyline(
          polylineId: PolylineId('route_${incident['id']}'),
          points: [incLatLng, respLatLng],
          color: AppTheme.emergencyUrl,
          width: 5,
        ));
      }

      if (incLatLng != null) {
        _moveCamera(incLatLng);
      }
    });
  }

  Future<void> _moveCamera(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 15),
    ));
  }

  void _showIncidentPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return PointerInterceptor(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Active Incident',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.map, color: Colors.grey),
                      title: const Text('View Map Only (Clear Selection)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {
                        setState(() {
                          _selectedIncident = null;
                          _markers.clear();
                          _polylines.clear();
                        });
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    if (_activeIncidents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No active incidents found.'),
                      )
                    else
                      ..._activeIncidents.map((inc) {
                        final ref = inc['ref_id'] ??
                            inc['id'].toString().substring(0, 6);
                        final isSelected = _selectedIncident != null &&
                            _selectedIncident!['id'] == inc['id'];
                        return ListTile(
                          leading: Icon(Icons.emergency,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.primary),
                          title: Text('REF #$ref',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppTheme.primary : null)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppTheme.primary)
                              : null,
                          onTap: () {
                            _onIncidentSelected(inc);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Stack(
        children: [
          // ── MAP ────────────────────────────────────────────────────────
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5244, 3.3792), // Default to Lagos, Nigeria
              zoom: 11,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // ── TOPBAR ───────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 16, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const RapidAidLogo(size: 32, iconSize: 30),
                  Text(
                    'INCIDENT TRACKING',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: cs.surfaceContainerHigh, width: 2),
                        ),
                        child: const UserProfileAvatar(radius: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── DROPDOWN FOR INCIDENTS ─────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            child: PointerInterceptor(
              child: Material(
                elevation: 4,
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isLoading ? null : () => _showIncidentPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.onSurface.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isLoading
                              ? 'Loading active incidents...'
                              : _selectedIncident != null
                                  ? 'REF #${_selectedIncident!['ref_id'] ?? _selectedIncident!['id'].toString().substring(0, 6)}'
                                  : 'Select active incident...',
                          style: TextStyle(
                            color: _selectedIncident != null
                                ? AppTheme.headingColor
                                : cs.onSurface.withOpacity(0.5),
                            fontWeight: _selectedIncident != null
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_circle,
                            color: AppTheme.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── BOTTOM SHEET TIMELINE ──────────────────────────────────────
          if (_selectedIncident != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * 0.35,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest.withOpacity(0.95),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // Drag Handle
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: cs.onSurface.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Live Activity',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.emergencyUrl.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ACTIVE DISPATCH',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppTheme.emergencyUrl,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Timeline
                        Expanded(
                          child: Builder(builder: (context) {
                            final status =
                                _selectedIncident!['status'] ?? 'ACTIVE';
                            final isResolved = status == 'RESOLVED';
                            final steps = [
                              {
                                'title': 'Emergency Dispatched',
                                'desc':
                                    'Emergency forces have been dispatched.',
                                'active': true
                              },
                              {
                                'title': 'Responder Assigned',
                                'desc': 'A responder is currently en route.',
                                'active': true
                              },
                              {
                                'title': 'Incident Resolved',
                                'desc': 'The incident has been cleared.',
                                'active': isResolved
                              },
                            ];

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 8),
                              itemCount: steps.length,
                              itemBuilder: (context, index) {
                                final step = steps[index];
                                final isActive = step['active'] as bool;
                                final isLast = index == 1 &&
                                    !isResolved; // Highlight current status

                                return _TimelineItem(
                                  time: '',
                                  isLast: isLast,
                                  isActive: isActive,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isLast
                                          ? AppTheme.emergencyUrl
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                            color: isLast
                                                ? AppTheme.emergencyUrl
                                                    .withOpacity(0.3)
                                                : Colors.black
                                                    .withOpacity(0.02),
                                            blurRadius: isLast ? 16 : 8,
                                            offset: isLast
                                                ? const Offset(0, 8)
                                                : Offset.zero),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step['title'] as String,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: isLast
                                                ? Colors.white
                                                : (isActive
                                                    ? cs.onSurface
                                                    : cs.onSurface
                                                        .withOpacity(0.3)),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          step['desc'] as String,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: isLast
                                                ? Colors.white.withOpacity(0.9)
                                                : (isActive
                                                    ? cs.onSurface
                                                        .withOpacity(0.6)
                                                    : cs.onSurface
                                                        .withOpacity(0.2)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
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

class _TimelineItem extends StatelessWidget {
  final String time;
  final Widget child;
  final bool isLast;
  final bool isActive;

  const _TimelineItem({
    required this.time,
    required this.child,
    this.isLast = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.emergencyUrl.withOpacity(0.2)
                        : cs.onSurface.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.emergencyUrl
                            : cs.onSurface.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.onSurface.withOpacity(0.05),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isActive
                          ? AppTheme.emergencyUrl
                          : cs.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
