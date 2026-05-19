import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/action_button.dart';

/// Citizen Incident Details Screen
/// Step 2: Input Emergency Details
/// Minimalist form for situation description and media upload
/// Uses Editorial tonal input style
class CitizenIncidentDetailsScreen extends StatefulWidget {
  const CitizenIncidentDetailsScreen({super.key});

  @override
  State<CitizenIncidentDetailsScreen> createState() =>
      _CitizenIncidentDetailsScreenState();
}

class _CitizenIncidentDetailsScreenState
    extends State<CitizenIncidentDetailsScreen> {
  final _descriptionController = TextEditingController();
  bool _hasPhoto = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = ModalRoute.of(context)?.settings.arguments as Map?;

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
          'INCIDENT DETAILS',
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

                // Category Display
                if (category != null && category['type'] != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              category['icon'] ?? '🚨',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EMERGENCY TYPE',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppTheme.bodyColor.withOpacity(0.5),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category['type']?.toString().toUpperCase() ??
                                    'UNKNOWN',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppTheme.headingColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Description Field
                Text(
                  'SITUATION DESCRIPTION',
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Describe the emergency situation...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.bodyColor.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Photo Upload
                Text(
                  'PHOTO EVIDENCE',
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() => _hasPhoto = !_hasPhoto);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _hasPhoto
                            ? AppTheme.primary
                            : AppTheme.surfaceContainerLow,
                        width: _hasPhoto ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasPhoto
                                ? Icons.check_circle
                                : Icons.add_photo_alternate,
                            size: 48,
                            color: _hasPhoto
                                ? AppTheme.primary
                                : AppTheme.bodyColor.withOpacity(0.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hasPhoto ? 'Photo Attached' : 'Tap to add photo',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.bodyColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Info Notice
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
                        Icons.info_outline,
                        color: AppTheme.emergencyUrl,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your location will be automatically shared with responders upon dispatch.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.emergencyUrl,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Continue Button
                ActionButton(
                  label: 'REVIEW & DISPATCH',
                  isEmergency: true,
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    context.push(
                      '/citizen/dispatch-confirm',
                      extra: {
                        'type': category?['type'] ?? 'SOS',
                        'description': _descriptionController.text.isNotEmpty
                            ? _descriptionController.text
                            : 'Emergency reported',
                        'hasPhoto': _hasPhoto,
                      },
                    );
                  },
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
