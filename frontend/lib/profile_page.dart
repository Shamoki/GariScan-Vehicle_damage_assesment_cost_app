import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: AnimatedSwitcher(
  duration: const Duration(milliseconds: 500),
  transitionBuilder: (Widget child, Animation<double> animation) {
    return FadeTransition(opacity: animation, child: child);
  },
  child: Center(
    child: ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: const Text('Logout'),
    ),
  ),
),

    );
  }
}
