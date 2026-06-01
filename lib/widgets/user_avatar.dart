import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../data/models/app_user.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 32});

  final AppUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
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
