import 'package:flutter/material.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:moelung_new/providers/accessibility_provider.dart'; // Import AccessibilityProvider

class AccessibilitySettingsScreen extends StatelessWidget {
  final UserModel currentUser;

  const AccessibilitySettingsScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const PageHeader(title: 'Pengaturan Aksesibilitas'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<AccessibilityProvider>(
                builder: (context, accessibilityProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${currentUser.name}!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Sesuaikan pengaturan aksesibilitas untuk pengalaman yang lebih baik.',
                        style: TextStyle(fontSize: 16, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 30),

                      // Font Size Adjustment
                      Text(
                        'Ukuran Font: ${accessibilityProvider.fontSizeScale.toStringAsFixed(1)}x',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                      ),
                      Slider(
                        value: accessibilityProvider.fontSizeScale,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        label: accessibilityProvider.fontSizeScale.toStringAsFixed(1),
                        onChanged: (newValue) {
                          accessibilityProvider.setFontSizeScale(newValue);
                        },
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.lightGrey,
                      ),
                      const SizedBox(height: 20),

                      // High Contrast Mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mode Kontras Tinggi',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                          ),
                          Switch(
                            value: accessibilityProvider.highContrastMode,
                            onChanged: (newValue) {
                              accessibilityProvider.setHighContrastMode(newValue);
                            },
                            activeColor: AppColors.primary,
                            inactiveThumbColor: AppColors.secondary,
                            inactiveTrackColor: AppColors.lightGrey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Save Settings Button (No longer dummy, changes are applied immediately)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Changes are applied immediately via notifyListeners in provider
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pengaturan aksesibilitas disimpan!'),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                              ),
                            );
                          },
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Simpan Pengaturan', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: const TextStyle(fontSize: 18),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
