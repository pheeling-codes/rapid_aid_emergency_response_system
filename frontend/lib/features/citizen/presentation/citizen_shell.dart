import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/notification_checker.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';

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

    return NotificationChecker(
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Scaffold(
            backgroundColor: cs.surface,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_iphone_rounded,
                        size: 64, color: cs.primary.withOpacity(0.5)),
                    const SizedBox(height: 24),
                    Text(
                      'CITIZEN OPERATIONS RESTRICTED ON DESKTOP',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PLEASE ACCESS VIA MOBILE DEVICE.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
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
                        foregroundColor: cs.onSurface.withOpacity(0.8),
                        side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
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
                  return IconThemeData(
                      color: cs.onSurface.withOpacity(0.6), size: 24);
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
      }),
    );
  }
}
