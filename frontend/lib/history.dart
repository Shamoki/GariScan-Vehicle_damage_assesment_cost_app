import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider for ThemeProvider
import 'theme_provider.dart'; // Import ThemeProvider

void main() {
  runApp(const HistoryPageApp());
}

class HistoryPageApp extends StatelessWidget {
  const HistoryPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  HistoryPage(),
    );
  }
}

class HistoryPage extends StatelessWidget {
  // Dummy ML output data
  final List<Map<String, String>> historyItems = [
    {
      "title": "Inspection - 12th Nov 2024",
      "description": "Damage Type: Dent, Severity: Moderate.",
      "details": "Damaged part: Left Door\nEstimated cost: \$500",
      "date": "12/11/2024"
    },
    {
      "title": "Inspection - 5th Oct 2024",
      "description": "Damage Type: Scratch, Severity: Severe.",
      "details": "Damaged part: Rear Bumper\nEstimated cost: \$1,200",
      "date": "05/10/2024"
    },
    {
      "title": "Inspection - 22nd Sep 2024",
      "description": "Damage Type: Crack, Severity: Minor.",
      "details": "Damaged part: Front Windshield\nEstimated cost: \$300",
      "date": "22/09/2024"
    },
  ];

   HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Detect swipe gesture to navigate back
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
  backgroundColor: isDarkMode ? Colors.black : Colors.white,
  elevation: 0,
  centerTitle: true, // Center the title
  title: Text(
    "",
    style: TextStyle(color: isDarkMode ? Colors.white : Colors.purple),
  ),
  
),

        body: Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search history...",
                    prefixIcon: Icon(Icons.search,
                        color: isDarkMode ? Colors.white : Colors.purple),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                          color: isDarkMode ? Colors.grey : Colors.purple),
                    ),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),

              // History Items
              Expanded(
                child: historyItems.isNotEmpty
                    ? ListView.builder(
                        itemCount: historyItems.length,
                        itemBuilder: (context, index) {
                          final item = historyItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              color: isDarkMode ? Colors.grey[850] : Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  item["title"]!,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  item["description"]!,
                                  style: TextStyle(
                                    color:
                                        isDarkMode ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                trailing: Text(
                                  item["date"]!,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey : Colors.grey[600],
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      item["details"]!,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : _buildEmptyState(isDarkMode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history,
              size: 80, color: isDarkMode ? Colors.white70 : Colors.purple.shade200),
          const SizedBox(height: 16),
          Text(
            "No History Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your recent activity will show up here.",
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
