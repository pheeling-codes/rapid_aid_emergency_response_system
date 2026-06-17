import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../../core/widgets/notification_checker.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';

class AdminShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AdminShell({super.key, required this.navigationShell});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;
  bool _isExpanded = false; // Add state for collapsible sidebar

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    _selectedIndex = widget.navigationShell.currentIndex;

    void goBranch(int index) {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }

    return NotificationChecker(
      child: LayoutBuilder(
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
                      Icon(Icons.desktop_mac_rounded,
                          size: 64, color: cs.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 24),
                      Text(
                        'ADMIN ACCESS RESTRICTED ON MOBILE',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PLEASE ACCESS VIA WEB-VIEW.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Clear memory cache if any
                          // Trigger sign out which clears the session and JWTs
                          context.read<AuthBloc>().add(const AuthLogoutRequested());
                          // Hard routing push to login
                          context.go('/login');
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('BACK TO LOGIN'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface.withValues(alpha: 0.8),
                          side: BorderSide(color: cs.onSurface.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
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
            body: Row(
              children: [
                // ── Left Navigation Rail ──────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isExpanded ? 240 : 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: cs.onSurface.withOpacity(0.05)),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 40),
                          _isExpanded
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const RapidAidLogo(size: 32, iconSize: 24),
                                    const SizedBox(width: 12),
                                    Text('Rapid Aid',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: AppTheme.headingColor)),
                                  ],
                                )
                              : const RapidAidLogo(size: 36, iconSize: 28),
                          const SizedBox(height: 48),
                          _NavItem(
                            icon: Icons.dashboard_rounded,
                            label: 'DASHBOARD',
                            isSelected: _selectedIndex == 0,
                            isExpanded: _isExpanded,
                            onTap: () => goBranch(0),
                            theme: theme,
                          ),
                          _NavItem(
                            icon: Icons.support_agent_rounded,
                            label: 'UNITS',
                            isSelected: _selectedIndex == 1,
                            isExpanded: _isExpanded,
                            onTap: () => goBranch(1),
                            theme: theme,
                          ),
                          _NavItem(
                            icon: Icons.history_rounded,
                            label: 'INCIDENTS',
                            isSelected: _selectedIndex == 2,
                            isExpanded: _isExpanded,
                            onTap: () => goBranch(2),
                            theme: theme,
                          ),
                          const Spacer(),
                          _NavItem(
                            icon: Icons.settings_rounded,
                            label: 'SETTINGS',
                            isSelected: _selectedIndex == 3,
                            isExpanded: _isExpanded,
                            onTap: () => goBranch(3),
                            theme: theme,
                            activeColor: const Color(
                                0xFFDC2626), // Red color for settings
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                      Positioned(
                        right: -12,
                        top: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: cs.onSurface.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isExpanded
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              color: cs.onSurface.withOpacity(0.5),
                              size: 16,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Main Content ──────────────────────────────────────────────────
                Expanded(child: widget.navigationShell),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final ThemeData theme;
  final Color? activeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    required this.theme,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 12, vertical: 8),
          padding: EdgeInsets.symmetric(
              vertical: 16, horizontal: isExpanded ? 16 : 0),
          decoration: BoxDecoration(
            color: isSelected
                ? (activeColor ?? const Color(0xFF004F9F))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isExpanded
              ? Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : cs.onSurface.withOpacity(0.5),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : cs.onSurface.withOpacity(0.5),
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : cs.onSurface.withOpacity(0.5),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : cs.onSurface.withOpacity(0.5),
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
