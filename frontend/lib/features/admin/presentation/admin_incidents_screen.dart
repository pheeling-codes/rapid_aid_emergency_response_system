import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class AdminIncidentsScreen extends StatefulWidget {
  const AdminIncidentsScreen({super.key});

  @override
  State<AdminIncidentsScreen> createState() => _AdminIncidentsScreenState();
}

class _AdminIncidentsScreenState extends State<AdminIncidentsScreen> {
  Map<String, dynamic>? _selectedIncident;

  final List<Map<String, dynamic>> _incidents = [
    {
      'id': '#RA-2026-9911',
      'category': 'Medical',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFFDC2626),
      'timestamp': '24 Oct,\n14:32:10',
      'duration': '12m 45s',
      'unit': 'Alpha-09\n(Paramedic)',
      'status': 'RESOLVED',
      'statusColor': const Color(0xFF10B981),
      'statusBg': const Color(0xFFD1FAE5),
      'reporter': 'Jonathan Vance',
      'location': '42 Market St, Central Plaza',
      'notes': '"Caller reported smelling smoke from the basement storage room. Multiple alarms triggered. evacuated building immediately."'
    },
    {
      'id': '#RA-2026-9912',
      'category': 'Fire',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFF59E0B),
      'timestamp': '24 Oct,\n13:15:44',
      'duration': '04m 20s',
      'unit': 'Engine-04',
      'status': 'CANCELLED',
      'statusColor': const Color(0xFF6B7280),
      'statusBg': const Color(0xFFF3F4F6),
      'reporter': 'Sarah Jenkins',
      'location': 'Downtown Core (Zone A)',
      'notes': 'False alarm.'
    },
    {
      'id': '#RA-2026-9913',
      'category': 'Security',
      'icon': Icons.security_rounded,
      'color': const Color(0xFF3B82F6),
      'timestamp': '24 Oct,\n12:40:02',
      'duration': '28m 10s',
      'unit': 'Patrol-02',
      'status': 'RESOLVED',
      'statusColor': const Color(0xFF10B981),
      'statusBg': const Color(0xFFD1FAE5),
      'reporter': 'David Chen',
      'location': 'North Highlands (Zone D)',
      'notes': 'Suspect apprehended without incident.'
    },
    {
      'id': '#RA-2026-9914',
      'category': 'Accident',
      'icon': Icons.car_crash_rounded,
      'color': const Color(0xFFEF4444),
      'timestamp': '24 Oct,\n11:22:19',
      'duration': '18m 55s',
      'unit': 'Rescue-01',
      'status': 'RESOLVED',
      'statusColor': const Color(0xFF10B981),
      'statusBg': const Color(0xFFD1FAE5),
      'reporter': 'Elena Rodriguez',
      'location': 'Highway 9, Mile Marker 42',
      'notes': 'Two vehicle collision. Minor injuries reported. Tow truck dispatched.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Row(
        children: [
          // ── Main Content Area ─────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Row(
                    children: [
                      Text(
                        'Rapid Aid: Incidents History',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      // Search Bar
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Quick search ticket...',
                            hintStyle: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(Icons.search,
                                size: 18, color: cs.onSurface.withOpacity(0.5)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(top: -4),
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
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.surfaceContainerLow,
                          child: Icon(Icons.person,
                              color: cs.onSurface.withOpacity(0.7), size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Scroll View
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    child: Column(
                      children: [
                        // KPIs
                        Row(
                          children: [
                            Expanded(child: _IncidentKpiCard(title: 'TOTAL RESOLVED', value: '1,240', change: '~12%', isPositive: true)),
                            const SizedBox(width: 24),
                            Expanded(child: _IncidentKpiCard(title: 'AVG RESPONSE TIME', value: '6m 12s', change: '~0.4s', isPositive: false)),
                            const SizedBox(width: 24),
                            Expanded(child: _IncidentKpiCard(title: 'SUCCESS RATE', value: '98%', change: 'stable', isPositive: true)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Filters
                        Row(
                          children: [
                            // Date Picker
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: cs.onSurface.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: cs.onSurface.withOpacity(0.6)),
                                  const SizedBox(width: 8),
                                  Text('Oct 24 - Oct 31, 2026', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.headingColor)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Category Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: cs.onSurface.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Text('All Categories', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.headingColor)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: cs.onSurface.withOpacity(0.6)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Search Box
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: cs.onSurface.withOpacity(0.1)),
                                ),
                                child: Text('Search respon...', style: TextStyle(color: cs.onSurface.withOpacity(0.4))),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Export Button
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.file_download_outlined, color: Color(0xFF004F9F)),
                              label: const Text('Export to CSV', style: TextStyle(color: Color(0xFF004F9F), fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                side: const BorderSide(color: Color(0xFF004F9F)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                backgroundColor: const Color(0xFFEFF6FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Data Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: _TableHeader('CATEGORY')),
                              Expanded(flex: 2, child: _TableHeader('TIMESTAMP')),
                              Expanded(flex: 2, child: _TableHeader('DURATION')),
                              Expanded(flex: 2, child: _TableHeader('ASSIGNED UNIT')),
                              Expanded(flex: 2, child: _TableHeader('STATUS')),
                            ],
                          ),
                        ),
                        
                        // Data Table Rows
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: _incidents.map((incident) {
                              final isSelected = _selectedIncident == incident;
                              return Column(
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedIncident = incident;
                                        });
                                      },
                                      child: Container(
                                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: incident['color'].withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(incident['icon'], color: incident['color'], size: 20),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(incident['category'], style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.headingColor)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(incident['timestamp'], style: const TextStyle(color: Color(0xFF4B5563), height: 1.3)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(incident['duration'], style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(incident['unit'], style: const TextStyle(color: Color(0xFF4B5563), height: 1.3)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(color: incident['statusBg'], borderRadius: BorderRadius.circular(12)),
                                                    child: Text(
                                                      incident['status'],
                                                      style: TextStyle(color: incident['statusColor'], fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                                                    ),
                                                  ),
                                                  if (isSelected) ...[
                                                    const Spacer(),
                                                    Icon(Icons.chevron_right_rounded, color: cs.primary),
                                                  ]
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (incident != _incidents.last) const Divider(height: 1, indent: 24, endIndent: 24),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Right Side Panel (Incident Case File) ────────────────────────
          if (_selectedIncident != null)
            Container(
              width: 380,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(-4, 0)),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Incident Case File',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.headingColor,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIncident = null;
                              });
                            },
                            child: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ACTIVE FILE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.5),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: _selectedIncident!['statusBg'], borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  _selectedIncident!['status'],
                                  style: TextStyle(color: _selectedIncident!['statusColor'], fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedIncident!['id'],
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.headingColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Reporter Details
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Color(0xFF3B82F6), size: 18),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Reporter', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                                        Text(_selectedIncident!['reporter'], style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Color(0xFF3B82F6), size: 18),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Location', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                                        Text(_selectedIncident!['location'], style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Evidence Photo
                          Text(
                            'EVIDENCE / SITE PHOTO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFF001A33),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(Icons.image, size: 48, color: Colors.white.withOpacity(0.2)),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Reporter Notes
                          Text(
                            'REPORTER NOTES',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(left: BorderSide(color: Color(0xFF3B82F6), width: 4)),
                            ),
                            child: Text(
                              _selectedIncident!['notes'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF4B5563),
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Dispatch Log
                          Text(
                            'DISPATCHER-UNIT LOG',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DISPATCH', style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6), fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedIncident!['unit']}, do you have eyes on the situation?',
                                  style: const TextStyle(color: Color(0xFF1F2937)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5E7EB),
                          foregroundColor: const Color(0xFF1F2937),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Print Full Audit Log', style: TextStyle(fontWeight: FontWeight.w800)),
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

class _IncidentKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;

  const _IncidentKpiCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.headingColor,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
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
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w800,
        fontSize: 10,
        letterSpacing: 1.0,
      ),
    );
  }
}
