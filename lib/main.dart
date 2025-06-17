import 'package:flutter/material.dart';
import 'package:moelung_new/config/app_routes.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/screens/penyetoer/trash_screen.dart';
import 'package:moelung_new/screens/penyetoer/leaderboard_screen.dart';
import 'package:moelung_new/screens/penyetoer/point_market_screen.dart';
import 'package:moelung_new/widgets/common/tikoem_map.dart';
import 'package:moelung_new/screens/auth/login_screen.dart';
import 'package:moelung_new/screens/auth/register_screen.dart';
import 'package:moelung_new/screens/common/home_screen.dart'; // Import HomeScreen
import 'package:moelung_new/screens/common/complaint_screen.dart'; // Import ComplaintScreen
import 'package:moelung_new/screens/kolektoer/dashboard_screen.dart'; // Import DashboardScreen
import 'package:moelung_new/screens/kolektoer/kolektoer_trash_screen.dart'; // Import KolektoerTrashScreen
import 'package:moelung_new/screens/penyetoer/education_screen.dart'; // Import EducationScreen
import 'package:moelung_new/screens/common/profile_screen.dart'; // Import ProfileScreen
import 'package:moelung_new/screens/common/notification_screen.dart'; // Import NotificationScreen
import 'package:moelung_new/screens/common/article_detail_screen.dart'; // Import ArticleDetailScreen and Article model
import 'package:moelung_new/screens/kolektoer/pickup_service_screen.dart'; // Import KolektoerPickupServiceScreen
import 'package:moelung_new/screens/penyetoer/jempoet_request_screen.dart'; // Import JempoetRequestScreen
import 'package:moelung_new/screens/penyetoer/kumpoel_jempoet_screen.dart'; // Import KumpoelJempoetScreen
import 'package:moelung_new/screens/common/edit_profile_screen.dart'; // Import EditProfileScreen
import 'package:moelung_new/screens/common/accessibility_settings_screen.dart'; // Import AccessibilitySettingsScreen
import 'package:moelung_new/screens/common/terms_of_service_screen.dart'; // Import TermsOfServiceScreen
import 'package:moelung_new/screens/common/privacy_policy_screen.dart'; // Import PrivacyPolicyScreen
import 'package:moelung_new/models/enums/user_role.dart'; // Import UserRole enum
import 'package:moelung_new/utils/role_utils.dart'; // Import RoleUtils
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import 'package:provider/provider.dart'; // Import provider
import 'package:moelung_new/providers/accessibility_provider.dart'; // Import AccessibilityProvider
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors for high contrast theme

import 'package:moelung_new/services/pickup_service.dart'; // Import PickupService
import 'package:moelung_new/models/enums/service_type.dart'; // Import ServiceType
import 'package:moelung_new/screens/onboarding/splash_screen.dart'; // Import SplashScreen
import 'package:moelung_new/screens/onboarding/intro_screen.dart'; // Import IntroScreen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => PickupService()), // Add PickupService
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibilityProvider, child) {
        final baseTheme = ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.rubikTextTheme(
            Theme.of(context).textTheme,
          ),
        );

        final highContrastTheme = baseTheme.copyWith(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: baseTheme.appBarTheme.copyWith(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          textTheme: baseTheme.textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: AppColors.accent,
            cardColor: Colors.grey[900],
            backgroundColor: Colors.black,
            errorColor: Colors.redAccent,
          ).copyWith(
            secondary: Colors.white, // Ensure contrast for secondary elements
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, // Text color for buttons
              backgroundColor: Colors.white, // Button background
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text color for text buttons
            ),
          ),
          // Add more high contrast adjustments as needed
        );

        return MaterialApp(
          title: 'Moelung New',
          debugShowCheckedModeBanner: false, // Remove debug banner
          theme: accessibilityProvider.highContrastMode ? highContrastTheme : baseTheme,
          initialRoute: AppRoutes.splash, // Set initial route to splash
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(accessibilityProvider.fontSizeScale),
              ),
              child: child!,
            );
          },
          onGenerateRoute: (settings) {
            // Determine the current user based on arguments, or use a default for testing
            // This logic ensures that if a user is passed (e.g., from login), it's used.
            // Otherwise, a default user is provided for routes that need one.
            final UserModel currentUser;
            if (settings.arguments is UserModel) {
              currentUser = settings.arguments as UserModel;
            } else {
              // Default to Penyetoer for most cases, Kolektoer for specific Kolektoer routes
              if (settings.name == AppRoutes.pickupService || settings.name == AppRoutes.dashboard) {
                currentUser = UserModel(id: 'kolektoer_id_default', name: 'Siti Rahayu', email: 'siti.rahayu@example.com', role: UserRole.kolektoer);
              } else {
                currentUser = UserModel(id: 'penyetoer_id_default', name: 'Budi Santoso', email: 'budi.santoso@example.com', role: UserRole.penyetoer);
              }
            }

            Widget screen;

            switch (settings.name) {
              case AppRoutes.splash:
                screen = const SplashScreen();
                break;
              case AppRoutes.intro:
                screen = const IntroScreen();
                break;
              case AppRoutes.login:
                screen = const LoginScreen();
                break;
              case AppRoutes.register:
                screen = const RegisterScreen();
                break;
              case AppRoutes.home:
                if (isKolektoer(currentUser.role)) {
                  screen = KolektoerPickupServiceScreen(currentUser: currentUser);
                } else {
                  screen = HomeScreen(currentUser: currentUser);
                }
                break;
              case AppRoutes.complaint:
                screen = const ComplaintScreen();
                break;
              case AppRoutes.trash:
                if (isKolektoer(currentUser.role)) {
                  screen = KolektoerTrashScreen(currentUser: currentUser);
                } else {
                  screen = TrashScreen(currentUser: currentUser);
                }
                break;
              case AppRoutes.leaderboard:
                screen = LeaderboardScreen(currentUser: currentUser);
                break;
              case AppRoutes.profile:
                screen = ProfileScreen(currentUser: currentUser);
                break;
              case AppRoutes.pointMarket:
                screen = PointMarketScreen(currentUser: currentUser);
                break;
              case AppRoutes.map:
                screen = TikoemMap();
                break;
              case AppRoutes.education:
                screen = EducationScreen(currentUser: currentUser);
                break;
              case AppRoutes.notifications:
                screen = NotificationScreen(currentUser: currentUser);
                break;
              case AppRoutes.articleDetail:
                screen = ArticleDetailScreen(article: settings.arguments as Article);
                break;
              case AppRoutes.pickupService:
                screen = KolektoerPickupServiceScreen(currentUser: currentUser);
                break;
              case AppRoutes.dashboard:
                screen = KolektoerDashboardScreen(currentUser: currentUser);
                break;
              case AppRoutes.jempoetRequest:
                screen = JempoetRequestScreen(currentUser: currentUser);
                break;
              case AppRoutes.kumpoelJempoet:
                final args = settings.arguments as Map<String, dynamic>?;
                screen = KumpoelJempoetScreen(
                  currentUser: currentUser,
                  initialServiceType: args?['initialServiceType'] as ServiceType?,
                );
                break;
              case AppRoutes.editProfile:
                screen = EditProfileScreen(currentUser: currentUser);
                break;
              case AppRoutes.accessibilitySettings:
                screen = AccessibilitySettingsScreen(currentUser: currentUser);
                break;
              case AppRoutes.termsOfService:
                screen = TermsOfServiceScreen(currentUser: currentUser);
                break;
              case AppRoutes.privacyPolicy:
                screen = PrivacyPolicyScreen(currentUser: currentUser);
                break;
              default:
                return MaterialPageRoute(builder: (context) => const Text('Error: Unknown route'));
            }
            // For bottom navigation routes, use PageRouteBuilder to remove transition animation
            if ([
              AppRoutes.home,
              AppRoutes.trash,
              AppRoutes.leaderboard,
              AppRoutes.profile,
              AppRoutes.dashboard, // Include dashboard for Kolektoer
            ].contains(settings.name)) {
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => screen,
                transitionDuration: Duration.zero, // No transition duration
                reverseTransitionDuration: Duration.zero, // No reverse transition duration
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return child; // No animation
                },
              );
            }
            return MaterialPageRoute(builder: (context) => screen); // Default for other routes
          },
        );
      },
    );
  }
}
