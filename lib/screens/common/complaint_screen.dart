import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/user_model.dart'; // Import UserModel
import 'package:moelung_new/models/enums/user_role.dart'; // Import UserRole
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a dummy UserModel for demonstration
    final dummyUser = UserModel(
      id: '123',
      name: 'Guest User',
      email: 'guest@example.com',
      role: UserRole.penyetoer, // Using a valid penyetoer role
      // Add other required fields for UserModel if any
    );

    return AppShell(
      navIndex: 0, // Assuming 0 is the index for home or a general screen
      user: dummyUser,
      body: Column( // Use Column to stack header and content
        children: [
          const PageHeader(title: 'Portal Pengaduan'), // Add the PageHeader
          Expanded( // Wrap the rest of the content in Expanded
            child: SingleChildScrollView( // Allow scrolling for content
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: AppColors.primary.withOpacity(0.1), // Light primary background
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PENTING: Hak Kepemilikan Sampah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sampah yang telah dipilah dan ditempatkan untuk dikumpulkan adalah properti pribadi pemiliknya. Pengambilan sampah tanpa izin dapat dianggap sebagai pencurian dan melanggar hukum yang berlaku (misalnya, Pasal 362 KUHP tentang Pencurian). Harap patuhi peraturan yang ada untuk menjaga ketertiban dan keadilan bagi semua pihak.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.dark.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Laporkan setiap pelanggaran di sini.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Subjek',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Deskripsi',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle complaint submission
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengaduan Terkirim!'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                        ),
                      );
                    },
                    child: const Text('Kirim Pengaduan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
