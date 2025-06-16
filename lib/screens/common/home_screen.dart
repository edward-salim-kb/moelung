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
            title: 'Home',
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
                                'Hello, ${currentUser.name.split(' ').first}!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Role: ${currentUser.role.toString().split('.').last}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                'Points: ${currentUser.points}',
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
                        'Go to Point Market',
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
                    'Latest Articles',
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
                      title: 'The Importance of Recycling',
                      description: 'Discover why recycling is crucial for our planet and how you can make a difference.',
                      content: 'Recycling plays a vital role in environmental protection by reducing waste, conserving natural resources, and preventing pollution. By recycling, we can lessen the need for new raw materials, which in turn saves energy and reduces greenhouse gas emissions. It also helps in minimizing the amount of waste sent to landfills, thereby reducing land and air pollution. Every recycled item contributes to a healthier planet and a more sustainable future for generations to come. Get involved in local recycling programs and encourage others to participate!',
                      imagePath: 'lib/assets/edu1.png', // Example image
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildArticleCard(
                    context,
                    Article(
                      title: 'Community Clean-up Drive',
                      description: 'Join our next community clean-up event and help keep our neighborhoods green.',
                      content: 'Our upcoming community clean-up drive is a fantastic opportunity to make a tangible difference in your local environment. We invite all community members to join us this Saturday at 9 AM in Central Park. Gloves, bags, and refreshments will be provided. This event is not just about cleaning; it\'s about fostering community spirit, raising environmental awareness, and working together for a cleaner, greener neighborhood. Your participation, no matter how small, can have a huge impact!',
                      imagePath: 'lib/assets/edu1.png', // Example image
                    ),
                  ),
                  const SizedBox(height: 24),

                  // News Section
                  Text(
                    'Recent News',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNewsItem(
                    context,
                    'New Recycling Initiative Launched in Jakarta',
                    'A new program aims to boost recycling rates in urban areas.',
                  ),
                  const SizedBox(height: 8),
                  _buildNewsItem(
                    context,
                    'Pemulung Recognized for Environmental Efforts',
                    'Local recyclers are celebrated for their vital contribution to sustainability.',
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
