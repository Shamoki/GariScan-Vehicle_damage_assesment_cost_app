import 'package:flutter/material.dart';
import 'package:onboarding/onboarding_page.dart'; // Onboarding page import
import 'login_page.dart'; // Login page import
import 'home_page.dart'; // Home page import
import 'signup_page.dart'; // Signup page import
import 'settings.dart'; // Settings page import
import 'waiting_page.dart'; // Waiting page import
import 'history_page.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart'; // Import NavigationHistoryObserver

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Global Key for Navigator
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      key: const ValueKey("MaterialApp"), // Avoid reinitialization
      title: 'GariScan',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,

      // Add NavigationHistoryObserver for tracking navigation events
      navigatorObservers: [NavigationHistoryObserver()],
      navigatorKey: navigatorKey,

      // Set initial route based on history or default to onboarding
      initialRoute: NavigationHistoryObserver().history.isEmpty
          ? '/onboarding'
          : NavigationHistoryObserver().top?.settings.name,

      // Define app routes
      routes: {
        '/onboarding': (context) => const OnboardingWrapper(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/profile_page': (context) => const ProfilePage(),
        '/waiting_page': (context) =>  GariscanApp(),
        '/history_page': (context) =>  HistoryPageApp(),
      },
    );
  }
}

// Wrapper for Onboarding Page to simplify MaterialApp configuration
class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      pages: [
        OnboardingPageModel(
          title: 'Welcome to GariScan',
          description: 'Your go-to app for fast vehicle damage scan and repair estimates.',
          image: 'assets/image0.png',
          bgColor: Colors.purple,
        ),
        OnboardingPageModel(
          title: 'Analyze your vehicle ANYWHERE, ANYTIME',
          description: 'Upload an image of your vehicle, we\'ll assess it in minutes.',
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
          description: 'Keep a record of all your vehicle assessments for future reference.',
          image: 'assets/image1.png',
          bgColor: Colors.purple,
        ),
      ],
    );
  }
}
