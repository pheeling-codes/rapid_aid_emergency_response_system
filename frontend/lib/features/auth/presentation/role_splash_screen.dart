import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth_enums.dart';
import '../../../core/widgets/base_splash_page.dart';
import '../../../core/state/data_sync_bloc.dart';
import '../../../core/state/data_sync_event.dart';
import '../../../core/state/data_sync_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Stage 3: Role-Specific Loading Splash
/// Shows the Rapid Aid branding with the role-specific portal label
/// and handshake message, then auto-redirects to the dashboard.
///
/// Citizen  → "CITIZEN PORTAL"  / "IDENTITY SECURED"
/// Responder → "RESPONDER PORTAL" / "SECURE HANDSHAKE"
/// Admin    → "ADMIN PORTAL"    / "COMMAND CENTER"
class RoleSplashScreen extends StatefulWidget {
  final UserRole role;

  const RoleSplashScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<RoleSplashScreen> createState() => _RoleSplashScreenState();
}

class _RoleSplashScreenState extends State<RoleSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _minTimeElapsed = false;
  bool _isSyncComplete = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Trigger initial state caching
    final bloc = context.read<DataSyncBloc>();
    if (bloc.state.status == DataSyncStatus.success) {
      _isSyncComplete = true;
    } else {
      bloc.add(const DataSyncTriggered(isSilent: false));
    }

    // Minimum 2 seconds splash
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _minTimeElapsed = true;
        _checkNavigate();
      }
    });
  }

  void _checkNavigate() {
    if (_minTimeElapsed && _isSyncComplete) {
      context.go(widget.role.dashboardRoute);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataSyncBloc, DataSyncState>(
      listener: (context, state) {
        if (state.status == DataSyncStatus.success || state.status == DataSyncStatus.failure) {
          _isSyncComplete = true;
          _checkNavigate();
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: BaseSplashPage(
          centerLabel: widget.role.portalLabel,
          bottomIndicatorText: widget.role.splashMessage,
        ),
      ),
    );
  }
}
