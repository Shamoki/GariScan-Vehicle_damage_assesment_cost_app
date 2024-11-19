import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class Profilepic extends StatefulWidget {
  const Profilepic({super.key});

  @override
  State<Profilepic> createState() => _ProfilepicState();
}

class _ProfilepicState extends State<Profilepic> {
  Uint8List? _profilePhotoBytes; // To store the loaded profile photo
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/profile/photo'));

      if (response.statusCode == 200) {
        setState(() {
          _profilePhotoBytes = response.bodyBytes; // Load the profile photo bytes
        });
      } else {
        _showSnackbar('Failed to load profile photo.');
      }
    } catch (e) {
      _showSnackbar('Error loading profile photo: $e');
    }
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isUploading = true;
        });

        final url = Uri.parse('http://localhost:5000/api/profile/upload');
        final request = http.MultipartRequest('POST', url);

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            result.files.single.bytes!,
            filename: result.files.single.name,
          ),
        );

        final response = await request.send();

        if (response.statusCode == 201) {
          await _loadProfilePhoto();
          _showSnackbar('Profile photo updated successfully.');
        } else {
          _showSnackbar('Failed to upload profile photo.');
        }
      }
    } catch (e) {
      _showSnackbar('Error uploading photo: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Photo
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.purple.shade100,
                      backgroundImage: _profilePhotoBytes != null
                          ? MemoryImage(_profilePhotoBytes!)
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                    FloatingActionButton.small(
                      backgroundColor: Colors.purple,
                      onPressed: _uploadProfilePhoto,
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Name
              const Text(
                "John Doe", // Replace with the actual user's name
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Email
              const Text(
                "johndoe@example.com", // Replace with the actual user's email
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              if (_isUploading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _uploadProfilePhoto,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload New Photo'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
