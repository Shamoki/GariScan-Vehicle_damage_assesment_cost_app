import 'package:flutter/material.dart';

class WaitingPage extends StatelessWidget {
  const WaitingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waiting Page"),
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Replace with any desired UI
      ),
    );
  }
}
