import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/user_model.dart'; // Import UserModel
import 'package:moelung_new/models/enums/user_role.dart'; // Import UserRole
import 'package:moelung_new/screens/common/complaint_screen.dart'; // Import ComplaintScreen
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors
import 'package:moelung_new/config/app_routes.dart'; // Import AppRoutes

class HomeScreen extends StatelessWidget {
  final UserModel currentUser; // Add currentUser parameter
  const HomeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
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
                    'The Importance of Recycling',
                    'Discover why recycling is crucial for our planet and how you can make a difference.',
                    'lib/assets/edu1.png', // Example image
                  ),
                  const SizedBox(height: 12),
                  _buildArticleCard(
                    context,
                    'Community Clean-up Drive',
                    'Join our next community clean-up event and help keep our neighborhoods green.',
                    'lib/assets/edu1.png', // Example image
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
    String title,
    String description,
    String imagePath,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to article detail page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Read more about "$title"')),
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
                  imagePath,
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
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
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
