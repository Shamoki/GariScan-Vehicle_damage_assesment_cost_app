import 'package:flutter/material.dart';

void main() {
  runApp(HistoryPageApp());
}

class HistoryPageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HistoryPage(),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Detect swipe gesture to navigate back
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          elevation: 0,
          title: const Text(
            "History",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search history...",
                    prefixIcon: Icon(Icons.search, color: Colors.purple),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.purple),
                    ),
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
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  item["title"]!,
                                  style: const TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  item["description"]!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: Text(
                                  item["date"]!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      item["details"]!,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.purple.shade200),
          const SizedBox(height: 16),
          const Text(
            "No History Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your recent activity will show up here.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
