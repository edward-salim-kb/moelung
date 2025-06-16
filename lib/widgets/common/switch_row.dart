import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.dark),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.dark),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
