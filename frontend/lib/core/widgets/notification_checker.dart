import 'package:flutter/material.dart';
import '../network/network_client.dart';
import '../../main.dart';

class NotificationChecker extends StatefulWidget {
  final Widget child;

  const NotificationChecker({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationChecker> createState() => _NotificationCheckerState();
}

class _NotificationCheckerState extends State<NotificationChecker> {
  @override
  void initState() {
    super.initState();
    _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    try {
      final res = await getIt<NetworkClient>().dio.get('/notifications/queued/');
      final List<dynamic> results = res.data['results'] ?? [];
      
      if (results.isNotEmpty && mounted) {
        for (var notif in results) {
          _showPremiumToast(notif['message'] ?? 'You have a new notification.');
        }
        await getIt<NetworkClient>().dio.post('/notifications/queued/');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  void _showPremiumToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1F2937), // Dark premium color
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        duration: const Duration(seconds: 5),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
