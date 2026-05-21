import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: cs.onSurface.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Rapid Aid: System Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Account Profile
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    child: Icon(Icons.person, size: 64, color: cs.onSurface.withOpacity(0.3)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF004F9F),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Chief Administrator',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.headingColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'admin.chief@rapidaid.org',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                              _AccountDetailRow(icon: Icons.badge_outlined, label: 'Employee ID', value: 'RA-ADM-001'),
                              const SizedBox(height: 16),
                              _AccountDetailRow(icon: Icons.shield_outlined, label: 'Access Level', value: 'Level 5 (God Mode)'),
                              const SizedBox(height: 16),
                              _AccountDetailRow(icon: Icons.location_on_outlined, label: 'Assigned Hub', value: 'Central HQ'),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Color(0xFFDC2626)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    foregroundColor: const Color(0xFFDC2626),
                                  ),
                                  child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right Column: System Configurations
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _SettingsSection(
                          title: 'SYSTEM PREFERENCES',
                          icon: Icons.tune_rounded,
                          children: [
                            _SettingsToggle(title: 'Global Dark Mode', subtitle: 'Force dark theme across all operator terminals', value: false),
                            const Divider(height: 1),
                            _SettingsToggle(title: 'High-Contrast Maps', subtitle: 'Enhance visibility of map routes and markers', value: true),
                            const Divider(height: 1),
                            _SettingsToggle(title: 'Auto-Dispatch AI', subtitle: 'Allow system to automatically assign nearest units', value: true),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _SettingsSection(
                          title: 'NOTIFICATION PROTOCOLS',
                          icon: Icons.notifications_active_rounded,
                          children: [
                            _SettingsToggle(title: 'Priority 1 Alarms', subtitle: 'Audible siren for critical life-threatening incidents', value: true),
                            const Divider(height: 1),
                            _SettingsToggle(title: 'Unit Offline Alerts', subtitle: 'Notify when a responder unit loses GPS connection', value: true),
                            const Divider(height: 1),
                            _SettingsToggle(title: 'Citizen Report Ping', subtitle: 'Subtle chime when a new civilian report enters the queue', value: false),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _SettingsSection(
                          title: 'DATA RETENTION',
                          icon: Icons.storage_rounded,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Incident Logs Archive', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.headingColor)),
                                      const SizedBox(height: 4),
                                      Text('Current retention policy: 7 Years', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                                    ],
                                  ),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('Modify Policy'),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}

class _AccountDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AccountDetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF004F9F), size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF004F9F),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsToggle extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool value;

  const _SettingsToggle({required this.title, required this.subtitle, required this.value});

  @override
  State<_SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<_SettingsToggle> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.headingColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOn,
            onChanged: (val) {
              setState(() {
                _isOn = val;
              });
            },
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}
