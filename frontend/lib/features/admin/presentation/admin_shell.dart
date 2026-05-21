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
  bool _isExpanded = false; // Add state for collapsible sidebar

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
                              Text('Rapid Aid', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.headingColor)),
                            ],
                          )
                        : const RapidAidLogo(size: 36, iconSize: 28),
                    const SizedBox(height: 48),
                    _NavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'DASHBOARD',
                      isSelected: _selectedIndex == 0,
                      isExpanded: _isExpanded,
                      onTap: () => context.go('/admin/dashboard'),
                      theme: theme,
                    ),
                    _NavItem(
                      icon: Icons.support_agent_rounded,
                      label: 'UNITS',
                      isSelected: _selectedIndex == 1,
                      isExpanded: _isExpanded,
                      onTap: () => context.go('/admin/units'),
                      theme: theme,
                    ),
                    _NavItem(
                      icon: Icons.history_rounded,
                      label: 'INCIDENTS',
                      isSelected: _selectedIndex == 2,
                      isExpanded: _isExpanded,
                      onTap: () => context.go('/admin/incidents'),
                      theme: theme,
                    ),
                    const Spacer(),
                    _NavItem(
                      icon: Icons.settings_rounded,
                      label: 'SETTINGS',
                      isSelected: _selectedIndex == 3,
                      isExpanded: _isExpanded,
                      onTap: () => context.go('/admin/settings'),
                      theme: theme,
                      activeColor: const Color(0xFFDC2626), // Red color for settings
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
                      border: Border.all(color: cs.onSurface.withOpacity(0.1)),
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
                        _isExpanded ? Icons.chevron_left : Icons.chevron_right,
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
          margin: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 12, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: isExpanded ? 16 : 0),
          decoration: BoxDecoration(
            color: isSelected ? (activeColor ?? const Color(0xFF004F9F)) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isExpanded
              ? Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.5),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.5),
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
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
