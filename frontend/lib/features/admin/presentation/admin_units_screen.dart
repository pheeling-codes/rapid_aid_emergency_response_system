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
                Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search systems, units, or users...',
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

          // ── Tabs ──────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
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

class _ResponderManagementView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top KPI Section ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Responder Status Card
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.headingColor,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _StatusStat('42', 'TOTAL UNITS', AppTheme.headingColor),
                              const SizedBox(width: 48),
                              _StatusStat('28', 'ON DUTY', const Color(0xFF10B981)),
                              const SizedBox(width: 48),
                              _StatusStat('14', 'OFF DUTY', const Color(0xFF6B7280)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Onboard New Responder',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626), // Red
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Row of Small KPIs
          Row(
            children: [
              Expanded(child: _SmallKpiCard(icon: Icons.timer, iconColor: const Color(0xFF3B82F6), iconBg: const Color(0xFFEFF6FF), label: 'AVG RESPONSE', value: '4.2 min')),
              const SizedBox(width: 24),
              Expanded(child: _SmallKpiCard(icon: Icons.check_circle_outline, iconColor: const Color(0xFF10B981), iconBg: const Color(0xFFECFDF5), label: 'SUCCESS RATE', value: '94%')),
              const SizedBox(width: 24),
              Expanded(child: _SmallKpiCard(icon: Icons.warning_amber_rounded, iconColor: const Color(0xFFDC2626), iconBg: const Color(0xFFFEF2F2), label: 'URGENT ALERTS', value: '2 Active')),
            ],
          ),
          const SizedBox(height: 40),

          // ── Data Table ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Export CSV', style: TextStyle(color: AppTheme.headingColor, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.filter_list, color: AppTheme.headingColor, size: 18),
                          label: Text('Filter', style: TextStyle(color: AppTheme.headingColor, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Table Header
                Row(
                  children: [
                    Expanded(flex: 3, child: _TableHeader('IDENTITY')),
                    Expanded(flex: 2, child: _TableHeader('UNIT ID')),
                    Expanded(flex: 2, child: _TableHeader('LIVE STATUS')),
                    Expanded(flex: 3, child: _TableHeader('ZONE')),
                    const SizedBox(width: 48, child: _TableHeader('ACTIONS')),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                // Table Rows
                _ResponderRow(
                  name: 'Lt. Sarah Jenkins', role: 'Senior Paramedic',
                  unitId: 'MED-X-902',
                  status: 'ON DUTY', statusColor: const Color(0xFF10B981), statusBg: const Color(0xFFD1FAE5),
                  zone: 'Downtown Core (Zone A)',
                ),
                const Divider(),
                _ResponderRow(
                  name: 'Sgt. David Chen', role: 'Tactical Response',
                  unitId: 'TAC-S-441',
                  status: 'OFF DUTY', statusColor: const Color(0xFF6B7280), statusBg: const Color(0xFFF3F4F6),
                  zone: 'North Highlands (Zone D)',
                ),
                const Divider(),
                _ResponderRow(
                  name: 'Cpt. Elena Rodriguez', role: 'Field Commander',
                  unitId: 'CMD-V-001',
                  status: 'SUSPENDED', statusColor: const Color(0xFFDC2626), statusBg: const Color(0xFFFEE2E2),
                  zone: 'Pending Assignment',
                ),
                const Divider(),
                _ResponderRow(
                  name: 'Officer James Miller', role: 'Support Unit',
                  unitId: 'SUP-M-112',
                  status: 'ON DUTY', statusColor: const Color(0xFF10B981), statusBg: const Color(0xFFD1FAE5),
                  zone: 'Waterfront District (Zone C)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── User Directory Tab ────────────────────────────────────────────────────────

class _UserDirectoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top KPI Section ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Citizen Status Card
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.headingColor,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _StatusStat('1,420', 'TOTAL USERS', AppTheme.headingColor),
                              const SizedBox(width: 48),
                              _StatusStat('1,280', 'ACTIVE USERS', AppTheme.headingColor),
                              const SizedBox(width: 48),
                              _StatusStat('130', 'INACTIVE USERS', const Color(0xFFDC2626)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Add New User',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626), // Red
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Side KPIs
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _SmallKpiCard(icon: Icons.bar_chart, iconColor: const Color(0xFF3B82F6), iconBg: const Color(0xFFEFF6FF), label: 'AVG REPORTS/USER', value: '2.1', isCompact: true),
                    const SizedBox(height: 12),
                    _SmallKpiCard(icon: Icons.check_circle_outline, iconColor: const Color(0xFF10B981), iconBg: const Color(0xFFECFDF5), label: 'ACTIVITY RATE', value: '92%', isCompact: true),
                    const SizedBox(height: 12),
                    _SmallKpiCard(icon: Icons.flag, iconColor: const Color(0xFFDC2626), iconBg: const Color(0xFFFEF2F2), label: 'DORMANT ACCOUNTS', value: '5 Dormant', isCompact: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // ── Data Table ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.filter_list, color: AppTheme.headingColor, size: 18),
                          label: Text('Filter', style: TextStyle(color: AppTheme.headingColor, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Export CSV', style: TextStyle(color: AppTheme.headingColor, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Table Header
                Row(
                  children: [
                    Expanded(flex: 3, child: _TableHeader('IDENTITY')),
                    Expanded(flex: 3, child: _TableHeader('USER ID/EMAIL')),
                    Expanded(flex: 2, child: _TableHeader('ACTIVITY STATUS')),
                    Expanded(flex: 2, child: _TableHeader('ACTIVITY')),
                    const SizedBox(width: 48, child: _TableHeader('ACTIONS')),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                // Table Rows
                _UserRow(
                  name: 'John Doe', joined: 'Joined Oct 2025',
                  email: 'john.doe@example.com',
                  status: 'ACTIVE', statusColor: const Color(0xFF10B981), statusBg: const Color(0xFFD1FAE5),
                  activity: '14 Reports',
                ),
                const Divider(),
                _UserRow(
                  name: 'Sarah Jenkins', joined: 'Joined Nov 2025',
                  email: 'sarah.j@network.aid',
                  status: 'ACTIVE', statusColor: const Color(0xFF10B981), statusBg: const Color(0xFFD1FAE5),
                  activity: '12 Reports',
                ),
                const Divider(),
                _UserRow(
                  name: 'Alex Thompson', joined: 'Joined Dec 2025',
                  email: 'alex.t@provider.com',
                  status: 'INACTIVE', statusColor: const Color(0xFF6B7280), statusBg: const Color(0xFFF3F4F6),
                  activity: '2 Reports',
                ),
                const Divider(),
                _UserRow(
                  name: 'Mark Richards', joined: 'Joined Jan 2026',
                  email: 'm.rich@temp-mail.org',
                  status: 'DORMANT', statusColor: const Color(0xFFDC2626), statusBg: const Color(0xFFFEE2E2),
                  activity: '0 Reports',
                  isAlert: true,
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
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: label == 'DORMANT ACCOUNTS' ? Border.all(color: const Color(0xFFFEE2E2), width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 8 : 12),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
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
                  color: label == 'DORMANT ACCOUNTS' ? const Color(0xFFDC2626) : AppTheme.headingColor,
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

class _ResponderRow extends StatelessWidget {
  final String name, role, unitId, status, zone;
  final Color statusColor, statusBg;

  const _ResponderRow({
    required this.name, required this.role,
    required this.unitId,
    required this.status, required this.statusColor, required this.statusBg,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, color: Color(0xFF9CA3AF), size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                    Text(role, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(unitId, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(zone, style: const TextStyle(color: Color(0xFF4B5563))),
          ),
          const SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.more_vert, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final String name, joined, email, status, activity;
  final Color statusColor, statusBg;
  final bool isAlert;

  const _UserRow({
    required this.name, required this.joined,
    required this.email,
    required this.status, required this.statusColor, required this.statusBg,
    required this.activity,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, color: Color(0xFF9CA3AF), size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                    Text(joined, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(email, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(activity, style: TextStyle(color: isAlert ? const Color(0xFFDC2626) : const Color(0xFF4B5563), fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: isAlert 
                ? const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626))
                : const Icon(Icons.more_vert, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}
