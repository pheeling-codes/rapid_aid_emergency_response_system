import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../../core/theme/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  String? _profileImageUrl;

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.headingColor),
        ),
        content: const Text(
          'Are you sure you want to sign out of the Admin Dashboard?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetSystemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('CRITICAL WARNING', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
          ],
        ),
        content: const Text(
          'Are you sure you want to completely RESET the system and permanently delete all user data? This action is irreversible and requires Level 5 God Mode clearance.',
          style: TextStyle(color: Color(0xFF6B7280), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('System reset initiated. All data is being purged...'),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CONFIRM PURGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Scaffold(
            backgroundColor: cs.surface,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.desktop_mac_rounded, size: 64, color: cs.primary.withOpacity(0.5)),
                    const SizedBox(height: 24),
                    Text(
                      'COMMAND CENTER ACCESS RESTRICTED',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PLEASE USE A DESKTOP TERMINAL.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    if (kIsWeb) {
                                      final input = html.FileUploadInputElement()
                                        ..accept = 'image/*'
                                        ..click();
                                      input.onChange.listen((e) {
                                        final files = input.files;
                                        if (files != null && files.isNotEmpty) {
                                          final objectUrl = html.Url.createObjectUrlFromBlob(files[0]);
                                          if (mounted) {
                                            setState(() {
                                              _profileImageUrl = objectUrl;
                                            });
                                          }
                                        }
                                      });
                                    }
                                  },
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFF3F4F6),
                                          border: Border.all(color: Colors.white, width: 4),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _profileImageUrl != null
                                              ? Image.network(_profileImageUrl!, fit: BoxFit.cover, width: 120, height: 120)
                                              : Icon(Icons.person, size: 64, color: cs.onSurface.withOpacity(0.3)),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF004F9F),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                      ),
                                    ],
                                  ),
                                ),
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
                                  onPressed: () => _showSignOutDialog(context),
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
                            _SettingsToggle(title: 'Admin View Only Theme', subtitle: 'Apply dedicated contrast styling strictly to admin terminal', value: true),
                            const Divider(height: 1),
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
                            _SettingsToggle(title: 'Unit Offline Alerts', subtitle: 'Notify when a responder unit loses GPS connection', value: true),
                            const Divider(height: 1),
                            _SettingsToggle(title: 'Citizen Report Ping', subtitle: 'Subtle chime when a new civilian report enters the queue', value: false),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _SettingsSection(
                          title: 'DATA RETENTION & COMPLIANCE',
                          icon: Icons.security_rounded,
                          isDanger: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('System Wipe / Data Purge', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFDC2626))),
                                      const SizedBox(height: 4),
                                      Text('Permanently delete ALL user and incident data', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _showResetSystemDialog(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDC2626),
                                    ),
                                    child: const Text('RESET SYSTEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
      },
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
  final bool isDanger;

  const _SettingsSection({required this.title, required this.icon, required this.children, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDanger ? const Color(0xFFDC2626) : const Color(0xFF004F9F);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
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
            border: isDanger ? Border.all(color: const Color(0xFFFEE2E2), width: 2) : null,
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
