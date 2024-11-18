import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(GariscanApp());
}

class GariscanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GariscanWaitingPage(),
    );
  }
}

class GariscanWaitingPage extends StatefulWidget {
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
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Lottie Animation occupying half the screen
            Expanded(
              flex: 5,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/inspect.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Safety Tips Section
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  const Text(
                    "While You Wait, Here are Some Safety Tips:",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Safety Tips Carousel
                  Expanded(
                    child: PageView(
                      controller: PageController(viewportFraction: 0.9),
                      children: [
                        _buildSafetyCard(
                          icon: Icons.warning,
                          title: "Incase of an accident.Move to Safety",
                          description:
                              "If possible, move to the side of the road to avoid blocking traffic.",
                        ),
                        _buildSafetyCard(
                          icon: Icons.phone,
                          title: "Call Kenya's emergency number 999",
                          description:
                              "Immediately call the appropriate emergency services for assistance.",
                        ),
                        _buildSafetyCard(
                          icon: Icons.camera_alt,
                          title: "Document the Scene",
                          description:
                              "Take photos of the damage and exchange contact information.",
                        ),
                        
                      ],
                    ),
                  ),

                  // Tagline
                  const Text(
                    "Safety First. Accurate Assessments Always!!",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard(
      {required IconData icon, required String title, required String description}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.purple),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
