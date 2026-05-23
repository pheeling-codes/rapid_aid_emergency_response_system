import 'package:flutter/material.dart';
import 'dart:convert';
import '../network/network_client.dart'; // Just to resolve getIt, actually let's just import main
import '../../main.dart';
import '../../features/auth/data/token_storage.dart';

class UserProfileAvatar extends StatefulWidget {
  final double radius;
  final IconData defaultIcon;

  const UserProfileAvatar({
    super.key,
    this.radius = 16,
    this.defaultIcon = Icons.person,
  });

  @override
  State<UserProfileAvatar> createState() => _UserProfileAvatarState();
}

class _UserProfileAvatarState extends State<UserProfileAvatar> {
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  void _loadProfileImage() {
    setState(() {
      _base64Image = getIt<TokenStorage>().getProfileImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_base64Image != null && _base64Image!.isNotEmpty) {
      try {
        final base64String = _base64Image!.contains(',')
            ? _base64Image!.split(',').last
            : _base64Image!;
        final bytes = base64Decode(base64String);
        return CircleAvatar(
          radius: widget.radius,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        debugPrint("Error decoding base64 profile image: $e");
      }
    }
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Icon(
        widget.defaultIcon,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        size: widget.radius * 1.25,
      ),
    );
  }
}
