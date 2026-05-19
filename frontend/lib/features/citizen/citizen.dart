/// Citizen Feature Module
/// Emergency response interface for citizen users
///
/// This module provides:
/// - Splash screen with tactical handshake
/// - Dashboard with emergency type selection (Medical, Fire, Accident, Security)
/// - Incident details input with editorial tonal style
/// - Dispatch confirmation with validated summary
/// - Live map with frosted glass bottom sheet
/// - Report history with high-density tonal cards
/// - Profile with Signup-style inputs and lowercase email validation
/// - Material 3 Bottom Navbar navigation

// Presentation Layer
export 'presentation/citizen_splash_screen.dart';
export 'presentation/citizen_shell.dart';
export 'presentation/citizen_dashboard_screen.dart';
export 'presentation/citizen_incident_details_screen.dart';
export 'presentation/citizen_dispatch_confirm_screen.dart';
export 'presentation/citizen_map_screen.dart';
export 'presentation/citizen_history_screen.dart';
export 'presentation/citizen_profile_screen.dart';

// Services Layer
export 'services/location_service.dart';
export 'services/dispatch_service.dart';
