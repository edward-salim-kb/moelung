import 'package:flutter/material.dart';
import 'package:moelung_new/utils/app_colors.dart';

class KumpoelDrawer extends StatelessWidget {
  const KumpoelDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder:
          (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: ListView(
              controller: controller,
              children: const [
                Center(
                  child: Text(
                    'Kumpoel mode active!',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
