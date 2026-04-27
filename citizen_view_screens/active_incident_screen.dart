import 'package:flutter/material.dart';
import '/core/theme.dart';

class IncidentActiveScreen extends StatelessWidget {
  const IncidentActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: const Text(
          'INCIDENT ACTIVE',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFF7EC8E3),
                  child: CustomPaint(
                    painter: _NorthAmericaMapPainter(),
                    child: Container(),
                  ),
                ),
                // Responder en route banner
                Positioned(
                  top: 16,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'RESPONDER EN ROUTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Incident pin
                Positioned(
                  top: 80,
                  right: 140,
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Container(width: 2, height: 14, color: AppColors.accent),
                    ],
                  ),
                ),
                // User dot
                const Positioned(
                  top: 140,
                  left: 100,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Live Activity
          Expanded(
            child: Container(
              color: AppColors.white,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Live Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ACTIVE DISPATCH',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timeline events
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: const [
                        _TimelineEvent(
                          time: '14:02',
                          title: 'Dispatch Confirmed',
                          subtitle: null,
                          isActive: false,
                          isUrgent: false,
                        ),
                        _TimelineEvent(
                          time: '14:03',
                          title: 'Unit 402 Departing Station',
                          subtitle:
                              'First responder unit assigned and clear for departure.',
                          isActive: false,
                          isUrgent: false,
                        ),
                        _TimelineEvent(
                          time: '14:05',
                          title: 'En route: Traffic on Third Mainland Bridge.',
                          subtitle:
                              'ETA adjusted. Responder maintains communication.',
                          isActive: true,
                          isUrgent: true,
                        ),
                      ],
                    ),
                  ),

                  // Call Responder button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text(
                          'CALL RESPONDER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 1.0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  final String time;
  final String title;
  final String? subtitle;
  final bool isActive;
  final bool isUrgent;

  const _TimelineEvent({
    required this.time,
    required this.title,
    this.subtitle,
    required this.isActive,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isUrgent ? AppColors.accent : AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              if (subtitle != null || !isUrgent)
                Container(width: 2, height: 50, color: AppColors.divider),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isUrgent ? AppColors.accent : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.accent : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isUrgent
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isUrgent
                                ? Colors.white.withOpacity(0.85)
                                : AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
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

class _NorthAmericaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF90C8A0)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Simplified North America shape
    path.moveTo(size.width * 0.15, size.height * 0.1);
    path.lineTo(size.width * 0.75, size.height * 0.08);
    path.lineTo(size.width * 0.85, size.height * 0.2);
    path.lineTo(size.width * 0.82, size.height * 0.55);
    path.lineTo(size.width * 0.65, size.height * 0.72);
    path.lineTo(size.width * 0.55, size.height * 0.85);
    path.lineTo(size.width * 0.45, size.height * 0.9);
    path.lineTo(size.width * 0.35, size.height * 0.75);
    path.lineTo(size.width * 0.18, size.height * 0.7);
    path.lineTo(size.width * 0.1, size.height * 0.5);
    path.lineTo(size.width * 0.12, size.height * 0.25);
    path.close();
    canvas.drawPath(path, paint);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
