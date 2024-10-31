import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Minor scratch - '),
            subtitle: const Text('Analyzed on 2024-10-23'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Dent on bumper - '),
            subtitle: const Text('Analyzed on 2024-10-20'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
