import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/network/network_client.dart';
import '../../../main.dart';
import '../../../core/widgets/user_profile_avatar.dart';

class AdminIncidentsScreen extends StatefulWidget {
  const AdminIncidentsScreen({super.key});

  @override
  State<AdminIncidentsScreen> createState() => _AdminIncidentsScreenState();
}

class _AdminIncidentsScreenState extends State<AdminIncidentsScreen> {
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Statuses';
  String _selectedTime = 'All Time';
  Map<String, dynamic>? _selectedIncident; // For the right panel

  bool _isLoading = true;
  List<Map<String, dynamic>> _incidents = [];

  int _totalResolved = 0;
  int _inProgressCount = 0;
  int _cancelledCount = 0;
  int _unassignedCount = 0;
  String _avgResponseTime = '0m';
  String _successRate = '0%';

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    try {
      final res = await getIt<NetworkClient>().dio.get('/incidents/');
      if (mounted) {
        final List<dynamic> results = res.data is List ? res.data : (res.data['results'] ?? []);
        
        int resolvedCount = 0;
        int inProgressCount = 0;
        int cancelledCount = 0;
        int unassignedCount = 0;
        int totalResponseSecs = 0;
        int validResponseCount = 0;

        final mapped = results.map((inc) {
          final isResolved = inc['status'] == 'RESOLVED';
          if (isResolved) resolvedCount++;
          if (inc['status'] == 'EN_ROUTE' || inc['status'] == 'ON_SCENE') inProgressCount++;
          if (inc['status'] == 'CANCELLED') cancelledCount++;
          if (inc['status'] == 'PENDING' || inc['status'] == 'UNASSIGNED') unassignedCount++;

          String responseTime = 'Pending';
          if (inc['created_at'] != null && inc['resolved_at'] != null) {
            final created = DateTime.parse(inc['created_at']);
            final resolved = DateTime.parse(inc['resolved_at']);
            final diff = resolved.difference(created);
            responseTime = '${diff.inMinutes} min';
            totalResponseSecs += diff.inSeconds;
            validResponseCount++;
          } else if (inc['status'] == 'EN_ROUTE' || inc['status'] == 'ON_SCENE') {
             responseTime = 'In Progress';
          }

          String type = inc['category']?.toString().toUpperCase() ?? 'OTHER';
          if (type == 'CRIME') type = 'SECURITY';
          return {
            'id': '#${inc['ref_id'] ?? inc['id'].toString()}',
            'type': type,
            'title': inc['title'] ?? 'Incident',
            'location': inc['address'] ?? 'Unknown Location',
            'status': inc['status'] == 'PENDING' ? 'UNASSIGNED' : (inc['status'] ?? 'UNASSIGNED'),
            'time': _formatTime(inc['created_at']),
            'rawDate': inc['created_at'],
            'unit': inc['responder_name'] ?? 'Unassigned',
            'response': responseTime,
            'details': inc['description'] ?? 'No details provided.',
          };
        }).toList();

        setState(() {
          _incidents = mapped;
          _totalResolved = resolvedCount;
          _inProgressCount = inProgressCount;
          _cancelledCount = cancelledCount;
          _unassignedCount = unassignedCount;
          
          if (validResponseCount > 0) {
            final avgSecs = totalResponseSecs / validResponseCount;
            _avgResponseTime = '${(avgSecs / 60).toStringAsFixed(1)}m';
          }
          
          if (_incidents.isNotEmpty) {
            _successRate = '${((resolvedCount / _incidents.length) * 100).toStringAsFixed(1)}%';
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final day = dt.day;
      final month = monthNames[dt.month - 1];
      final year = dt.year;
      int hour = dt.hour;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$day $month $year, $hour:$min $period';
    } catch (e) {
      return 'Unknown';
    }
  }

  Color _getCategoryColor(String type) {
    if (type == 'MEDICAL') return const Color(0xFFDC2626);
    if (type == 'FIRE') return const Color(0xFFF59E0B);
    if (type == 'POLICE' || type == 'SECURITY') return const Color(0xFF8B5CF6);
    if (type == 'ACCIDENT') return const Color(0xFF3B82F6);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final filteredIncidents = _incidents.where((inc) {
      if (_selectedCategory != 'All Categories' && inc['type'] != _selectedCategory.toUpperCase()) {
        return false;
      }
      if (_selectedStatus != 'All Statuses') {
        final backendStatus = _selectedStatus.toUpperCase().replaceAll(' ', '_');
        if (inc['status'] != backendStatus) return false;
      }
      if (_selectedTime != 'All Time' && inc['rawDate'] != null) {
        try {
          final dt = DateTime.parse(inc['rawDate']).toLocal();
          final now = DateTime.now();
          if (_selectedTime == 'Last 24 Hours' && now.difference(dt).inHours > 24) return false;
          if (_selectedTime == 'Last 7 Days' && now.difference(dt).inDays > 7) return false;
          if (_selectedTime == 'Last 30 Days' && now.difference(dt).inDays > 30) return false;
        } catch (_) {}
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Row(
        children: [
          // ── Main Content Area ───────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: cs.onSurface.withOpacity(0.05))),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Incidents History',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
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
                              hintText: 'Search tickets, units, locations...',
                              hintStyle: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.5)),
                              prefixIcon: Icon(Icons.search, size: 18, color: cs.onSurface.withOpacity(0.5)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Profile Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.onSurface.withOpacity(0.1), width: 2),
                        ),
                        child: const UserProfileAvatar(radius: 16),
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Analytics Header
                        Row(
                          children: [
                            Expanded(child: _AnalyticCard(title: 'TOTAL INCIDENT', value: '${_incidents.length}', trend: '-', isPositive: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _AnalyticCard(title: 'UNASSIGNED', value: '$_unassignedCount', trend: '-', isPositive: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _AnalyticCard(title: 'IN PROGRESS', value: '$_inProgressCount', trend: '-', isPositive: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _AnalyticCard(title: 'RESOLVED', value: '$_totalResolved', trend: '-', isPositive: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _AnalyticCard(title: 'CANCELLED', value: '$_cancelledCount', trend: '-', isPositive: false)),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Filters & Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Category Filter
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: cs.onSurface.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.headingColor, size: 18),
                                      isDense: true,
                                      style: TextStyle(color: AppTheme.headingColor, fontWeight: FontWeight.w700),
                                      items: ['All Categories', 'Fire', 'Medical', 'Accident', 'Security'].map((String value) {
                                        return DropdownMenuItem<String>(value: value, child: Text(value));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedCategory = val);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Status Filter
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: cs.onSurface.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedStatus,
                                      icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.headingColor, size: 18),
                                      isDense: true,
                                      style: TextStyle(color: AppTheme.headingColor, fontWeight: FontWeight.w700),
                                      items: ['All Statuses', 'Unassigned', 'En Route', 'On Scene', 'Resolved', 'Cancelled'].map((String value) {
                                        return DropdownMenuItem<String>(value: value, child: Text(value));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() {
                                          _selectedStatus = val;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Timeline Filter
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: cs.onSurface.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedTime,
                                      icon: Icon(Icons.calendar_today, color: AppTheme.headingColor, size: 16),
                                      isDense: true,
                                      style: TextStyle(color: AppTheme.headingColor, fontWeight: FontWeight.w700),
                                      items: ['Last 24 Hours', 'Last 7 Days', 'Last 30 Days', 'All Time'].map((String value) {
                                        return DropdownMenuItem<String>(value: value, child: Text(value));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedTime = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Data Table
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  border: Border(bottom: BorderSide(color: cs.onSurface.withOpacity(0.05))),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: _TableHeader('INCIDENT ID')),
                                    Expanded(flex: 2, child: _TableHeader('CATEGORY')),
                                    Expanded(flex: 3, child: _TableHeader('LOCATION')),
                                    Expanded(flex: 2, child: _TableHeader('STATUS')),
                                    Expanded(flex: 2, child: _TableHeader('DISPATCHED UNIT')),
                                    Expanded(flex: 2, child: _TableHeader('TIME')),
                                  ],
                                ),
                              ),
                              // Rows
                              Container(
                                constraints: const BoxConstraints(maxHeight: 500),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ...filteredIncidents.map((inc) {
                                final isSelected = _selectedIncident == inc;
                                final isCritical = inc['type'] == 'MEDICAL' || inc['type'] == 'FIRE';
                                
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedIncident = inc;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                        border: Border(bottom: BorderSide(color: cs.onSurface.withOpacity(0.05))),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(inc['id'], style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              inc['type'],
                                              style: TextStyle(
                                                color: _getCategoryColor(inc['type']),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              children: [
                                                const Icon(Icons.location_on, size: 14, color: Color(0xFF6B7280)),
                                                const SizedBox(width: 4),
                                                Expanded(child: Text(inc['location'], style: const TextStyle(color: Color(0xFF4B5563)), overflow: TextOverflow.ellipsis)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: inc['status'] == 'RESOLVED' ? const Color(0xFFD1FAE5) : inc['status'] == 'UNASSIGNED' ? const Color(0xFFF3F4F6) : inc['status'] == 'EN_ROUTE' || inc['status'] == 'ON_SCENE' ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  inc['status'],
                                                  style: TextStyle(
                                                    color: inc['status'] == 'RESOLVED' ? const Color(0xFF10B981) : inc['status'] == 'UNASSIGNED' ? const Color(0xFF6B7280) : inc['status'] == 'EN_ROUTE' || inc['status'] == 'ON_SCENE' ? const Color(0xFF3B82F6) : const Color(0xFFDC2626),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 10,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(inc['unit'], style: const TextStyle(color: Color(0xFF4B5563))),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(inc['time'], style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Right Slide-out Panel (Incident Case File) ────────────────────
          if (_selectedIncident != null)
            Container(
              width: 380,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(-4, 0))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Panel Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.onSurface.withOpacity(0.05)))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('INCIDENT CASE FILE', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIncident = null),
                            child: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedIncident!['id'], style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.headingColor)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _selectedIncident!['status'] == 'RESOLVED' ? const Color(0xFFD1FAE5) : _selectedIncident!['status'] == 'UNASSIGNED' ? const Color(0xFFF3F4F6) : _selectedIncident!['status'] == 'EN_ROUTE' || _selectedIncident!['status'] == 'ON_SCENE' ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedIncident!['status'],
                                  style: TextStyle(color: _selectedIncident!['status'] == 'RESOLVED' ? const Color(0xFF10B981) : _selectedIncident!['status'] == 'UNASSIGNED' ? const Color(0xFF6B7280) : _selectedIncident!['status'] == 'EN_ROUTE' || _selectedIncident!['status'] == 'ON_SCENE' ? const Color(0xFF3B82F6) : const Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_selectedIncident!['title'], style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563))),
                          const SizedBox(height: 32),
                          
                          // Details Grid
                          Row(
                            children: [
                              Expanded(child: _DetailItem('TIME REPORTED', _selectedIncident!['time'])),
                              Expanded(child: _DetailItem('RESPONSE TIME', _selectedIncident!['response'])),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: _DetailItem('DISPATCHED UNIT', _selectedIncident!['unit'])),
                              Expanded(child: _DetailItem('LOCATION', _selectedIncident!['location'])),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 32),
                          
                          // Notes & Evidence
                          Text('DISPATCH LOGS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.0, color: const Color(0xFF6B7280))),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              _selectedIncident!['details'],
                              style: const TextStyle(color: Color(0xFF4B5563), height: 1.5),
                            ),
                          ),
                        ],
                      ),
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

// ── Components ───────────────────────────────────────────────────────────────

class _AnalyticCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const _AnalyticCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFDC2626);
    final bg = isPositive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280), fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.headingColor)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(trend, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.0));
  }
}

class _DetailItem extends StatelessWidget {

  final String label;
  final String value;

  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
      ],
    );
  }
}
