import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../../core/network/network_client.dart';
import '../../../main.dart';
import '../../auth/data/token_storage.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';
import '../../../core/state/data_sync_bloc.dart';
import '../../../core/state/data_sync_event.dart';

/// Responder Profile Screen
/// Premium profile with stats, duty toggle, credentials and session controls.
class ResponderProfileScreen extends StatefulWidget {
  const ResponderProfileScreen({super.key});

  @override
  State<ResponderProfileScreen> createState() => _ResponderProfileScreenState();
}

class _ResponderProfileScreenState extends State<ResponderProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isOnDuty = true;
  bool _isDarkMode = false;
  String? _profileImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  String _totalResponses = '0';
  String _totalDutyHours = '0';

  @override
  void initState() {
    super.initState();
    _loadProfileSync();
    _fetchProfileStats();
  }

  void _loadProfileSync() {
    final ts = getIt<TokenStorage>();
    final name = ts.getUserName();
    final email = ts.getUserEmail();
    final img = ts.getProfileImage();
    if (name != null && name.isNotEmpty) _nameController.text = name;
    if (email != null && email.isNotEmpty) _emailController.text = email;
    if (img != null && img.isNotEmpty) _profileImageUrl = img;
    _isOnDuty = ts.getIsOnDuty();
  }

  Future<void> _fetchProfileStats() async {
    try {
      final dio = getIt<NetworkClient>().dio;
      final res = await dio.get('/incidents/');
      final dataList = (res.data is List)
          ? res.data as List
          : res.data['results'] as List? ?? [];

      if (mounted) {
        setState(() {
          _totalResponses = dataList
              .where((i) => i['status'] == 'RESOLVED')
              .length
              .toString();
          // Mock duty hours based on responses
          _totalDutyHours = (dataList.length * 3).toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);
    try {
      final dio = getIt<NetworkClient>().dio;
      final parts = _nameController.text.trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final Map<String, dynamic> data = {
        'first_name': firstName,
        'last_name': lastName,
      };

      if (_profileImageUrl != null && _profileImageUrl!.startsWith('data:')) {
        data['profile_image'] = _profileImageUrl;
      }

      final response = await dio.patch('/auth/me/', data: data);
      final ts = getIt<TokenStorage>();
      final newName =
          "${response.data['first_name'] ?? ''} ${response.data['last_name'] ?? ''}"
              .trim();
      if (newName.isNotEmpty) {
        await ts.saveUserName(newName);
      }
      if (response.data['profile_image'] != null) {
        await ts.saveProfileImage(response.data['profile_image']);
        _profileImageUrl = response.data['profile_image'];
      }

      if (mounted) {
        context.read<DataSyncBloc>().add(const DataSyncTriggered(isSilent: true));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleDuty(bool value) async {
    setState(() => _isOnDuty = value);
    getIt<TokenStorage>().saveIsOnDuty(value);
    try {
      final dio = getIt<NetworkClient>().dio;
      await dio.patch('/auth/me/', data: {'is_available': value});
    } catch (e) {
      debugPrint('Duty toggle error: $e');
      // Revert on failure
      if (mounted) {
        setState(() => _isOnDuty = !value);
        getIt<TokenStorage>().saveIsOnDuty(!value);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _pickAvatar() {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..click();
      input.onChange.listen((e) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final reader = html.FileReader();
          reader.readAsDataUrl(files[0]);
          reader.onLoadEnd.listen((_) {
            final base64str = reader.result as String;
            if (mounted) setState(() => _profileImageUrl = base64str);
          });
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
              context.read<DataSyncBloc>().add(DataSyncStopPolling());
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
                      name: _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Unit 402',
                      onTap: _pickAvatar,
                      theme: theme,
                      cs: cs,
                    ),
                    const SizedBox(height: 24),

                    // Profile Edit Fields
                    _ProfileTextField(
                      label: 'Full Name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    _ProfileTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),

                    // Save Changes Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading || _isSaving ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004F9F),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                'Save Profile',
                                style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Banner
                    _StatsBanner(
                      theme: theme,
                      totalResponses: _totalResponses,
                      totalDutyHours: _totalDutyHours,
                    ),
                    const SizedBox(height: 16),

                    // Active Duty Toggle
                    _DutyToggleCard(
                      isOnDuty: _isOnDuty,
                      onChanged: (v) {
                        _toggleDuty(v);
                      },
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
  final String name;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme cs;

  const _AvatarSection({
    required this.profileImageUrl,
    required this.name,
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
      ],
    );
  }
}

class _StatsBanner extends StatelessWidget {
  final ThemeData theme;
  final String totalResponses;
  final String totalDutyHours;

  const _StatsBanner({
    required this.theme,
    required this.totalResponses,
    required this.totalDutyHours,
  });

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
                  totalResponses,
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
                      totalDutyHours,
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
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primary,
            inactiveThumbColor: AppTheme.primary,
            inactiveTrackColor: const Color(0xFFEEF2F6),
            // thumbColor: WidgetStateProperty.all(Colors.white),
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
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primary,
            inactiveThumbColor: AppTheme.primary,
            inactiveTrackColor: const Color(0xFFEEF2F6),
            // thumbColor: WidgetStateProperty.all(AppTheme.primary),
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

class _ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const _ProfileTextField({
    required this.label,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color:
                enabled ? AppTheme.headingColor : cs.onSurface.withOpacity(0.4),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.onSurface.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.onSurface.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF004F9F), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.onSurface.withOpacity(0.05)),
            ),
          ),
        ),
      ],
    );
  }
}
