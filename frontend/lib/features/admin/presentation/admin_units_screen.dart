import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class AdminUnitsScreen extends StatefulWidget {
  const AdminUnitsScreen({super.key});

  @override
  State<AdminUnitsScreen> createState() => _AdminUnitsScreenState();
}

class _AdminUnitsScreenState extends State<AdminUnitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                  'Rapid Aid: Units & User Management',
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
                        hintText: 'Search systems, units, or users...',
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
                const SizedBox(width: 24),
                // Profile Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: cs.onSurface.withOpacity(0.1), width: 2),
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

          // ── Tabs ──────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                dividerColor:
                    Colors.transparent, // Remove horizontal line beneath tabs
                indicatorColor: const Color(0xFFDC2626), // Red indicator
                indicatorWeight: 3,
                labelColor: const Color(0xFFDC2626),
                unselectedLabelColor: cs.onSurface.withOpacity(0.5),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                tabs: const [
                  Tab(text: 'Responder Management'),
                  Tab(text: 'User Directory'),
                ],
              ),
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ResponderManagementView(),
                _UserDirectoryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Responder Management Tab ──────────────────────────────────────────────────

class _ResponderManagementView extends StatefulWidget {
  @override
  State<_ResponderManagementView> createState() =>
      _ResponderManagementViewState();
}

class _ResponderManagementViewState extends State<_ResponderManagementView> {
  String _selectedFilter = 'All';
  int? _editingIndex;
  late TextEditingController _roleController;

  List<Map<String, dynamic>> _responders = [
    {
      'name': 'Lt. Sarah Jenkins',
      'role': 'Senior Paramedic',
      'unitId': 'MED-X-902',
      'status': 'ON DUTY',
      'location': '402 W 51st St (Moving)',
      'dateJoined': 'Oct 12, 2024',
    },
    {
      'name': 'Sgt. David Chen',
      'role': 'Tactical Response',
      'unitId': 'TAC-S-441',
      'status': 'OFF DUTY',
      'location': 'HQ Base 4',
      'dateJoined': 'Nov 05, 2024',
    },
    {
      'name': 'Cpt. Elena Rodriguez',
      'role': 'Field Commander',
      'unitId': 'CMD-V-001',
      'status': 'SUSPENDED',
      'location': 'Offline',
      'dateJoined': 'Dec 22, 2023',
    },
    {
      'name': 'Officer James Miller',
      'role': 'Support Unit',
      'unitId': 'SUP-M-112',
      'status': 'ON DUTY',
      'location': '128 8th Ave (Stationary)',
      'dateJoined': 'Jan 15, 2025',
    },
  ];

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController();
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  void _showConfirmModal(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppTheme.headingColor)),
        content:
            Text(content, style: const TextStyle(color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final filteredResponders = _responders.where((r) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Dormant')
        return r['status'] ==
            'SUSPENDED'; // Mapping dormant to suspended for now
      return r['status'] == _selectedFilter.toUpperCase();
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 32, vertical: 16), // Reduced top space
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top KPI Section (Horizontal Layout) ─────────────────────────────
          Row(
            children: [
              // Main Responder Status Card
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPERATIONAL OVERVIEW',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Responder Status',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.headingColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatusStat(
                              '42', 'TOTAL UNITS', AppTheme.headingColor),
                          const SizedBox(width: 32),
                          _StatusStat('28', 'ON DUTY', const Color(0xFF10B981)),
                          const SizedBox(width: 32),
                          _StatusStat(
                              '14', 'OFF DUTY', const Color(0xFF6B7280)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Side KPIs in a horizontal row
              Expanded(
                  flex: 2,
                  child: _SmallKpiCard(
                      icon: Icons.timer,
                      iconColor: const Color(0xFF3B82F6),
                      iconBg: const Color(0xFFEFF6FF),
                      label: 'AVG RESPONSE',
                      value: '4.2m',
                      isCompact: false)),
              const SizedBox(width: 16),
              Expanded(
                  flex: 2,
                  child: _SmallKpiCard(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF10B981),
                      iconBg: const Color(0xFFECFDF5),
                      label: 'SUCCESS RATE',
                      value: '94%',
                      isCompact: false)),
              const SizedBox(width: 16),
              Expanded(
                  flex: 2,
                  child: _SmallKpiCard(
                      icon: Icons.warning_amber_rounded,
                      iconColor: const Color(0xFFDC2626),
                      iconBg: const Color(0xFFFEF2F2),
                      label: 'URGENT ALERTS',
                      value: '2',
                      isCompact: false)),
            ],
          ),
          const SizedBox(height: 24),

          // ── Data Table ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Responders Directory',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.headingColor,
                      ),
                    ),
                    Row(
                      children: [
                        // Status Filter
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: cs.onSurface.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFilter,
                              icon: Icon(Icons.filter_list,
                                  color: AppTheme.headingColor, size: 18),
                              isDense: true,
                              style: TextStyle(
                                  color: AppTheme.headingColor,
                                  fontWeight: FontWeight.w700),
                              items: ['All', 'On Duty', 'Off Duty', 'Suspended']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedFilter = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Timeline Filter
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: cs.onSurface.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: 'All Time',
                              icon: Icon(Icons.calendar_today,
                                  color: AppTheme.headingColor, size: 16),
                              isDense: true,
                              style: TextStyle(
                                  color: AppTheme.headingColor,
                                  fontWeight: FontWeight.w700),
                              items: [
                                'All Time',
                                'Last 24 Hours',
                                'Last 7 Days',
                                'Last 30 Days'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                    value: value, child: Text(value));
                              }).toList(),
                              onChanged: (val) {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Table Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _TableHeader('IDENTITY')),
                      Expanded(flex: 2, child: _TableHeader('UNIT ID')),
                      Expanded(flex: 2, child: _TableHeader('LIVE STATUS')),
                      Expanded(flex: 3, child: _TableHeader('LIVE LOCATION')),
                      Expanded(flex: 2, child: _TableHeader('DATE JOINED')),
                      const SizedBox(
                          width: 100,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: _TableHeader('ACTIONS'))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Table Rows
                ...filteredResponders.asMap().entries.map((entry) {
                  final index = _responders.indexOf(entry.value);
                  final r = entry.value;
                  final isEditing = _editingIndex == index;
                  final statusStr = r['status'] as String;
                  Color statusColor = const Color(0xFF6B7280);
                  Color statusBg = const Color(0xFFF3F4F6);
                  if (statusStr == 'ON DUTY') {
                    statusColor = const Color(0xFF10B981);
                    statusBg = const Color(0xFFD1FAE5);
                  } else if (statusStr == 'SUSPENDED') {
                    statusColor = const Color(0xFFDC2626);
                    statusBg = const Color(0xFFFEE2E2);
                  }

                  return MouseRegion(
                    cursor: SystemMouseCursors.basic,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: cs.onSurface.withOpacity(0.05))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFE5E7EB),
                                  child: Icon(Icons.person,
                                      color: Color(0xFF9CA3AF), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(r['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1F2937))),
                                      if (isEditing)
                                        SizedBox(
                                          height: 24,
                                          child: TextField(
                                            controller: _roleController,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280)),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.only(bottom: 12),
                                              border: UnderlineInputBorder(),
                                            ),
                                          ),
                                        )
                                      else
                                        Text(r['role'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(r['unitId'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B5563))),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text(statusStr,
                                        style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                            letterSpacing: 0.5)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Color(0xFF3B82F6)),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(r['location'],
                                        style: const TextStyle(
                                            color: Color(0xFF4B5563)),
                                        overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(r['dateJoined'],
                                style: const TextStyle(
                                    color: Color(0xFF6B7280), fontSize: 12)),
                          ),
                          SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: isEditing
                                  ? [
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Color(0xFF10B981), size: 18),
                                        onPressed: () {
                                          setState(() {
                                            _responders[index]['role'] =
                                                _roleController.text;
                                            _editingIndex = null;
                                          });
                                          _showToast('Role updated');
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Color(0xFF6B7280), size: 18),
                                        onPressed: () {
                                          setState(() => _editingIndex = null);
                                        },
                                      ),
                                    ]
                                  : [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _editingIndex = index;
                                              _roleController.text = r['role'];
                                            });
                                          },
                                          child: const Icon(Icons.edit_outlined,
                                              color: Color(0xFF6B7280),
                                              size: 20),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            final isSuspended =
                                                r['status'] == 'SUSPENDED';
                                            final action = isSuspended
                                                ? 'unsuspend'
                                                : 'suspend';
                                            _showConfirmModal(
                                              '${isSuspended ? 'Unsuspend' : 'Suspend'} Responder',
                                              'Are you sure you want to $action ${r['name']}?',
                                              () {
                                                setState(() {
                                                  _responders[index]['status'] =
                                                      isSuspended
                                                          ? 'OFF DUTY'
                                                          : 'SUSPENDED';
                                                });
                                                _showToast(
                                                    'Responder ${isSuspended ? 'unsuspended' : 'suspended'}');
                                              },
                                            );
                                          },
                                          child: Icon(
                                              r['status'] == 'SUSPENDED'
                                                  ? Icons.unarchive_outlined
                                                  : Icons.archive_outlined,
                                              color: const Color(0xFFF59E0B),
                                              size: 20),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showConfirmModal(
                                              'Delete Responder',
                                              'Are you sure you want to delete ${r['name']}? This cannot be undone.',
                                              () {
                                                setState(() {
                                                  _responders.removeAt(index);
                                                });
                                                _showToast('Responder deleted');
                                              },
                                            );
                                          },
                                          child: const Icon(
                                              Icons.delete_outline,
                                              color: Color(0xFFDC2626),
                                              size: 20),
                                        ),
                                      ),
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── User Directory Tab ────────────────────────────────────────────────────────

class _UserDirectoryView extends StatefulWidget {
  @override
  State<_UserDirectoryView> createState() => _UserDirectoryViewState();
}

class _UserDirectoryViewState extends State<_UserDirectoryView> {
  String _selectedStatusFilter = 'All';
  String _selectedTimeFilter = 'All Time';

  List<Map<String, dynamic>> _citizens = [
    {
      'name': 'John Doe',
      'joined': 'Joined Oct 2025',
      'email': 'john.doe@example.com',
      'status': 'ACTIVE',
      'activity': '14 Reports',
    },
    {
      'name': 'Sarah Jenkins',
      'joined': 'Joined Nov 2025',
      'email': 'sarah.j@network.aid',
      'status': 'ACTIVE',
      'activity': '12 Reports',
    },
    {
      'name': 'Alex Thompson',
      'joined': 'Joined Dec 2025',
      'email': 'alex.t@provider.com',
      'status': 'INACTIVE',
      'activity': '2 Reports',
    },
    {
      'name': 'Mark Richards',
      'joined': 'Joined Jan 2026',
      'email': 'm.rich@temp-mail.org',
      'status': 'DORMANT',
      'activity': '0 Reports',
      'isAlert': true,
    },
  ];

  void _showConfirmModal(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppTheme.headingColor)),
        content:
            Text(content, style: const TextStyle(color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final filteredCitizens = _citizens.where((c) {
      if (_selectedStatusFilter != 'All' &&
          c['status'] != _selectedStatusFilter.toUpperCase()) return false;
      // Timeline filter is just mock UI for now
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 32, vertical: 16), // Reduced top space
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top KPI Section ───────────────────────────────────────────────
          Row(
            children: [
              // Main Citizen Status Card
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPERATIONAL OVERVIEW',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CITIZEN STATUS',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.headingColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatusStat(
                              '1,420', 'TOTAL USERS', AppTheme.headingColor),
                          const SizedBox(width: 32),
                          _StatusStat(
                              '1,280', 'ACTIVE USERS', AppTheme.headingColor),
                          const SizedBox(width: 32),
                          _StatusStat(
                              '130', 'INACTIVE USERS', const Color(0xFFDC2626)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Side KPIs in horizontal row
              Expanded(
                  flex: 2,
                  child: _SmallKpiCard(
                      icon: Icons.bar_chart,
                      iconColor: const Color(0xFF3B82F6),
                      iconBg: const Color(0xFFEFF6FF),
                      label: 'AVG REPORTS/USER',
                      value: '2.1',
                      isCompact: false)),
              const SizedBox(width: 16),
              Expanded(
                  flex: 2,
                  child: _SmallKpiCard(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF10B981),
                      iconBg: const Color(0xFFECFDF5),
                      label: 'ACTIVITY RATE',
                      value: '92%',
                      isCompact: false)),
              const SizedBox(width: 16),
              Expanded(
                  flex: 2,
                  child: _SmallKpiCard(
                      icon: Icons.flag,
                      iconColor: const Color(0xFFDC2626),
                      iconBg: const Color(0xFFFEF2F2),
                      label: 'DORMANT ACCOUNTS',
                      value: '5',
                      isCompact: false)),
            ],
          ),
          const SizedBox(height: 24),

          // ── Data Table ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Citizen Directory',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.headingColor,
                      ),
                    ),
                    Row(
                      children: [
                        // Status Filter
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: cs.onSurface.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatusFilter,
                              icon: Icon(Icons.filter_list,
                                  color: AppTheme.headingColor, size: 18),
                              isDense: true,
                              style: TextStyle(
                                  color: AppTheme.headingColor,
                                  fontWeight: FontWeight.w700),
                              items: [
                                'All',
                                'Active',
                                'Inactive',
                                'Dormant',
                                'Suspended'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                    value: value, child: Text(value));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedStatusFilter = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Timeline Filter
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: cs.onSurface.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTimeFilter,
                              icon: Icon(Icons.calendar_today,
                                  color: AppTheme.headingColor, size: 16),
                              isDense: true,
                              style: TextStyle(
                                  color: AppTheme.headingColor,
                                  fontWeight: FontWeight.w700),
                              items: [
                                'All Time',
                                'Last 24 Hours',
                                'Last 7 Days',
                                'Last 30 Days'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                    value: value, child: Text(value));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedTimeFilter = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Table Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _TableHeader('IDENTITY')),
                      Expanded(flex: 3, child: _TableHeader('USER ID/EMAIL')),
                      Expanded(flex: 2, child: _TableHeader('ACTIVITY STATUS')),
                      Expanded(flex: 2, child: _TableHeader('ACTIVITY')),
                      const SizedBox(
                          width: 80,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: _TableHeader('ACTIONS'))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Table Rows
                ...filteredCitizens.asMap().entries.map((entry) {
                  final index = _citizens.indexOf(entry.value);
                  final c = entry.value;
                  final isAlert = c['isAlert'] == true;
                  final statusStr = c['status'] as String;
                  Color statusColor = const Color(0xFF6B7280);
                  Color statusBg = const Color(0xFFF3F4F6);
                  if (statusStr == 'ACTIVE') {
                    statusColor = const Color(0xFF10B981);
                    statusBg = const Color(0xFFD1FAE5);
                  } else if (statusStr == 'DORMANT' ||
                      statusStr == 'SUSPENDED') {
                    statusColor = const Color(0xFFDC2626);
                    statusBg = const Color(0xFFFEE2E2);
                  }

                  return MouseRegion(
                    cursor: SystemMouseCursors.basic,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: cs.onSurface.withOpacity(0.05)))),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFE5E7EB),
                                  child: Icon(Icons.person,
                                      color: Color(0xFF9CA3AF), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1F2937))),
                                    Text(c['joined'],
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(c['email'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B5563))),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text(statusStr,
                                        style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                            letterSpacing: 0.5)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(c['activity'],
                                style: TextStyle(
                                    color: isAlert
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF4B5563),
                                    fontWeight: FontWeight.w700)),
                          ),
                          SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      final isSuspended =
                                          c['status'] == 'SUSPENDED';
                                      final action =
                                          isSuspended ? 'unsuspend' : 'suspend';
                                      _showConfirmModal(
                                        '${isSuspended ? 'Unsuspend' : 'Suspend'} User',
                                        'Are you sure you want to $action ${c['name']}?',
                                        () {
                                          setState(() {
                                            _citizens[index]['status'] =
                                                isSuspended
                                                    ? 'ACTIVE'
                                                    : 'SUSPENDED';
                                          });
                                          _showToast(
                                              'User ${isSuspended ? 'unsuspended' : 'suspended'}');
                                        },
                                      );
                                    },
                                    child: Icon(
                                        c['status'] == 'SUSPENDED'
                                            ? Icons.unarchive_outlined
                                            : Icons.archive_outlined,
                                        color: const Color(0xFFF59E0B),
                                        size: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      _showConfirmModal(
                                        'Delete User',
                                        'Are you sure you want to permanently delete ${c['name']}?',
                                        () {
                                          setState(() {
                                            _citizens.removeAt(index);
                                          });
                                          _showToast('User deleted');
                                        },
                                      );
                                    },
                                    child: const Icon(Icons.delete_outline,
                                        color: Color(0xFFDC2626), size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Components ───────────────────────────────────────────────────────────────

class _StatusStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatusStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _SmallKpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final bool isCompact;

  const _SmallKpiCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
        border: label == 'DORMANT ACCOUNTS'
            ? Border.all(color: const Color(0xFFFEE2E2), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 8 : 12),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: isCompact ? 18 : 24),
          ),
          SizedBox(width: isCompact ? 16 : 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: label == 'DORMANT ACCOUNTS'
                      ? const Color(0xFFDC2626)
                      : AppTheme.headingColor,
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
