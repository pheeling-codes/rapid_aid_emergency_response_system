import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/theme.dart';

class IncidentDetailsScreen extends StatefulWidget {
  final String incidentType;
  const IncidentDetailsScreen({super.key, required this.incidentType});

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Incident Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Incident Details',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide a brief description or upload a photo to help responders prepare.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Situation Description
            const Text(
              'SITUATION DESCRIPTION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: _placeholder,
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
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
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Evidence
            const Text(
              'EVIDENCE (OPTIONAL)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
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
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasPhoto
                        ? AppColors.success
                        : AppColors.borderColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _hasPhoto
                            ? Icons.check_circle
                            : Icons.add_a_photo_outlined,
                        color: _hasPhoto
                            ? AppColors.success
                            : AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasPhoto ? 'Photo Added' : 'Attach Photo/Video',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _hasPhoto
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Capture or select from gallery',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withOpacity(0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Your location and identity will be shared with the rapid response team to ensure immediate assistance.',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Review Emergency button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(
                    '/dispatch-confirm',
                    extra: {
                      'type': _displayType,
                      'description': _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : 'Two-car collision with visible injuries. Requesting immediate ambulance support.',
                    },
                  );
                },
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text(
                  'Review Emergency',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
