import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/ambient_shadow.dart';

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

  void _validateAndProceed() {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please provide a brief situation description.';
      });
      return;
    }
    if (text.length < 10) {
      setState(() {
        _errorMessage = 'Please provide more details (at least 10 characters).';
      });
      return;
    }
    setState(() {
      _errorMessage = '';
    });
    context.push('/citizen/dispatch-confirm', extra: {
      'type': widget.emergencyType,
      'description': text,
    });
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
            // Fixed Custom Topbar
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
                      color: cs.onSurface,
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
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.surfaceContainerLow,
                      child: Icon(Icons.person,
                          color: cs.onSurface.withOpacity(0.7), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
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

                    // Category Card Prefilled
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

                    // Description Input Box
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
                                  '', // We hide default counter to build custom one
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

                    // Evidence Upload Box (Dashed style via custom painter or simple container)
                    CustomPaint(
                      painter: _DashedRectPainter(
                          color: cs.onSurface.withOpacity(0.15)),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () {
                              // Media selection logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Media upload functionality coming soon.'),
                                  backgroundColor: cs.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: cs.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Attach Photo/Video',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Capture or select from gallery',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: cs.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
