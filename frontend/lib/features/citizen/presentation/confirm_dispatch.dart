import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import '../../../main.dart';
import '../../../core/network/network_client.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/ambient_shadow.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConfirmDispatch extends StatefulWidget {
  final String emergencyType;
  final String description;
  final double? latitude;
  final double? longitude;
  final List<XFile>? mediaFiles;

  const ConfirmDispatch({
    super.key,
    required this.emergencyType,
    required this.description,
    this.latitude,
    this.longitude,
    this.mediaFiles,
  });

  @override
  State<ConfirmDispatch> createState() => _ConfirmDispatchState();
}

class _ConfirmDispatchState extends State<ConfirmDispatch> {
  bool _isDispatching = false;
  String _addressLine1 = 'Fetching location...';
  String _addressLine2 = '';

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    if (widget.latitude == null || widget.longitude == null) {
      setState(() {
        _addressLine1 = 'Unknown Location';
      });
      return;
    }
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        setState(() {
          _addressLine1 = '${widget.latitude}, ${widget.longitude}';
        });
        return;
      }
      final dio = Dio();
      final res = await dio.get(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'latlng': '${widget.latitude},${widget.longitude}',
            'key': apiKey,
          });
      if (res.statusCode == 200 && res.data['status'] == 'OK') {
        final results = res.data['results'] as List;
        if (results.isNotEmpty) {
          final components = results.first['address_components'] as List;
          String streetName = '';
          String locality = '';
          String adminArea = '';
          String country = '';
          for (var c in components) {
            final types = c['types'] as List;
            if (types.contains('route')) {
              streetName = c['long_name'];
            } else if (types.contains('neighborhood') && streetName.isEmpty) {
              streetName = c['long_name'];
            } else if (types.contains('sublocality') && streetName.isEmpty) {
              streetName = c['long_name'];
            } else if (types.contains('sublocality_level_1') &&
                streetName.isEmpty) {
              streetName = c['long_name'];
            } else if (types.contains('administrative_area_level_3') &&
                streetName.isEmpty) {
              streetName = c['long_name'];
            }
            if (types.contains('locality')) locality = c['long_name'];
            if (types.contains('administrative_area_level_1')) {
              adminArea = c['long_name'];
            }
            if (types.contains('country')) country = c['long_name'];
          }
          final formatted = results.first['formatted_address'] as String;

          if (streetName.isEmpty || streetName.contains('+')) {
            final parts = formatted.split(',');
            if (parts.isNotEmpty) {
              String firstPart = parts[0].trim();
              if (firstPart.contains('+')) {
                final spaceIdx = firstPart.indexOf(' ');
                if (spaceIdx != -1 && spaceIdx < firstPart.length - 1) {
                  firstPart = firstPart.substring(spaceIdx + 1).trim();
                } else if (parts.length > 1) {
                  firstPart = parts[1].trim();
                }
              }
              streetName = firstPart;
            }
          }

          setState(() {
            _addressLine1 = [
              if (streetName.isNotEmpty) streetName,
              if (locality.isNotEmpty && locality != streetName) locality
            ].join(', ');
            
            if (_addressLine1.isEmpty) _addressLine1 = 'Unknown Location';

            _addressLine2 = [
              if (adminArea.isNotEmpty) adminArea,
              if (country.isNotEmpty) country
            ].join(', ');
          });
        }
      } else {
        setState(() {
          _addressLine1 = '${widget.latitude}, ${widget.longitude}';
        });
      }
    } catch (_) {
      setState(() {
        _addressLine1 = '${widget.latitude}, ${widget.longitude}';
      });
    }
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

  Future<void> _submitIncident() async {
    setState(() => _isDispatching = true);
    try {
      final dio = getIt<NetworkClient>().dio;
      final Map<String, dynamic> data = {
        'title': 'Emergency: ${widget.emergencyType}',
        'description': widget.description,
        'category': widget.emergencyType.toUpperCase() == 'SECURITY' ? 'CRIME' : widget.emergencyType.toUpperCase(),
        'severity': 'HIGH',
        'address': [
          _addressLine1, 
          if (_addressLine2.isNotEmpty) _addressLine2
        ].join(', ').trim(),
      };

      if (widget.latitude != null && widget.longitude != null) {
        data['latitude'] = widget.latitude!;
        data['longitude'] = widget.longitude!;
      }

      if (widget.mediaFiles != null && widget.mediaFiles!.isNotEmpty) {
        List<String> base64Images = [];
        for (var file in widget.mediaFiles!) {
          final bytes = await file.readAsBytes();
          final base64Str = base64Encode(bytes);
          // Prepend data URL scheme if needed or just send base64
          base64Images.add('data:${file.mimeType ?? 'image/jpeg'};base64,$base64Str');
        }
        data['evidences'] = base64Images;
      }

      await dio.post('/incidents/create/', data: data);

      if (mounted) {
        context.go('/citizen/dashboard');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Emergency dispatched successfully.'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDispatching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to dispatch: $e'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
            // Custom Topbar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: cs.onSurface.withOpacity(0.7)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Text(
                    'RAPID AID',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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

            const SizedBox(height: 6),

            // Map and Content Area
            Expanded(
              child: Stack(
                children: [
                  // Background Map
                  Positioned.fill(
                    child: widget.latitude != null && widget.longitude != null
                        ? GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target:
                                  LatLng(widget.latitude!, widget.longitude!),
                              zoom: 16.0,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('emergency_location'),
                                position:
                                    LatLng(widget.latitude!, widget.longitude!),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed),
                              )
                            },
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                          )
                        : Container(
                            color: Colors
                                .blue.shade600, // Placeholder color for Map
                            child: Stack(
                              children: [
                                // Map Graphic placeholder overlay
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.blue.shade400.withOpacity(0.5),
                                  ),
                                ),
                                // Mock map pin
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 3),
                                        ),
                                        child: const Icon(Icons.emergency,
                                            color: Colors.white, size: 24),
                                      ),
                                      Container(
                                        width: 4,
                                        height: 16,
                                        color: AppTheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  // GPS Fix Pill
                  Positioned(
                    top: 16.0,
                    left: 24.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'GPS FIX: HIGH ACCURACY',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom content card
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.15), // Dynamically push down map
                            // Content Card overlapping map
                            Container(
                              width: double.infinity,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: AppTheme.emergencyUrl
                                              .withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(
                                              widget.emergencyType),
                                          color: AppTheme.emergencyUrl,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Incident: ${widget.emergencyType}',
                                                  style: theme
                                                      .textTheme.titleLarge
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    height: 1.2,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 6.0),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.emergencyUrl
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                  ),
                                                  child: Text(
                                                    'URGENT',
                                                    style: theme
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                      color:
                                                          AppTheme.emergencyUrl,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'REF ID: RA-992-01',
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                color: cs.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Location Details
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.location_on,
                                          color: cs.primary, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'LOCATION',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: cs.onSurface
                                                    .withOpacity(0.5),
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _addressLine1,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (_addressLine2.isNotEmpty)
                                              Text(
                                                _addressLine2,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: cs.onSurface
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Description Details
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.description,
                                          color: cs.primary, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'DESCRIPTION',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: cs.onSurface
                                                    .withOpacity(0.5),
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.description.isNotEmpty
                                                  ? '"${widget.description}"'
                                                  : '"No description provided."',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: cs.onSurface
                                                    .withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Evidence Files
                                  if (widget.mediaFiles != null &&
                                      widget.mediaFiles!.isNotEmpty) ...[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.attachment,
                                            color: cs.primary, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'EVIDENCE',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: cs.onSurface
                                                      .withOpacity(0.5),
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: widget.mediaFiles!
                                                    .map((file) {
                                                  return Container(
                                                    width: 64,
                                                    height: 64,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.black12,
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: kIsWeb
                                                        ? Image.network(
                                                            file.path,
                                                            fit: BoxFit.cover)
                                                        : const Icon(Icons
                                                            .insert_drive_file),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // Pre-allocated Responder Status
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade500,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Responder pre-allocated',
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                color: cs.onSurface
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'ETA: 6 MINS',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Big Confirm & Dispatch Button
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: InkWell(
                                onTap: _isDispatching ? null : _submitIncident,
                                borderRadius: BorderRadius.circular(24.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  decoration: BoxDecoration(
                                    color: _isDispatching
                                        ? Colors.grey
                                        : AppTheme.emergencyUrl,
                                    borderRadius: BorderRadius.circular(24.0),
                                    boxShadow: [
                                      if (!_isDispatching)
                                        BoxShadow(
                                          color: AppTheme.emergencyUrl
                                              .withOpacity(0.4),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isDispatching)
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5),
                                        )
                                      else ...[
                                        const Icon(Icons.notifications_active,
                                            color: Colors.white, size: 24),
                                        const SizedBox(width: 12),
                                        Text(
                                          'CONFIRM & DISPATCH',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Safety Disclaimer
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Colors.orange.shade700,
                                        size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color:
                                                cs.onSurface.withOpacity(0.8),
                                            height: 1.4,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Safety Disclaimer: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: cs.onSurface),
                                            ),
                                            const TextSpan(
                                              text:
                                                  'False reports are subject to legal penalties under the Emergency Services Act. Help is being pre-allocated to your verified location.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ), // <-- Closes Positioned.fill
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
