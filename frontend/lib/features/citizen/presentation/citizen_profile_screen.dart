import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Citizen Profile Screen
/// High-end profile screen with futuristic UI elements matching the Vanguard aesthetic.
class CitizenProfileScreen extends StatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  State<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends State<CitizenProfileScreen> {
  final _nameController = TextEditingController(text: 'Alex Henderson');
  final _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  final _emailController = TextEditingController(text: 'alex.h@rapidaid.org');

  bool _isDarkTheme = false;
  bool _isLocationEnabled = true;
  String? _profileImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
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
                                  final objectUrl =
                                      html.Url.createObjectUrlFromBlob(files[0]);
                                  if (context.mounted) {
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
                                  child: _profileImageUrl != null
                                      ? Image.network(
                                          _profileImageUrl!,
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                        )
                                      : Icon(Icons.person,
                                          size: 70,
                                          color: cs.onSurface.withOpacity(0.4)),
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
                      _ProfileTextField(
                        label: 'Full Name',
                        controller: _nameController,
                      ),
                      const SizedBox(height: 20),
                      _ProfileTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                      ),
                      const SizedBox(height: 20),
                      _ProfileTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        enabled: false,
                      ),
                      const SizedBox(height: 24),

                      // Save Changes Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Profile saved successfully'),
                                backgroundColor: const Color(0xFF004F9F),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004F9F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
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
                                    child: Text(
                                      '12',
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
                            // Progress Bar
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cs.onSurface.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.75, // Just visual
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF004F9F),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Top 5% of active community responders',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
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
                          onPressed: () {},
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
