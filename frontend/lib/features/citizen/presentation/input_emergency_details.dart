import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/user_profile_avatar.dart';
import '../../../core/widgets/ambient_shadow.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'package:universal_html/html.dart' as html;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/location_service.dart';

class InputEmergencyDetails extends StatefulWidget {
  final String emergencyType;

  const InputEmergencyDetails({
    super.key,
    required this.emergencyType,
  });

  @override
  State<InputEmergencyDetails> createState() => _InputEmergencyDetailsState();
}

class _InputEmergencyDetailsState extends State<InputEmergencyDetails> {
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String _errorMessage = '';

  final ImagePicker _picker = ImagePicker();
  List<XFile> _evidenceFiles = [];
  int _totalEvidenceSizeInBytes = 0;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medical':
        return Icons.medical_services;
      case 'fire':
        return Icons.local_fire_department;
      case 'accident':
        return Icons.car_crash;
      case 'security':
        return Icons.security;
      default:
        return Icons.emergency;
    }
  }

  void _showErrorToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color(0xFFDC2626), // Emergency Red
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600))),
          ],
        )));
  }

  Future<void> _pickMedia() async {
    if (_evidenceFiles.length >= 4) {
      _showErrorToast('Maximum of 4 evidence files allowed.');
      return;
    }

    try {
      final List<XFile> selected = await _picker.pickMultiImage();
      if (selected.isEmpty) return;

      List<XFile> validFiles = [];
      for (var file in selected) {
        final length = await file.length();
        if (length > 5 * 1024 * 1024) {
          // 5MB
          _showErrorToast('File ${file.name} exceeds 5MB limit.');
          continue;
        }
        validFiles.add(file);
      }

      int slotsAvailable = 4 - _evidenceFiles.length;
      List<XFile> validFilesToTake = validFiles.take(slotsAvailable).toList();

      int additionalSize = 0;
      for (var f in validFilesToTake) {
        additionalSize += await f.length();
      }

      setState(() {
        if (_evidenceFiles.length + validFiles.length > 4) {
          _showErrorToast('Maximum of 4 evidence files allowed.');
        }
        _evidenceFiles.addAll(validFilesToTake);
        _totalEvidenceSizeInBytes += additionalSize;
      });
    } catch (e) {
      _showErrorToast('Failed to pick media: $e');
    }
  }

  void _removeFile(XFile file) async {
    final length = await file.length();
    setState(() {
      _evidenceFiles.remove(file);
      _totalEvidenceSizeInBytes -= length;
    });
  }

  Future<void> _validateAndProceed() async {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      setState(() =>
          _errorMessage = 'Please provide a brief situation description.');
      return;
    }
    if (text.length < 10) {
      setState(() => _errorMessage =
          'Please provide more details (at least 10 characters).');
      return;
    }
    setState(() => _errorMessage = '');

    setState(() => _isLocating = true);

    try {
      Position? position = await LocationService().getCurrentPosition();
      if (position == null) {
        throw Exception('Could not determine current location.');
      }

      if (mounted) {
        setState(() => _isLocating = false);
        context.push('/citizen/dispatch-confirm', extra: {
          'type': widget.emergencyType,
          'description': text,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'mediaFiles': _evidenceFiles,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocating = false);
        _showErrorToast('Failed to get location: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: cs.onSurface.withOpacity(0.7)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    'Incident Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: cs.surfaceContainerHigh, width: 2),
                    ),
                    child: const UserProfileAvatar(radius: 16),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Incident Details',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Provide a brief description or upload a photo to help responders prepare.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(widget.emergencyType),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SELECTED CATEGORY',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.emergencyType.toUpperCase(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.check_circle, color: AppTheme.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'SITUATION DESCRIPTION',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: _errorMessage.isNotEmpty
                              ? AppTheme.emergencyUrl
                              : (_isFocused ? cs.primary : Colors.transparent),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _descriptionController,
                            focusNode: _focusNode,
                            maxLines: 5,
                            maxLength: 500,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: cs.onSurface,
                            ),
                            onChanged: (_) {
                              if (_errorMessage.isNotEmpty) {
                                setState(() => _errorMessage = '');
                              }
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Describe the situation (e.g., "Two-car collision on Third Mainland Bridge").',
                              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                color: cs.onSurface.withOpacity(0.4),
                                height: 1.5,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16.0),
                              counterText:
                                  '', 
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 16.0, bottom: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedBuilder(
                                  animation: _descriptionController,
                                  builder: (context, _) {
                                    return Text(
                                      '${_descriptionController.text.length} / 500',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.4),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          _errorMessage,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppTheme.emergencyUrl,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    Text(
                      'EVIDENCE (OPTIONAL)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: cs.onSurface.withOpacity(0.15),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ..._evidenceFiles.map((file) {
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.black12,
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: kIsWeb
                                            ? Image.network(file.path,
                                                fit: BoxFit.cover)
                                            : const Icon(Icons.insert_drive_file),
                                      ),
                                      Positioned(
                                        right: -8,
                                        top: -8,
                                        child: InkWell(
                                          onTap: () => _removeFile(file),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                if (_evidenceFiles.length < 4)
                                  InkWell(
                                    onTap: _pickMedia,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: cs.primary.withOpacity(0.3),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                        color: cs.primary.withOpacity(0.05),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.add_photo_alternate,
                                            color: cs.primary, size: 32),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Only images are allowed (No video). Max 4 images.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                            ),
                            if (_evidenceFiles.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${(_totalEvidenceSizeInBytes / (1024 * 1024)).toStringAsFixed(2)}MB / 5.00MB used',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    InkWell(
                      onTap: _validateAndProceed,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        decoration: BoxDecoration(
                          color: AppTheme.emergencyUrl,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLocating)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            else ...[
                              const Icon(Icons.location_on,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Review Emergency',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Disclaimer
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.emergencyUrl.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info,
                              color: AppTheme.emergencyUrl, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your location and identity will be shared with the rapid response team to ensure immediate assistance.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.emergencyUrl.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    path.addRRect(rrect);

    // Simple dash effect
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0.0;

    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        final extractPath =
            measurePath.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
      distance = 0.0; // Reset for next subpath
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
