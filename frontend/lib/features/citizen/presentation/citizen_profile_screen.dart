import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';
import '../../../main.dart';
import '../../../core/network/network_client.dart';
import '../../auth/data/token_storage.dart';
import '../../../core/state/data_sync_bloc.dart';
import '../../../core/state/data_sync_event.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// Citizen Profile Screen
/// High-end profile screen with futuristic UI elements matching the Vanguard aesthetic.
class CitizenProfileScreen extends StatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  State<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends State<CitizenProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isDarkTheme = false;
  bool _isLocationEnabled = true;
  String? _profileImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  int _totalReports = 0;
  int _activeReports = 0;

  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _loadProfileSync();
    _fetchProfileData();
  }

  void _loadProfileSync() {
    final ts = getIt<TokenStorage>();
    final name = ts.getUserName();
    final email = ts.getUserEmail();
    final img = ts.getProfileImage();
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }
    if (img != null && img.isNotEmpty) {
      _profileImageBase64 = img;
    }
  }

  Future<void> _fetchProfileData() async {
    // Only fetch for total reports or updates, no need to show loading if we have local data
    if (_nameController.text.isNotEmpty) {
      setState(() => _isLoading = false);
    }
    try {
      final client = getIt<NetworkClient>().dio;
      final profileRes = await client.get('/auth/me/');
      if (profileRes.data != null) {
        final data = profileRes.data;
        final fetchedName =
            "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();
        if (fetchedName.isNotEmpty) {
          _nameController.text = fetchedName;
          getIt<TokenStorage>().saveUserName(fetchedName);
        } else if (data['username'] != null) {
          _nameController.text = data['username'];
          getIt<TokenStorage>().saveUserName(data['username']);
        }
        if (data['email'] != null) {
          _emailController.text = data['email'];
        }
        if (data['profile_image'] != null &&
            data['profile_image'].toString().isNotEmpty) {
          _profileImageBase64 = data['profile_image'];
          getIt<TokenStorage>().saveProfileImage(data['profile_image']);
        }
      }

      final cachedReports = context.read<DataSyncBloc>().state.allReports;
      final List<dynamic> dataList;
      
      if (cachedReports.isNotEmpty) {
        dataList = cachedReports;
        context.read<DataSyncBloc>().add(const DataSyncTriggered(isSilent: true));
      } else {
        final reportsRes = await client.get('/incidents/');
        dataList = (reportsRes.data != null && reportsRes.data is List)
            ? reportsRes.data as List
            : (reportsRes.data != null && reportsRes.data['results'] != null)
                ? reportsRes.data['results'] as List
                : [];
      }
      
      if (dataList.isNotEmpty || cachedReports.isNotEmpty) {
        if (mounted) {
          setState(() {
            _totalReports = dataList.length;
            _activeReports = dataList
                .where((json) =>
                    json['status'] == 'PENDING' || json['status'] == 'ACTIVE')
                .length;
          });
        }
      }
    } catch (e, st) {
      debugPrint("Profile fetch error: $e");
      debugPrint("StackTrace: $st");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final client = getIt<NetworkClient>().dio;
      final parts = _nameController.text.trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      await client.patch('/auth/me/', data: {
        'first_name': firstName,
        'last_name': lastName,
        if (_profileImageBase64 != null) 'profile_image': _profileImageBase64,
      });

      // Update local storage so Dashboards show the new name
      final ts = getIt<TokenStorage>();
      await ts.saveUserName(_nameController.text.trim());
      if (_profileImageBase64 != null) {
        await ts.saveProfileImage(_profileImageBase64!);
      }

      if (mounted) {
        context.read<DataSyncBloc>().add(const DataSyncTriggered(isSilent: true));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile saved successfully'),
            backgroundColor: const Color(0xFF004F9F),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showDeleteDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppTheme.surfaceContainerLowest,
        title: Text(
          'Delete Report Data',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.headingColor,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete all your report data? This action cannot be undone.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.bodyColor.withOpacity(0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.bodyColor.withOpacity(0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Report data deleted successfully'),
                  backgroundColor: AppTheme.emergencyUrl,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emergencyUrl,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppTheme.surfaceContainerLowest,
        title: Text(
          'Sign Out',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.headingColor,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.bodyColor.withOpacity(0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.bodyColor.withOpacity(0.6),
              ),
            ),
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
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
      backgroundColor: const Color(0xFFF8F9FA), // Clean light background
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Custom Topbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: RapidAidLogo(size: 28, iconSize: 26),
                  ),
                  Text(
                    'YOUR PROFILE',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Avatar
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
                                  final reader = html.FileReader();
                                  reader.readAsDataUrl(files[0]);
                                  reader.onLoadEnd.listen((_) {
                                    if (context.mounted) {
                                      setState(() {
                                        _profileImageBase64 =
                                            reader.result as String;
                                      });
                                    }
                                  });
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
                                  color: cs.surfaceContainerHigh,
                                  border:
                                      Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _profileImageBase64 != null
                                      ? Image.memory(
                                          base64Decode(_profileImageBase64!
                                              .split(',')
                                              .last),
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.person,
                                          size: 56,
                                          color: cs.onSurface.withOpacity(0.3)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF004F9F), // Rapid Aid Blue
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                ),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Text Fields
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                _ProfileTextField(
                                  label: 'Full Name',
                                  controller: _nameController,
                                ),
                                const SizedBox(height: 20),
                                _ProfileTextField(
                                  label: 'Email Address',
                                  controller: _emailController,
                                  enabled: false,
                                ),
                              ],
                            ),
                      const SizedBox(height: 24),

                      // Save Changes Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading || _isSaving ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004F9F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(
                                  'Save Changes',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Impact Summary
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IMPACT SUMMARY',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.5),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Total Reports Submitted',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.emergencyUrl.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator())
                                        : Text(
                                            '$_totalReports',
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
                                              color: AppTheme.emergencyUrl,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Active Reports in Progress',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator())
                                        : Text(
                                            '$_activeReports',
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // System Settings Header
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SYSTEM SETTINGS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Settings Card
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // Dark Theme
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Icon(Icons.dark_mode,
                                      color: cs.onSurface.withOpacity(0.6)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dark Theme',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          'Reduce eye strain at night',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: cs.onSurface
                                                      .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _isDarkTheme,
                                    onChanged: (val) =>
                                        setState(() => _isDarkTheme = val),
                                    activeColor: const Color(0xFF004F9F),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                                height: 1,
                                color: cs.onSurface.withOpacity(0.05)),
                            // Location Services
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: cs.onSurface.withOpacity(0.6)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Location Services',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          'Improve aid response accuracy',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: cs.onSurface
                                                      .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _isLocationEnabled,
                                    onChanged: (val) => setState(
                                        () => _isLocationEnabled = val),
                                    activeColor: const Color(0xFF004F9F),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Delete Button
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showDeleteDataDialog(context),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.emergencyUrl,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                          label: Text(
                            "Delete User's Report Data",
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppTheme.emergencyUrl,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign Out
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _showSignOutDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF004F9F), // Rapid Aid Blue
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Sign Out',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom TextField for Profile matching the mockup's floating label style
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

    return TextField(
      controller: controller,
      enabled: enabled,
      style: theme.textTheme.titleMedium?.copyWith(
        color: enabled ? cs.onSurface : cs.onSurface.withOpacity(0.6),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: const Color(0xFF004F9F),
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: enabled
            ? Colors.white.withOpacity(0.5)
            : cs.onSurface.withOpacity(0.03),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF004F9F).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF004F9F),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.onSurface.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}
