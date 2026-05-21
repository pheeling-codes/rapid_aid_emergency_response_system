import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Column(
        children: [
          // ── Top App Bar ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: cs.onSurface.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Rapid Aid: Command Center',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 48),
                // Search Bar
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search incidents, units...',
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(Icons.search,
                            size: 18, color: cs.onSurface.withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(top: -4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
                // System Status
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981), // Green
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SYSTEM OPERATIONAL: NORMAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Profile Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.onSurface.withOpacity(0.1), width: 2),
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

          // ── Map & Overlays ────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Simulated Map Background
                Container(
                  color: const Color(0xFFE5E7EB), // Light gray map bg
                  child: CustomPaint(
                    painter: _AdminMapPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),

                // ── Left Overlay: Active Incidents ──────────────────────────
                Positioned(
                  top: 24,
                  left: 24,
                  bottom: 24,
                  width: 320,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE INCIDENTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _IncidentCard(
                              type: 'CRITICAL AID',
                              typeColor: const Color(0xFFDC2626),
                              title: 'Cardiac Arrest',
                              address: '402 W 51st St, New York',
                              time: '2m ago',
                            ),
                            const SizedBox(height: 12),
                            _IncidentCard(
                              type: 'RESPIRATORY',
                              typeColor: const Color(0xFFF59E0B),
                              title: 'Difficulty Breathing',
                              address: '128 8th Ave, New York',
                              time: '8m ago',
                            ),
                            const SizedBox(height: 12),
                            _IncidentCard(
                              type: 'TRANSPORT',
                              typeColor: const Color(0xFF3B82F6),
                              title: 'Non-Emergency Transfer',
                              address: 'Metropolitan Hospital Center',
                              time: '15m ago',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right Overlay: Nearest Responders ────────────────────────
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: 380,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(-4, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected Incident Details
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2), // Light red bg
                            border: Border(bottom: BorderSide(color: cs.onSurface.withOpacity(0.05))),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDC2626),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.monitor_heart, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PRIORITY 1 CRITICAL',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: const Color(0xFFDC2626),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Text(
                                        'Cardiac Arrest',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.headingColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '402 W 51st St, New York, NY 10019',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF4B5563),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reported by Jane Doe (Bystander)',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF4B5563),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '"Patient collapsed in pharmacy. Unresponsive. Bystander started CPR."',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Nearest Responders List
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              Text(
                                'NEAREST RESPONDERS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.5),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _UnitCard(
                                name: 'Unit 7A (ALS)',
                                distance: '0.8 mi',
                                eta: 'ETA: 3 mins',
                                isSelected: true,
                              ),
                              const SizedBox(height: 12),
                              _UnitCard(
                                name: 'Unit 12B (BLS)',
                                distance: '1.4 mi',
                                eta: 'ETA: 6 mins',
                              ),
                              const SizedBox(height: 12),
                              _UnitCard(
                                name: 'Rapid Response 4',
                                distance: '2.1 mi',
                                eta: 'ETA: 8 mins',
                              ),
                            ],
                          ),
                        ),

                        // Dispatch Button
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626), // Red
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'DISPATCH UNIT 7A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom Metrics ───────────────────────────────────────────
                Positioned(
                  bottom: 24,
                  right: 400, // Left of the right panel
                  child: Row(
                    children: [
                      _MetricCard(title: 'ACTIVE UNITS', value: '12', subValue: ' / 14'),
                      const SizedBox(width: 16),
                      _MetricCard(title: 'RESPONSE TIME', value: '4.2', subValue: ' min avg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _IncidentCard extends StatelessWidget {
  final String type;
  final Color typeColor;
  final String title;
  final String address;
  final String time;

  const _IncidentCard({
    required this.type,
    required this.typeColor,
    required this.title,
    required this.address,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isCritical = type == 'CRITICAL AID';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCritical ? Border.all(color: typeColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.headingColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: cs.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // View Details Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  'VIEW DETAILS',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppTheme.headingColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final String name;
  final String distance;
  final String eta;
  final bool isSelected;

  const _UnitCard({
    required this.name,
    required this.distance,
    required this.eta,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF3B82F6) : cs.onSurface.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.directions_car_filled_rounded, 
                color: isSelected ? Colors.white : const Color(0xFF4B5563), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.headingColor,
                      ),
                    ),
                    Text(
                      distance,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$eta • Status: Available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subValue;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.headingColor,
                ),
              ),
              Text(
                subValue,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: title == 'ACTIVE UNITS' ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Light grey background
    final bgPaint = Paint()..color = const Color(0xFFE5E7EB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Thick roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final minorRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Draw grid of minor roads
    for (double x = 40; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorRoadPaint);
    }
    for (double y = 40; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorRoadPaint);
    }

    // Draw major arterial roads
    final mainPath1 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
          size.width * 0.4, size.height * 0.5, size.width, size.height * 0.3);
    canvas.drawPath(mainPath1, roadPaint);

    final mainPath2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(mainPath2, roadPaint);

    // Draw some blocks / buildings
    final blockPaint = Paint()..color = const Color(0xFFD1D5DB).withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.5, 40, 60), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.65, size.height * 0.5, 30, 40), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, size.height * 0.7, 80, 40), blockPaint);
    
    // Draw Incident Pin (Red asterisk equivalent)
    final redPinPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final cx = size.width * 0.6;
    final cy = size.height * 0.4;
    canvas.drawLine(Offset(cx - 10, cy - 10), Offset(cx + 10, cy + 10), redPinPaint);
    canvas.drawLine(Offset(cx + 10, cy - 10), Offset(cx - 10, cy + 10), redPinPaint);
    canvas.drawLine(Offset(cx, cy - 14), Offset(cx, cy + 14), redPinPaint);
    canvas.drawLine(Offset(cx - 14, cy), Offset(cx + 14, cy), redPinPaint);

    // Draw Unit Pins (Blue arrows)
    final bluePinPaint = Paint()..color = const Color(0xFF3B82F6);
    
    void drawUnit(double x, double y) {
      final path = Path()
        ..moveTo(x, y - 8)
        ..lineTo(x + 8, y + 12)
        ..lineTo(x, y + 6)
        ..lineTo(x - 8, y + 12)
        ..close();
      canvas.drawPath(path, bluePinPaint);
    }
    
    drawUnit(size.width * 0.45, size.height * 0.35);
    drawUnit(size.width * 0.35, size.height * 0.75);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
