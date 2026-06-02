import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/user_profile_avatar.dart';
import '../../../main.dart';
import '../../../core/network/network_client.dart';
import '../../../features/auth/data/token_storage.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIncidentIndex = 0;
  int _selectedUnitIndex = 0;
  String _userEmail = '';
  String _userName = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    final ts = getIt<TokenStorage>();
    _userEmail = ts.getUserEmail() ?? 'Admin';
    _userName = ts.getUserName() ?? _userEmail.split('@').first;
    _userRole = ts.getUserRole() ?? 'DISPATCHER';
    
    _fetchStats();
    _fetchIncidents();
  }

  bool _isLoadingStats = true;
  int _totalUnits = 0;
  int _activeUnits = 0;

  bool _isLoadingIncidents = true;
  List<Map<String, dynamic>> _incidents = [];
  
  bool _isLoadingUnits = false;
  List<Map<String, dynamic>> _units = [];

  Future<void> _fetchStats() async {
    try {
      final res = await getIt<NetworkClient>().dio.get('/dispatcher/dashboard/stats/');
      if (mounted) {
        setState(() {
          _totalUnits = res.data['total_units'] ?? 0;
          _activeUnits = res.data['active_units'] ?? 0;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _fetchIncidents() async {
    try {
      final res = await getIt<NetworkClient>().dio.get('/incidents/');
      if (mounted) {
        final List<dynamic> results = res.data is List ? res.data : (res.data['results'] ?? []);
        setState(() {
          _incidents = results.map((inc) {
            String cat = inc['category'] ?? 'OTHER';
            Color tColor = const Color(0xFF3B82F6);
            IconData iData = Icons.warning;
            if (cat == 'MEDICAL') {
              tColor = const Color(0xFFDC2626);
              iData = Icons.monitor_heart;
            } else if (cat == 'FIRE') {
              tColor = const Color(0xFFF59E0B);
              iData = Icons.local_fire_department;
            } else if (cat == 'POLICE' || cat == 'SECURITY') {
              tColor = const Color(0xFF8B5CF6);
              iData = Icons.security;
            } else if (cat == 'ACCIDENT') {
              tColor = const Color(0xFF3B82F6);
              iData = Icons.car_crash;
            }

            return {
              'id': inc['id'],
              'type': cat,
              'typeColor': tColor,
              'title': inc['title'] ?? 'Unknown',
              'address': (inc['address'] ?? '').split(',').first,
              'fullAddress': inc['address'] ?? 'No Address',
              'time': _formatTimeAgo(inc['created_at']),
              'reporter': inc['reporter_name'] ?? 'Unknown',
              'notes': inc['description'] ?? '',
              'icon': iData,
              'priority': inc['severity'] ?? 'NORMAL',
            };
          }).toList();
          _isLoadingIncidents = false;
          if (_incidents.isNotEmpty) {
            _fetchClosestResponders(_incidents[_selectedIncidentIndex]['id']);
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingIncidents = false);
    }
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }

  Future<void> _fetchClosestResponders(String incidentId) async {
    setState(() => _isLoadingUnits = true);
    try {
      final res = await getIt<NetworkClient>().dio.get('/dispatcher/incidents/$incidentId/closest_responders/');
      if (mounted) {
        final List<dynamic> results = res.data['results'] ?? [];
        setState(() {
          _units = results.map((r) {
            return {
              'id': r['id'],
              'name': r['name'] ?? 'Unknown Responder',
              'distance': '${r['distance_km']} km',
              'eta': 'ETA: ${r['eta_mins']} mins',
              'profile_image': r['profile_image'],
            };
          }).toList();
          _selectedUnitIndex = 0;
          _isLoadingUnits = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingUnits = false);
    }
  }

  Future<void> _dispatchUnit() async {
    if (_units.isEmpty || _incidents.isEmpty) return;
    final selectedUnit = _units[_selectedUnitIndex];
    final selectedIncident = _incidents[_selectedIncidentIndex];

    try {
      await getIt<NetworkClient>().dio.post(
        '/dispatcher/incidents/${selectedIncident['id']}/dispatch/', 
        data: {'responder_id': selectedUnit['id']}
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedUnit['name']} dispatched successfully!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _fetchIncidents();
        _fetchStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to dispatch unit: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  // Removed static lists

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final selectedIncident = _incidents.isNotEmpty && _selectedIncidentIndex < _incidents.length ? _incidents[_selectedIncidentIndex] : null;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Column(
        children: [
          // ── Top App Bar ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: cs.onSurface.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Rapid Aid: Command Center',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 48),
                // Search Bar
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search incidents, units...',
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(Icons.search,
                            size: 18, color: cs.onSurface.withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
                // System Status
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981), // Green
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SYSTEM OPERATIONAL: NORMAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Profile Avatar & Info
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
                        border: Border.all(color: cs.onSurface.withOpacity(0.1), width: 2),
                      ),
                      child: const UserProfileAvatar(radius: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Map & Overlays ────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Simulated Map Background
                Container(
                  color: const Color(0xFFE5E7EB), // Light gray map bg
                  child: CustomPaint(
                    painter: _AdminMapPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),

                // ── Left Overlay: Active Incidents ──────────────────────────
                Positioned(
                  top: 24,
                  left: 24,
                  bottom: 24,
                  width: 320,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE INCIDENTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _isLoadingIncidents 
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : _incidents.isEmpty
                            ? const Center(child: Text('No active incidents', style: TextStyle(color: Colors.white54)))
                            : ListView.builder(
                          itemCount: _incidents.length,
                          itemBuilder: (context, index) {
                            final inc = _incidents[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _IncidentCard(
                                type: inc['type'],
                                typeColor: inc['typeColor'],
                                title: inc['title'],
                                address: inc['address'],
                                time: inc['time'],
                                isSelected: _selectedIncidentIndex == index,
                                onTap: () {
                                  setState(() {
                                    _selectedIncidentIndex = index;
                                  });
                                  _fetchClosestResponders(inc['id']);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right Overlay: Nearest Responders ────────────────────────
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: 380,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(-4, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected Incident Details
                        if (selectedIncident != null)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: selectedIncident['typeColor'].withOpacity(0.05),
                            border: Border(bottom: BorderSide(color: cs.onSurface.withOpacity(0.05))),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: selectedIncident['typeColor'],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(selectedIncident['icon'], color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedIncident['priority'],
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: selectedIncident['typeColor'],
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Text(
                                        selectedIncident['title'],
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.headingColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedIncident['fullAddress'],
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF4B5563),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Reported by ${selectedIncident['reporter']}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF4B5563),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  selectedIncident['notes'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Nearest Responders List
                        Expanded(
                          child: _isLoadingUnits
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: _units.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    'NEAREST RESPONDERS',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: cs.onSurface.withOpacity(0.5),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                );
                              }
                              final unitIndex = index - 1;
                              final unit = _units[unitIndex];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _UnitCard(
                                  name: unit['name'],
                                  distance: unit['distance'],
                                  eta: unit['eta'],
                                  isSelected: _selectedUnitIndex == unitIndex,
                                  onTap: () {
                                    setState(() {
                                      _selectedUnitIndex = unitIndex;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        // Dispatch Button
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton(
                              onPressed: _units.isEmpty ? null : _dispatchUnit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626), // Red
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                    Text(
                                      _units.isEmpty 
                                          ? 'NO UNITS AVAILABLE' 
                                          : 'DISPATCH ${_units[_selectedUnitIndex]['name'].split(' ').take(2).join(' ')}',
                                      style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                      fontSize: 14,
                                    ),
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

                // ── Bottom Metrics ───────────────────────────────────────────
                Positioned(
                  bottom: 24,
                  right: 400, // Left of the right panel
                  child: Row(
                    children: [
                      _MetricCard(title: 'ACTIVE UNITS', value: '$_activeUnits', subValue: ' / $_totalUnits'),
                      const SizedBox(width: 16),
                      _MetricCard(title: 'RESPONSE TIME', value: '4.2', subValue: ' min avg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _IncidentCard extends StatelessWidget {
  final String type;
  final Color typeColor;
  final String title;
  final String address;
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const _IncidentCard({
    required this.type,
    required this.typeColor,
    required this.title,
    required this.address,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: typeColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.headingColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: cs.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // View Details Indicator
              if (isSelected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    'CURRENTLY VIEWING',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: typeColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final String name;
  final String distance;
  final String eta;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitCard({
    required this.name,
    required this.distance,
    required this.eta,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : cs.onSurface.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.directions_car_filled_rounded, 
                    color: isSelected ? Colors.white : const Color(0xFF4B5563), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.headingColor,
                          ),
                        ),
                        Text(
                          distance,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$eta • Status: Available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subValue;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.headingColor,
                ),
              ),
              Text(
                subValue,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: title == 'ACTIVE UNITS' ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Light grey background
    final bgPaint = Paint()..color = const Color(0xFFE5E7EB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Thick roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final minorRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Draw grid of minor roads
    for (double x = 40; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorRoadPaint);
    }
    for (double y = 40; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorRoadPaint);
    }

    // Draw major arterial roads
    final mainPath1 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
          size.width * 0.4, size.height * 0.5, size.width, size.height * 0.3);
    canvas.drawPath(mainPath1, roadPaint);

    final mainPath2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(mainPath2, roadPaint);

    // Draw some blocks / buildings
    final blockPaint = Paint()..color = const Color(0xFFD1D5DB).withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.5, 40, 60), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.65, size.height * 0.5, 30, 40), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, size.height * 0.7, 80, 40), blockPaint);
    
    // Draw Incident Pin (Red asterisk equivalent)
    final redPinPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final cx = size.width * 0.6;
    final cy = size.height * 0.4;
    canvas.drawLine(Offset(cx - 10, cy - 10), Offset(cx + 10, cy + 10), redPinPaint);
    canvas.drawLine(Offset(cx + 10, cy - 10), Offset(cx - 10, cy + 10), redPinPaint);
    canvas.drawLine(Offset(cx, cy - 14), Offset(cx, cy + 14), redPinPaint);
    canvas.drawLine(Offset(cx - 14, cy), Offset(cx + 14, cy), redPinPaint);

    // Draw Unit Pins (Blue arrows)
    final bluePinPaint = Paint()..color = const Color(0xFF3B82F6);
    
    void drawUnit(double x, double y) {
      final path = Path()
        ..moveTo(x, y - 8)
        ..lineTo(x + 8, y + 12)
        ..lineTo(x, y + 6)
        ..lineTo(x - 8, y + 12)
        ..close();
      canvas.drawPath(path, bluePinPaint);
    }
    
    drawUnit(size.width * 0.45, size.height * 0.35);
    drawUnit(size.width * 0.35, size.height * 0.75);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
