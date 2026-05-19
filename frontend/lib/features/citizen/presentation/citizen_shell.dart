import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';

/// Citizen Shell
/// Material 3 Bottom Navbar with exactly 4 destinations:
/// - Home (Dashboard): The tactical trigger center
/// - Map: The live tracking and regional safety view
/// - History: A high-density list of past reports
/// - Profile: A clean settings view
class CitizenShell extends StatefulWidget {
  const CitizenShell({super.key, required this.child});

  final Widget child;

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int _selectedIndex = 0;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'Map',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: 'History',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    // Update selected index based on current route
    if (location.startsWith('/citizen/dashboard')) {
      _selectedIndex = 0;
    } else if (location.startsWith('/citizen/map')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/citizen/history')) {
      _selectedIndex = 2;
    } else if (location.startsWith('/citizen/profile')) {
      _selectedIndex = 3;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              context.go('/citizen/dashboard');
              break;
            case 1:
              context.go('/citizen/map');
              break;
            case 2:
              context.go('/citizen/history');
              break;
            case 3:
              context.go('/citizen/profile');
              break;
          }
        },
        destinations: _destinations,
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

/// Route configuration for citizen shell
class CitizenRoutes {
  static const String splash = '/citizen/splash';
  static const String dashboard = '/citizen/dashboard';
  static const String incidentDetails = '/citizen/incident-details';
  static const String dispatchConfirm = '/citizen/dispatch-confirm';
  static const String map = '/citizen/map';
  static const String history = '/citizen/history';
  static const String reportDetails = '/citizen/report-details';
  static const String profile = '/citizen/profile';
}
