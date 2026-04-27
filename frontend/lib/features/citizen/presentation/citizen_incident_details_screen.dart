import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_button.dart';

/// CitizenIncidentDetailsScreen - Incident details form with description and evidence
/// Migrated from incident_details_screen.dart with Clinical Vanguard design compliance
class CitizenIncidentDetailsScreen extends StatefulWidget {
  final String incidentType;

  const CitizenIncidentDetailsScreen({
    super.key,
    required this.incidentType,
  });

  @override
  State<CitizenIncidentDetailsScreen> createState() =>
      _CitizenIncidentDetailsScreenState();
}

class _CitizenIncidentDetailsScreenState
    extends State<CitizenIncidentDetailsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _hasPhoto = false;

  String get _displayType {
    switch (widget.incidentType.toLowerCase()) {
      case 'fire':
        return 'Fire';
      case 'accident':
        return 'Accident';
      case 'security':
        return 'Security';
      default:
        return 'Medical';
    }
  }

  String get _placeholder {
    switch (widget.incidentType.toLowerCase()) {
      case 'fire':
        return 'Describe the fire (e.g., "Building fire on Lagos Island")';
      case 'accident':
        return 'Describe the accident (e.g., "Two-car collision on Third Mainland Bridge")';
      case 'security':
        return 'Describe the security concern (e.g., "Armed robbery at Lekki Phase 1")';
      default:
        return 'Describe the situation (e.g., "Two-car collision on Third Mainland Bridge").';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.headingColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Incident Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incident Details',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide a brief description or upload a photo to help responders prepare.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Situation Description - Using surfaceContainerHigh (No-Line Rule)
            Text(
              'SITUATION DESCRIPTION',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                // No border per No-Line Rule
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: _placeholder,
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_descriptionController.text.length} / 500',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Evidence - Using tonal depth for state indication
            Text(
              'EVIDENCE (OPTIONAL)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _hasPhoto = !_hasPhoto),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: _hasPhoto
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  // No border per No-Line Rule
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _hasPhoto
                            ? Icons.check_circle
                            : Icons.add_a_photo_outlined,
                        color: _hasPhoto
                            ? AppTheme.primary
                            : cs.onSurface.withOpacity(0.6),
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasPhoto ? 'Photo Added' : 'Attach Photo/Video',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _hasPhoto
                            ? AppTheme.primary
                            : AppTheme.headingColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capture or select from gallery',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurface.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info notice - Emergency Red with tonal depth
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.emergencyUrl.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.emergencyUrl,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your location and identity will be shared with the rapid response team to ensure immediate assistance.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.emergencyUrl,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Review Emergency button - Using RapidAidButton with Emergency Red
            RapidAidButton(
              label: 'Review Emergency',
              onPressed: () {
                context.push(
                  '/citizen/dispatch-confirm',
                  extra: {
                    'type': _displayType,
                    'description': _descriptionController.text.isNotEmpty
                        ? _descriptionController.text
                        : 'Two-car collision with visible injuries. Requesting immediate ambulance support.',
                  },
                );
              },
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }
}
