import 'package:flutter/material.dart';
import 'package:moelung_new/utils/app_colors.dart';

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final bool showBackButton;
  final VoidCallback? onNotificationPressed; // New parameter for notification icon

  const PageHeader({
    super.key,
    required this.title,
    this.trailing,
    this.showBackButton = true,
    this.onNotificationPressed, // Initialize new parameter
  });

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
          if (canGoBack && showBackButton) // Conditionally show back button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.background), // White icon for contrast
              onPressed: () => Navigator.pop(context),
            ),
          if (!canGoBack || !showBackButton) const SizedBox(width: 16), // Adjust spacing if no back button
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.background), // White text for contrast
              textAlign: TextAlign.left,
            ),
          ),
          if (onNotificationPressed != null) // Conditionally show notification icon
            IconButton(
              icon: const Icon(Icons.notifications, color: AppColors.background),
              onPressed: onNotificationPressed,
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
