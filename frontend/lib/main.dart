import 'package:flutter/material.dart';
import 'package:onboarding/onboarding_page.dart'; // Onboarding page import
import 'login_page.dart'; // Login page import
import 'home_page.dart'; // Home page import
import 'signup_page.dart'; // Signup page import
import 'settings.dart'; // Settings page import
import 'package:navigation_history_observer/navigation_history_observer.dart'; // Import NavigationHistoryObserver
import 'waiting_page.dart';

void main() {
  runApp(const MyApp()); // App entry point
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GariScan',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,

      // Add NavigationHistoryObserver to track navigation events.
      navigatorObservers: [NavigationHistoryObserver()],

      initialRoute: '/onboarding', // Set initial route to onboarding page

      routes: {
        // Onboarding Page Route
        '/onboarding': (context) => OnboardingPage(
              pages: [
                OnboardingPageModel(
                  title: 'Welcome to GariScan',
                  description:
                      'Your go-to app for fast vehicle damage scan and repair estimates.',
                  image: 'assets/image0.png',
                  bgColor: Colors.purple,
                ),
                OnboardingPageModel(
                  title: 'Analyze your vehicle ANYWHERE, ANYTIME',
                  description:
                      'Upload an image of your vehicle, we\'ll assess it in minutes.',
                  image: 'assets/image3.png',
                  bgColor: Colors.purple,
                ),
                OnboardingPageModel(
                  title: 'Get COST estimates',
                  description: 'Find how much it costs to repair your damage.',
                  image: 'assets/money.gif',
                  bgColor: Colors.purple,
                ),
                OnboardingPageModel(
                  title: 'Fish your History',
                  description:
                      'Keep a record of all your vehicle assessments for future reference.',
                  image: 'assets/image1.png',
                  bgColor: Colors.purple,
                ),
              ],
            ),

        // Login Page Route
        '/login': (context) => LoginPage(),

        // Signup Page Route
        '/signup': (context) => SignupPage(),

        // Home Page Route
        '/home': (context) => const HomePage(),

        // Settings Page Route
        '/settings': (context) => const SettingsPage(),

        '/profile_page': (context) => const ProfilePage(),

        '/waiting_page': (context) => const WaitingPage(),
      },
    );
  }
}
