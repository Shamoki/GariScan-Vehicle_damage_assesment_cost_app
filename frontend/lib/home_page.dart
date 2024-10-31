import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const UploadButtonPage(),
    const Center(child: Text("History Page", style: TextStyle(fontSize: 24))),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _pages[_selectedIndex],
          ),
          const Positioned(
            top: 20,
            right: 16,
            child: ProfilePopupMenu(), // Positioned Profile Popup
          ),
        ],
      ),
      bottomNavigationBar: _buildSalomonBottomBar(),
    );
  }

  Widget _buildSalomonBottomBar() {
    return SalomonBottomBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.upload_file),
          title: const Text("Upload"),
          selectedColor: Colors.purple.withOpacity(0.8),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.history),
          title: const Text("History"),
          selectedColor: Colors.purple.withOpacity(0.8),
        ),
      ],
    );
  }
}

class UploadButtonPage extends StatefulWidget {
  const UploadButtonPage({Key? key}) : super(key: key);

  @override
  UploadButtonPageState createState() => UploadButtonPageState();
}

class UploadButtonPageState extends State<UploadButtonPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // animation controlller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    // scaling button
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller.
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
        _controller.stop(); // Stop animation during upload.
      });

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await _uploadImageFromBytes(bytes, pickedFile.name);
      } else {
        final file = File(pickedFile.path);
        await _uploadImageFromFile(file);
      }

      setState(() {
        _isUploading = false;
        _controller.repeat(reverse: true); // Restart animation.
      });
    }
  }

  Future<void> _uploadImageFromBytes(Uint8List bytes, String filename) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/upload'),
      );
      request.files
          .add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      var response = await request.send();
      _showUploadResult(response.statusCode == 200);
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    }
  }

  Future<void> _uploadImageFromFile(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var response = await request.send();
      _showUploadResult(response.statusCode == 200);
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    }
  }

  void _showUploadResult(bool success) {
    final message = success ? 'Upload Successful' : 'Upload Failed';
    // Use the nearest valid context from your widget tree
    showDialog(
      context: context, // Ensure this is valid at the time of call
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(message),
          content: const Text('Your image is being processed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize
                .min, // Ensure the column only takes the needed space
            children: [
              // Animated Button
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value, // Apply animated scaling.
                    child: child,
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.8),
                        Colors.purple.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50), //space
              const Text(
                'Tap to Analyse',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Profile Page",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ProfilePopupMenu extends StatelessWidget {
  const ProfilePopupMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Colors.purple,
              Color.fromARGB(255, 255, 68, 239)
            ], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0), // Padding around the icon
        child: const Icon(
          Icons.person,
          color: Colors.white, // White icon for contrast
          size: 30.0, // Slightly smaller size for minimal feel
        ),
      ),
      onSelected: (Menu item) {
        switch (item) {
          case Menu.profile:
            Navigator.pushReplacementNamed(context, '/profile_page');
            break;
          case Menu.settings:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
          case Menu.signOut:
            Navigator.pushReplacementNamed(context, '/login');
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<Menu>>[
        const PopupMenuItem<Menu>(
          value: Menu.profile,
          child: Text('Profile'),
        ),
        const PopupMenuItem<Menu>(
          value: Menu.settings,
          child: Text('Settings'),
        ),
        const PopupMenuItem<Menu>(
          value: Menu.signOut,
          child: Text('Sign Out'),
        ),
      ],
    );
  }
}

enum Menu { profile, settings, signOut }
