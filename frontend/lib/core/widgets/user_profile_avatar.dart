import 'package:flutter/material.dart';
import 'dart:convert';
import '../network/network_client.dart'; // Just to resolve getIt, actually let's just import main
import '../../main.dart';
import '../../features/auth/data/token_storage.dart';

class UserProfileAvatar extends StatelessWidget {
  final double radius;
  final IconData defaultIcon;

  const UserProfileAvatar({
    super.key,
    this.radius = 16,
    this.defaultIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: getIt<TokenStorage>().profileImageNotifier,
      builder: (context, base64Image, child) {
        if (base64Image != null && base64Image.isNotEmpty) {
          try {
            final base64String = base64Image.contains(',')
                ? base64Image.split(',').last
                : base64Image;
            final bytes = base64Decode(base64String);
            return CircleAvatar(
              radius: radius,
              backgroundImage: MemoryImage(bytes),
            );
          } catch (e) {
            debugPrint("Error decoding base64 profile image: $e");
          }
        }
        return CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Icon(
            defaultIcon,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            size: radius * 1.25,
          ),
        );
      },
    );
  }
}
