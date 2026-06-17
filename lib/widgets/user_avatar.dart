import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/image_base64_utils.dart';
import '../data/models/app_user.dart';
import 'base64_image.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 32});

  final AppUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = ImageBase64Utils.isBase64Image(user.fotoBase64);

    if (hasPhoto) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight,
        child: ClipOval(
          child: Base64Image(
            base64: user.fotoBase64,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        user.iniciales,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
