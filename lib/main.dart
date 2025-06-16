import 'package:flutter/material.dart';
import 'package:moelung_new/config/app_routes.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:moelung_new/config/app_routes.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/screens/penyetoer/kumpoel_jempoet_screen.dart';
import 'package:moelung_new/screens/penyetoer/trash_screen.dart';
import 'package:moelung_new/screens/penyetoer/leaderboard_screen.dart';
import 'package:moelung_new/screens/penyetoer/point_market_screen.dart';
import 'package:moelung_new/widgets/common/tikoem_map.dart';
import 'package:moelung_new/screens/auth/login_screen.dart';
import 'package:moelung_new/screens/auth/register_screen.dart';
import 'package:moelung_new/screens/common/home_screen.dart'; // Import HomeScreen
import 'package:moelung_new/screens/common/complaint_screen.dart'; // Import ComplaintScreen
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/screens/kolektoer/dashboard_screen.dart'; // Import DashboardScreen
import 'package:moelung_new/screens/penyetoer/education_screen.dart'; // Import EducationScreen
import 'package:moelung_new/screens/common/profile_screen.dart'; // Import ProfileScreen
import 'package:moelung_new/screens/common/notification_screen.dart'; // Import NotificationScreen
import 'package:moelung_new/models/enums/user_role.dart'; // Import UserRole enum

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moelung New',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.login, // Set initial route to login
      onGenerateRoute: (settings) {
        final user = settings.arguments;

        Widget screen;
        // Check if the route requires authentication and if the user is valid
        // Temporarily removed authentication check for debugging routing
        // if (settings.name != AppRoutes.login &&
        //     settings.name != AppRoutes.register &&
        //     settings.name != AppRoutes.home && // Allow home without user for now
        //     settings.name != AppRoutes.complaint && // Allow complaint without user for now
        //     (user == null || !(user is UserModel))) {
        //   // If trying to access an authenticated route without a valid user, redirect to login
        //   return MaterialPageRoute(builder: (context) => const LoginScreen());
        // }

        switch (settings.name) {
          case AppRoutes.login:
            screen = const LoginScreen();
            break;
          case AppRoutes.register:
            screen = const RegisterScreen();
            break;
          case AppRoutes.home:
            screen = HomeScreen(currentUser: (user as UserModel?) ?? UserModel(id: 'dummy', name: 'Dummy User', email: 'dummy@example.com', role: UserRole.penyetoerKumpoelAdat)); // Pass user to HomeScreen
            break;
          case AppRoutes.complaint:
            screen = const ComplaintScreen();
            break;
          case AppRoutes.trash:
            screen = TrashScreen(currentUser: (user as UserModel?) ?? UserModel(id: 'dummy', name: 'Dummy User', email: 'dummy@example.com', role: UserRole.penyetoerKumpoelAdat));
            break;
          case AppRoutes.leaderboard:
            screen = LeaderboardScreen(currentUser: (user as UserModel?) ?? UserModel(id: 'dummy', name: 'Dummy User', email: 'dummy@example.com', role: UserRole.penyetoerKumpoelAdat));
            break;
          case AppRoutes.profile: // Route to the new ProfileScreen
            screen = ProfileScreen(currentUser: (user as UserModel?) ?? UserModel(id: 'dummy', name: 'Dummy User', email: 'dummy@example.com', role: UserRole.penyetoerKumpoelAdat));
            break;
          case AppRoutes.pointMarket: // New route for PointMarketScreen
            screen = PointMarketScreen(currentUser: (user as UserModel?) ?? UserModel(id: 'dummy', name: 'Dummy User', email: 'dummy@example.com', role: UserRole.penyetoerKumpoelAdat));
            break;
          case AppRoutes.map:
            screen = TikoemMap();
            break;
          case AppRoutes.dashboard: // Add dashboard route
            screen = DashboardScreen(currentUser: (user as UserModel?) ?? UserModel(id: 'dummy', name: 'Dummy User', email: 'dummy@example.com', role: UserRole.penyetoerKumpoelAdat));
            break;
          case AppRoutes.education: // Add education route
            screen = EducationScreen(currentUser: (user as UserModel?) ?? UserModel(id: 'dummy', name: 'Dummy User', email: 'dummy@example.com', role: UserRole.penyetoerKumpoelAdat));
            break;
          case AppRoutes.notifications: // Add notifications route
            screen = NotificationScreen(currentUser: (user as UserModel?) ?? UserModel(id: 'dummy', name: 'Dummy User', email: 'dummy@example.com', role: UserRole.penyetoerKumpoelAdat));
            break;
          default:
            return MaterialPageRoute(builder: (context) => const Text('Error: Unknown route'));
        }
        return MaterialPageRoute(builder: (context) => screen);
      },
    );
  }
}
