import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponderShell extends StatefulWidget {
  const ResponderShell({super.key, required this.child});

  final Widget child;

  @override
  State<ResponderShell> createState() => _ResponderShellState();
}

class _ResponderShellState extends State<ResponderShell> {
  int _selectedIndex = 0;

  static const _routes = [
    '/responder/dashboard',
    '/responder/history',
    '/responder/map',
    '/responder/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (location.startsWith('/responder/dashboard')) {
      _selectedIndex = 0;
    } else if (location.startsWith('/responder/history')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/responder/map')) {
      _selectedIndex = 2;
    } else if (location.startsWith('/responder/profile')) {
      _selectedIndex = 3;
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: List.generate(4, (index) {
                final isActive = _selectedIndex == index;
                final items = [
                  _NavItem(icon: Icons.grid_view_rounded, label: 'Overview'),
                  _NavItem(icon: Icons.emergency_share_rounded, label: 'Incidents'),
                  _NavItem(icon: Icons.map_rounded, label: 'Map'),
                  _NavItem(icon: Icons.person_rounded, label: 'Profile'),
                ];
                final item = items[index];

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      context.go(_routes[index]);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? cs.primary.withOpacity(0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: isActive
                                ? cs.primary
                                : cs.onSurface.withOpacity(0.45),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: isActive
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isActive
                                  ? cs.primary
                                  : cs.onSurface.withOpacity(0.45),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
