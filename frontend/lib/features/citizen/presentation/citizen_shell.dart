import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';

class CitizenShell extends StatefulWidget {
  const CitizenShell({super.key, required this.child});

  final Widget child;

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (location.startsWith('/citizen/dashboard')) {
      _selectedIndex = 0;
    } else if (location.startsWith('/citizen/history')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/citizen/map')) {
      _selectedIndex = 2;
    } else if (location.startsWith('/citizen/profile')) {
      _selectedIndex = 3;
    }

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: cs.primary.withOpacity(0.1),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return theme.textTheme.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                );
              }
              return theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w700,
                fontSize: 10,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: cs.primary, size: 24);
              }
              return IconThemeData(color: cs.onSurface.withOpacity(0.6), size: 24);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              switch (index) {
                case 0:
                  context.go('/citizen/dashboard');
                  break;
                case 1:
                  context.go('/citizen/history'); // Reports
                  break;
                case 2:
                  context.go('/citizen/map');
                  break;
                case 3:
                  context.go('/citizen/profile');
                  break;
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_filled),
                label: 'HOME',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment),
                label: 'REPORTS',
              ),
              NavigationDestination(
                icon: Icon(Icons.map),
                label: 'MAP',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'PROFILE',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
