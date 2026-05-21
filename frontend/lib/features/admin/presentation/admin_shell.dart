import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';

class AdminShell extends StatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (location.startsWith('/admin/dashboard')) {
      _selectedIndex = 0;
    } else if (location.startsWith('/admin/units')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/admin/incidents')) {
      _selectedIndex = 2;
    } else if (location.startsWith('/admin/settings')) {
      _selectedIndex = 3;
    }

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Row(
        children: [
          // ── Left Navigation Rail ──────────────────────────────────────────
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: cs.onSurface.withOpacity(0.05)),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const RapidAidLogo(size: 36, iconSize: 28),
                const SizedBox(height: 48),
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'DASHBOARD',
                  isSelected: _selectedIndex == 0,
                  onTap: () => context.go('/admin/dashboard'),
                  theme: theme,
                ),
                _NavItem(
                  icon: Icons.support_agent_rounded,
                  label: 'UNITS',
                  isSelected: _selectedIndex == 1,
                  onTap: () => context.go('/admin/units'),
                  theme: theme,
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: 'INCIDENTS',
                  isSelected: _selectedIndex == 2,
                  onTap: () => context.go('/admin/incidents'),
                  theme: theme,
                ),
                const Spacer(),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'SETTINGS',
                  isSelected: _selectedIndex == 3,
                  onTap: () => context.go('/admin/settings'),
                  theme: theme,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // ── Main Content ──────────────────────────────────────────────────
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF004F9F) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.5),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
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
