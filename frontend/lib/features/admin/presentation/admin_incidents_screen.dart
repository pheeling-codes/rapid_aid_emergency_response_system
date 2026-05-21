import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class AdminIncidentsScreen extends StatefulWidget {
  const AdminIncidentsScreen({super.key});

  @override
  State<AdminIncidentsScreen> createState() => _AdminIncidentsScreenState();
}

class _AdminIncidentsScreenState extends State<AdminIncidentsScreen> {
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Statuses';
  String _selectedTime = 'Last 24 Hours';
  Map<String, dynamic>? _selectedIncident; // For the right panel

  final List<Map<String, dynamic>> _incidents = [
    {
      'id': 'INC-2026-0892',
      'type': 'MEDICAL',
      'title': 'Cardiac Arrest',
      'location': '402 W 51st St',
      'status': 'RESOLVED',
      'time': '12:42 PM',
      'unit': 'Unit 7A (ALS)',
      'response': '4.1 min',
      'details': 'Patient revived after 2 rounds of CPR and 1 shock from AED. Transported to Mt Sinai.',
    },
    {
      'id': 'INC-2026-0891',
      'type': 'FIRE',
      'title': 'Building Fire',
      'location': '128 8th Ave',
      'status': 'ACTIVE',
      'time': '12:30 PM',
      'unit': 'Unit 12B (BLS)',
      'response': 'Pending',
      'details': 'Patient struggling to breathe, history of severe asthma. Unit en route.',
    },
    {
      'id': 'INC-2026-0890',
      'type': 'ACCIDENT',
      'title': 'Vehicle Collision',
      'location': 'Broadway & 42nd St',
      'status': 'RESOLVED',
      'time': '11:15 AM',
      'unit': 'Rapid Response 4',
      'response': '5.2 min',
      'details': 'Minor lacerations and suspected concussion. Immobilized and transported to Bellevue.',
    },
    {
      'id': 'INC-2026-0889',
      'type': 'SECURITY',
      'title': 'Intrusion Alarm',
      'location': 'Metropolitan Hospital',
      'status': 'RESOLVED',
      'time': '09:00 AM',
      'unit': 'Unit 3C (Transport)',
      'response': 'N/A',
      'details': 'Scheduled transfer to rehabilitation facility.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final filteredIncidents = _incidents.where((inc) {
      if (_selectedCategory != 'All Categories' && inc['type'] != _selectedCategory.toUpperCase()) {
        return false;
      }
      if (_selectedStatus != 'All Statuses' && inc['status'] != _selectedStatus.toUpperCase()) {
        return false;
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
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.surfaceContainerLow,
                          child: Icon(Icons.person, color: cs.onSurface.withOpacity(0.7), size: 20),
                        ),
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
                            Expanded(child: _AnalyticCard(title: 'TOTAL RESOLVED (24H)', value: '142', trend: '+12%', isPositive: true)),
                            const SizedBox(width: 24),
                            Expanded(child: _AnalyticCard(title: 'AVG RESPONSE TIME', value: '4.2m', trend: '-0.4m', isPositive: true)),
                            const SizedBox(width: 24),
                            Expanded(child: _AnalyticCard(title: 'SUCCESS RATE', value: '98.5%', trend: '+1.2%', isPositive: true)),
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
                                      items: ['All Statuses', 'Active', 'Resolved', 'Cancelled'].map((String value) {
                                        return DropdownMenuItem<String>(value: value, child: Text(value));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedStatus = val);
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
                                    Expanded(flex: 3, child: _TableHeader('CATEGORY & TITLE')),
                                    Expanded(flex: 2, child: _TableHeader('LOCATION')),
                                    Expanded(flex: 2, child: _TableHeader('STATUS')),
                                    Expanded(flex: 2, child: _TableHeader('DISPATCHED UNIT')),
                                    Expanded(flex: 1, child: _TableHeader('TIME')),
                                  ],
                                ),
                              ),
                              // Rows
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
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  inc['type'],
                                                  style: TextStyle(
                                                    color: isCritical ? const Color(0xFFDC2626) : const Color(0xFF6B7280),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                Text(inc['title'], style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.headingColor)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
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
                                                  color: inc['status'] == 'RESOLVED' ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  inc['status'],
                                                  style: TextStyle(
                                                    color: inc['status'] == 'RESOLVED' ? const Color(0xFF10B981) : const Color(0xFFDC2626),
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
                                            flex: 1,
                                            child: Text(inc['time'], style: const TextStyle(color: Color(0xFF6B7280))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
                                  color: _selectedIncident!['status'] == 'RESOLVED' ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedIncident!['status'],
                                  style: TextStyle(color: _selectedIncident!['status'] == 'RESOLVED' ? const Color(0xFF10B981) : const Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
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
