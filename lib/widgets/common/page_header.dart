import 'package:flutter/material.dart';
import 'package:moelung_new/utils/app_colors.dart';

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;

  const PageHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.primary, // Use primary green for header background
        border: Border(bottom: BorderSide(color: AppColors.dark.withOpacity(0.2))), // Softer border
      ),
      child: Row(
        children: [
          if (canGoBack)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.background), // White icon for contrast
              onPressed: () => Navigator.pop(context),
            ),
          if (!canGoBack) const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.background), // White text for contrast
              textAlign: TextAlign.left,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
