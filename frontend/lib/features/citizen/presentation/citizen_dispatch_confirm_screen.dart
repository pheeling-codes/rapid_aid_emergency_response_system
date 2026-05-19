import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/action_button.dart';
import '../services/dispatch_service.dart';
import '../services/location_service.dart';

/// Citizen Dispatch Confirm Screen
/// Step 3: Confirm & Dispatch
/// High-precision summary screen with validated address, category, and description
/// Primary action is a 56px 'Confirm & Dispatch' button in Emergency Red
/// Wires to DispatchService for nearest-responder logic
class CitizenDispatchConfirmScreen extends StatefulWidget {
  const CitizenDispatchConfirmScreen({super.key});

  @override
  State<CitizenDispatchConfirmScreen> createState() =>
      _CitizenDispatchConfirmScreenState();
}

class _CitizenDispatchConfirmScreenState
    extends State<CitizenDispatchConfirmScreen> {
  final DispatchService _dispatchService = DispatchService();
  final LocationService _locationService = LocationService();
  bool _isDispatching = false;

  Future<void> _handleDispatch() async {
    final data = ModalRoute.of(context)?.settings.arguments as Map?;
    final type = data?['type'] as String? ?? 'SOS';
    final description = data?['description'] as String? ?? 'Emergency reported';
    final hasPhoto = data?['hasPhoto'] as bool? ?? false;

    setState(() => _isDispatching = true);

    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();

      // Dispatch emergency
      final result = await _dispatchService.dispatchEmergency(
        type: type,
        description: description,
        location: position != null
            ? {'latitude': position.latitude, 'longitude': position.longitude}
            : {'latitude': 0.0, 'longitude': 0.0},
        hasPhoto: hasPhoto,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Dispatch successful'),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.go('/citizen/map');
        } else {
          setState(() => _isDispatching = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Dispatch failed. Please try again.'),
              backgroundColor: AppTheme.emergencyUrl,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDispatching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.emergencyUrl,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = ModalRoute.of(context)?.settings.arguments as Map?;
    final type = data?['type'] as String? ?? 'SOS';
    final description = data?['description'] as String? ?? 'Emergency reported';
    final hasPhoto = data?['hasPhoto'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CONFIRM DISPATCH',
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Warning Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.emergencyUrl.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.emergencyUrl,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This will dispatch emergency responders to your current location.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.emergencyUrl,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Incident Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        offset: const Offset(0, 12),
                        blurRadius: 24,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type
                      Text(
                        'EMERGENCY TYPE',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.bodyColor.withOpacity(0.5),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type.toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.headingColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        'DESCRIPTION',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.bodyColor.withOpacity(0.5),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.bodyColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Location
                      Text(
                        'LOCATION',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.bodyColor.withOpacity(0.5),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current GPS Location',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.bodyColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Photo Status
                      if (hasPhoto) ...[
                        Text(
                          'PHOTO EVIDENCE',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppTheme.bodyColor.withOpacity(0.5),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Photo attached',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppTheme.bodyColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Safety Disclaimer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.bodyColor.withOpacity(0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'False reports are subject to legal penalties. Help will be dispatched to your verified location.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.bodyColor.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Confirm & Dispatch Button - 56px height
                ActionButton(
                  label:
                      _isDispatching ? 'DISPATCHING...' : 'CONFIRM & DISPATCH',
                  isEmergency: true,
                  icon: Icons.emergency,
                  isLoading: _isDispatching,
                  onPressed: _isDispatching ? null : _handleDispatch,
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
