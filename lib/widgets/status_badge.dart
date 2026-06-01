import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../data/models/contract_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ContractStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      ContractStatus.activo => (AppColors.success, AppColors.successLight),
      ContractStatus.porVencer => (AppColors.warning, AppColors.warningLight),
      ContractStatus.finalizado => (AppColors.textSecondary, AppColors.divider),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
