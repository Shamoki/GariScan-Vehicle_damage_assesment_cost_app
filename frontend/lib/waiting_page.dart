import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const GariscanApp());
}

class GariscanApp extends StatelessWidget {
  const GariscanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GariscanWaitingPage(),
    );
  }
}

class GariscanWaitingPage extends StatefulWidget {
  const GariscanWaitingPage({super.key});

  @override
  _GariscanWaitingPageState createState() => _GariscanWaitingPageState();
}

class _GariscanWaitingPageState extends State<GariscanWaitingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromARGB(255, 240, 240, 240)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lottie Animation
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Lottie.asset(
                    'assets/animations/inspect.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Tagline Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                children: const [
                  Text(
                    "While You Wait for us to analyse, take note of some safety tips:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Safety Tips Carousel
            Expanded(
              flex: 5,
              child: PageView(
                controller: PageController(viewportFraction: 0.85),
                children: [
                  _buildSafetyCard(
                    icon: Icons.warning,
                    title: "Move to Safety",
                    description: "If possible, move to the side of the road to avoid traffic.",
                  ),
                  _buildSafetyCard(
                    icon: Icons.phone,
                    title: "Emergency Assistance",
                    description: "Call Kenya's emergency number 999 for help.",
                  ),
                  _buildSafetyCard(
                    icon: Icons.camera_alt,
                    title: "Document the Scene",
                    description: "Take photos and exchange contact details.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.purple),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
