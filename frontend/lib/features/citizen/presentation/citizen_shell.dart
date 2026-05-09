import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';

/// CitizenShell provides the main scaffold with bottom navigation
/// for all citizen-facing screens.
class CitizenShell extends StatefulWidget {
  final Widget child;

  const CitizenShell({
    super.key,
    required this.child,
  });

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/citizen/dashboard')) return 0;
    if (location.startsWith('/citizen/active')) return 1;
    if (location.startsWith('/citizen/reports')) return 2;
    if (location.startsWith('/citizen/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/citizen/dashboard');
        break;
      case 1:
        context.go('/citizen/active');
        break;
      case 2:
        context.go('/citizen/reports');
        break;
      case 3:
        context.go('/citizen/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _calculateSelectedIndex(location);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        indicatorColor: AppTheme.primary.withOpacity(0.1),
        destinations: [
          // Home - Emergency Dashboard
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: selectedIndex == 0
                  ? AppTheme.primary
                  : AppTheme.bodyColor.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.home,
              color: AppTheme.primary,
            ),
            label: 'Home',
          ),
          // Map - Active Incident / Live Tracking
          NavigationDestination(
            icon: Icon(
              Icons.map_outlined,
              color: selectedIndex == 1
                  ? AppTheme.primary
                  : AppTheme.bodyColor.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.map,
              color: AppTheme.primary,
            ),
            label: 'Map',
          ),
          // History - Report History
          NavigationDestination(
            icon: Icon(
              Icons.history,
              color: selectedIndex == 2
                  ? AppTheme.primary
                  : AppTheme.bodyColor.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.history,
              color: AppTheme.primary,
            ),
            label: 'History',
          ),
          // Profile - User Settings
          NavigationDestination(
            icon: Icon(
              Icons.person_outlined,
              color: selectedIndex == 3
                  ? AppTheme.primary
                  : AppTheme.bodyColor.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.person,
              color: AppTheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
