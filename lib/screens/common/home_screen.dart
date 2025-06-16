import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/user_model.dart'; // Import UserModel
import 'package:moelung_new/screens/kolektoer/dashboard_screen.dart'; // Import KolektoerDashboardScreen
import 'package:moelung_new/utils/role_utils.dart'; // Import RoleUtils
import 'package:moelung_new/screens/common/article_detail_screen.dart'; // Import ArticleDetailScreen and Article model
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors
import 'package:moelung_new/config/app_routes.dart'; // Import AppRoutes

class HomeScreen extends StatelessWidget {
  final UserModel currentUser; // Add currentUser parameter
  const HomeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    if (isKolektoer(currentUser.role)) {
      return KolektoerDashboardScreen(currentUser: currentUser);
    }

    return AppShell(
      navIndex: 0, // Assuming 0 is the index for home
      user: currentUser, // Use the passed currentUser
      body: Column( // Use Column to stack header and content
        children: [
          PageHeader(
            title: 'Beranda',
            showBackButton: false, // Hide back button
            trailing: Row( // Use a Row for multiple trailing icons
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton( // Notification icon
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.background),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications, arguments: currentUser);
                  },
                ),
                IconButton( // Complaint icon
                  icon: const Icon(Icons.feedback_outlined, color: AppColors.background),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.complaint);
                  },
                ),
              ],
            ),
          ),
          Expanded( // Wrap the rest of the content in Expanded
            child: SingleChildScrollView( // Make content scrollable
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Card
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dark.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('lib/assets/avatar.png'), // Placeholder
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${currentUser.name.split(' ').first}!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Peran: ${currentUser.role.toString().split('.').last}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                'Poin: ${currentUser.points}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.profile, arguments: currentUser);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Point Market Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.pointMarket, arguments: currentUser);
                      },
                      icon: const Icon(Icons.star, color: Colors.white),
                      label: const Text(
                        'Ke Pasar Poin',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Articles Section
                  Text(
                    'Artikel Terbaru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildArticleCard(
                    context,
                    Article(
                      title: 'Pentingnya Daur Ulang',
                      description: 'Cari tahu kenapa daur ulang penting banget buat bumi kita dan gimana kamu bisa bantu.',
                      content: 'Daur ulang itu penting banget buat jaga lingkungan, biar sampah berkurang, sumber daya alam awet, dan polusi gak makin parah. Dengan daur ulang, kita bisa hemat bahan baku baru, jadi energi juga hemat dan emisi gas rumah kaca berkurang. Ini juga bantu ngurangin sampah yang dibuang ke TPA, jadi polusi tanah sama udara juga berkurang. Setiap barang yang didaur ulang itu bantu bikin bumi lebih sehat dan masa depan yang lebih lestari buat anak cucu kita. Yuk, ikutan program daur ulang di daerahmu dan ajak teman-teman juga!',
                      imagePath: 'lib/assets/articles/pentingnya-daur-ulang.png',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildArticleCard(
                    context,
                    Article(
                      title: 'Aksi Bersih-bersih Lingkungan',
                      description: 'Yuk, ikutan acara bersih-bersih lingkungan kita selanjutnya dan bantu jaga lingkungan sekitar tetap hijau.',
                      content: 'Aksi bersih-bersih lingkungan kita nanti itu kesempatan bagus banget buat bikin perubahan nyata di lingkunganmu. Kita ngajak semua warga buat gabung hari Sabtu ini jam 9 pagi di Taman Pusat. Sarung tangan, kantong sampah, sama minuman bakal disediain. Acara ini bukan cuma buat bersih-bersih aja; ini juga buat bangun semangat kebersamaan, ningkatin kesadaran lingkungan, dan kerja bareng buat lingkungan yang lebih bersih dan hijau. Partisipasimu, sekecil apapun, bisa punya dampak besar!',
                      imagePath: 'lib/assets/articles/aksi-bersih-lingkungan.png',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Application Announcements Section
                  Text(
                    'Pengumuman Aplikasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNewsItem(
                    context,
                    'Pembaruan Aplikasi: Fitur Baru Tersedia!',
                    'Kami telah meluncurkan fitur-fitur menarik untuk meningkatkan pengalaman Anda. Periksa sekarang!',
                  ),
                  const SizedBox(height: 8),
                  _buildNewsItem(
                    context,
                    'Perbaikan Kinerja dan Bug',
                    'Pembaruan terbaru mencakup peningkatan kinerja dan perbaikan bug untuk aplikasi yang lebih stabil.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    Article article, // Accept Article object
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.articleDetail,
            arguments: article,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  article.imagePath, // Use article imagePath
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title, // Use article title
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.description, // Use article description
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}
