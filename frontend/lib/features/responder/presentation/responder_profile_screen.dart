import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';

/// Responder Profile Screen
/// Premium profile with stats, duty toggle, credentials and session controls.
class ResponderProfileScreen extends StatefulWidget {
  const ResponderProfileScreen({super.key});

  @override
  State<ResponderProfileScreen> createState() => _ResponderProfileScreenState();
}

class _ResponderProfileScreenState extends State<ResponderProfileScreen> {
  bool _isOnDuty = true;
  bool _isDarkMode = false;
  String? _profileImageUrl;

  void _pickAvatar() {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..click();
      input.onChange.listen((e) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final url = html.Url.createObjectUrlFromBlob(files[0]);
          if (mounted) setState(() => _profileImageUrl = url);
        }
      });
    }
  }

  void _showEndSessionDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          'End Active Duty Session?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.headingColor,
          ),
        ),
        content: Text(
          'You will no longer receive emergency dispatches. Confirm to go off-duty.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.bodyColor.withOpacity(0.65),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.bodyColor.withOpacity(0.5),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isOnDuty = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emergencyUrl,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('End Session',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          'Delete Response Data?',
          style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700, color: AppTheme.headingColor),
        ),
        content: Text(
          'This will permanently delete all your response history and cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.bodyColor.withOpacity(0.6),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: AppTheme.bodyColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emergencyUrl,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          'Sign Out',
          style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700, color: AppTheme.headingColor),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppTheme.bodyColor.withOpacity(0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: AppTheme.bodyColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed Topbar ───────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(
                children: [
                  const RapidAidLogo(size: 32, iconSize: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'YOUR PROFILE',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: cs.surfaceContainerHigh, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.surfaceContainerLow,
                      child: Icon(Icons.person_rounded,
                          color: cs.onSurface.withOpacity(0.6), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar + Identity
                    _AvatarSection(
                      profileImageUrl: _profileImageUrl,
                      onTap: _pickAvatar,
                      theme: theme,
                      cs: cs,
                    ),
                    const SizedBox(height: 20),

                    // Stats Banner
                    _StatsBanner(theme: theme),
                    const SizedBox(height: 16),

                    // Active Duty Toggle
                    _DutyToggleCard(
                      isOnDuty: _isOnDuty,
                      onChanged: (v) => setState(() => _isOnDuty = v),
                      theme: theme,
                      cs: cs,
                    ),
                    const SizedBox(height: 10),

                    // Dark / Light Mode Toggle
                    _ThemeModeToggleCard(
                      isDarkMode: _isDarkMode,
                      onChanged: (v) => setState(() => _isDarkMode = v),
                      theme: theme,
                      cs: cs,
                    ),
                    const SizedBox(height: 20),

                    // Menu Items
                    _MenuSection(theme: theme, cs: cs),
                    const SizedBox(height: 24),

                    // Sign Out Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _showSignOutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sign Out',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Delete Data Link
                    Center(
                      child: TextButton(
                        onPressed: _showDeleteDialog,
                        child: Text(
                          'Delete Response Data',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.emergencyUrl,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final String? profileImageUrl;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme cs;

  const _AvatarSection({
    required this.profileImageUrl,
    required this.onTap,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainerHigh,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profileImageUrl != null
                        ? Image.network(profileImageUrl!,
                            fit: BoxFit.cover, width: 110, height: 110)
                        : Icon(Icons.person_rounded,
                            size: 60, color: cs.onSurface.withOpacity(0.35)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Name
        Text(
          'Unit 402',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.headingColor,
          ),
        ),
        const SizedBox(height: 6),

        // Rank badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'RESPONDER RANK II',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Verified phone
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, size: 14, color: AppTheme.primary),
            const SizedBox(width: 6),
            Text(
              '+234 812 345 6789',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.headingColor.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsBanner extends StatelessWidget {
  final ThemeData theme;
  const _StatsBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004F9F), Color(0xFF0066CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL NO. OF RESPONSES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withOpacity(0.65),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '24',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                Container(
                  height: 4,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.98,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 70,
            color: Colors.white.withOpacity(0.15),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ACTIVE DUTY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withOpacity(0.65),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '250',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'hrs',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Lifetime statistics',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                    fontSize: 10,
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

class _DutyToggleCard extends StatelessWidget {
  final bool isOnDuty;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;
  final ColorScheme cs;

  const _DutyToggleCard({
    required this.isOnDuty,
    required this.onChanged,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sensors_rounded,
                color: Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Duty ${isOnDuty ? 'ONLINE' : 'OFFLINE'}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.headingColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnDuty
                      ? 'Broadcasting location to dispatch'
                      : 'Not broadcasting — off duty',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnDuty,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            thumbColor: WidgetStateProperty.all(Colors.white),
            activeTrackColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ThemeModeToggleCard extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;
  final ColorScheme cs;

  const _ThemeModeToggleCard({
    required this.isDarkMode,
    required this.onChanged,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1A237E).withOpacity(0.1)
                  : const Color(0xFFFFF8E1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDarkMode
                  ? const Color(0xFF3949AB)
                  : const Color(0xFFFFB300),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.headingColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDarkMode
                      ? 'Darker interface for low-light'
                      : 'Bright interface for daylight',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            thumbColor: WidgetStateProperty.all(Colors.white),
            activeTrackColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  const _MenuSection({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.notifications_rounded,
        label: 'Alert Preferences',
        iconBg: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFE65100),
      ),
      _MenuItem(
        icon: Icons.badge_rounded,
        label: 'Professional Credentials',
        iconBg: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF1565C0),
      ),
    ];

    return Column(
      children: List.generate(items.length, (i) {
        final item = items[i];
        final isLast = i == items.length - 1;
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: item.iconBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              Icon(item.icon, color: item.iconColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.headingColor,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: cs.onSurface.withOpacity(0.3), size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!isLast) const SizedBox(height: 10),
          ],
        );
      }),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
  });
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme cs;

  const _OutlineActionButton({
    required this.label,
    required this.onTap,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: cs.onSurface.withOpacity(0.15), width: 1.5),
          backgroundColor: Colors.white,
        ),
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.headingColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
