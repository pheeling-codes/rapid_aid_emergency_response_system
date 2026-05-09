import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_button.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';

/// CitizenProfileScreen - User profile and settings
/// Clinical Vanguard Design System Compliance:
/// - AuthTextField for editorial input style with lowercase enforcement
/// - No borders on avatar (No-Line Rule)
/// - Tonal depth for section separation
/// - Deep Slate (#111827) for headings
class CitizenProfileScreen extends StatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  State<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends State<CitizenProfileScreen> {
  bool _darkTheme = false;
  bool _locationServices = true;

  final _nameController = TextEditingController(text: 'Alex Henderson');
  final _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  final _emailController = TextEditingController(text: 'alex.h@rapidaid.org');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header Card - Using surfaceContainerLowest
              Container(
                color: AppTheme.surfaceContainerLowest,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar - Primary Blue accent, NO BORDER per No-Line Rule
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                            // Border removed per No-Line Rule
                          ),
                          child: const ClipOval(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Profile Fields - Using AuthTextField with editorial style
                    // Email field enforces lowercase validation
                    AuthTextField(
                      label: 'FULL NAME',
                      hintText: 'Enter your full name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'PHONE NUMBER',
                      hintText: 'Enter your phone number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'EMAIL ADDRESS',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      forceLowercase: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Impact Summary - Using surfaceContainerLowest
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IMPACT SUMMARY',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.bodyColor.withOpacity(0.5),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Reports Submitted',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '12',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: AppTheme.surfaceContainerHigh,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Top 5% of active community responders',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.bodyColor.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // System Settings - Using surfaceContainerLowest
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYSTEM SETTINGS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.bodyColor.withOpacity(0.5),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _SettingsToggle(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Theme',
                            subtitle: 'Reduce eye strain at night',
                            value: _darkTheme,
                            onChanged: (v) => setState(() => _darkTheme = v),
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppTheme.surfaceContainerHigh,
                          ),
                          _SettingsToggle(
                            icon: Icons.location_on_outlined,
                            title: 'Location Services',
                            subtitle: 'Improve aid response accuracy',
                            value: _locationServices,
                            onChanged: (v) =>
                                setState(() => _locationServices = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Delete data - Emergency Red accent
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => _showDeleteConfirmation(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.emergencyUrl.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppTheme.emergencyUrl,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Delete User's Report Data",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.emergencyUrl,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign Out - Using RapidAidButton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RapidAidButton(
                  label: 'Sign Out',
                  onPressed: () => _showSignOutDialog(context),
                  isPrimary: true,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
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
          ),
        ),
        content: Text(
          'This will permanently delete all your report data. This action cannot be undone.',
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
            onPressed: () => Navigator.pop(ctx),
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
}

// _ProfileField removed - using AuthTextField instead for consistency

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 12,
                    color: AppTheme.bodyColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
