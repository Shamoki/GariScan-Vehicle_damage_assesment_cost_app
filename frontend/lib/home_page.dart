import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'history.dart';
import 'profile.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const UploadButtonPage(),
     HistoryPageApp(),
     Profilepic(),
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
            child: ProfilePopupMenu(),
          ),
        ],
      ),
      bottomNavigationBar: _buildSalomonBottomBar(context),
    );
  }

  Widget _buildSalomonBottomBar(BuildContext context) {
  return SalomonBottomBar(
    currentIndex: _selectedIndex,
    onTap: (index) {
      setState(() {
        _selectedIndex = index; // Switch tabs within the same structure
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
  const UploadButtonPage({super.key});

  @override
  UploadButtonPageState createState() => UploadButtonPageState();
}

class UploadButtonPageState extends State<UploadButtonPage>
    with SingleTickerProviderStateMixin {
  bool _isUploading = false;
  Uint8List? _selectedFileBytes;
  String? _selectedFilePath;
  late AnimationController _controller;
  // ignore: unused_field
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif'],
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedFileBytes = result.files.single.bytes;
          _selectedFilePath = result.files.single.name; // Use file name
        });
        await _uploadImage();
      } else {
        _showErrorSnackBar("No file selected or invalid format.");
      }
    } catch (e) {
      _showErrorSnackBar("Error selecting file: $e");
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedFileBytes == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      String? token = prefs.getString('token');

      if (userId == null || token == null) {
        _showErrorSnackBar('You must log in first.');
        return;
      }

      var url = Uri.parse('http://localhost:5000/api/upload/');
      var request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['userId'] = userId;

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _selectedFileBytes!,
        filename: _selectedFilePath ?? 'upload.png',
      ));

      var response = await request.send();

      if (response.statusCode == 201) {
        _showUploadResult(true);
      } else {
        var errorMsg = await response.stream.bytesToString();
        _showErrorSnackBar("Upload failed: $errorMsg");
      }
    } catch (e) {
      _showErrorSnackBar("Upload error: $e");
    } finally {
      setState(() {
        _isUploading = false;
        _selectedFileBytes = null;
      });
    }
    
  }

  
  void _showUploadResult(bool success) {
  final message = success ? "Upload Successful" : "Upload Failed";

  // Show the result dialog
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(message),
        content: const Text("Your image is being processed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog manually if OK is pressed
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );

  // Navigate to the waiting page immediately, even if the dialog is still open
  if (success) {
    Future.delayed(Duration.zero, () {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/waiting_page');
    });
  }
}


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
Widget build(BuildContext context) {
  return Center(
    child: Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _pickFromGallery, // Trigger file picker
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'animations/upload.json', 
                height: 200,
                repeat: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Tap to Analyse',
                style: TextStyle(
                  color: Color.fromARGB(255, 243, 5, 191),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (_isUploading) const CircularProgressIndicator(),
      ],
    ),
  );
}

}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
  const ProfilePopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.purple, Color.fromARGB(255, 255, 68, 239)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 30.0,
        ),
      ),
      onSelected: (Menu item) {
        switch (item) {
          case Menu.profile:
            Navigator.pushReplacementNamed(context, '/profile');
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
