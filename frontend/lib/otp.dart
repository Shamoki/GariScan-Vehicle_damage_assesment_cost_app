import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPVerificationPage extends StatefulWidget {
  final String email;

  OTPVerificationPage({required this.email, super.key});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController otpController = TextEditingController();

  Future<void> verifyOTP(BuildContext context) async {
    var url = Uri.parse('http://localhost:5000/api/auth/verify-otp');

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': widget.email,
        'otp': otpController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the OTP sent to your email',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => verifyOTP(context),
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
