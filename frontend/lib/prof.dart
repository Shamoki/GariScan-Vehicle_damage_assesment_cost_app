import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProfPage extends StatefulWidget {
  const ProfPage({super.key});

  @override
  State<ProfPage> createState() => _ProfPageState();
}

class _ProfPageState extends State<ProfPage> {
  String _username = "Loading...";
  String _email = "Loading...";
  Uint8List? _profilePhotoBytes;
  bool _isUploading = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    String? storedEmail = prefs.getString('email');
    
    if (storedUsername != null && storedEmail != null) {
      setState(() {
        _username = storedUsername;
        _email = storedEmail;
      });
    } else {
      await _fetchUserDataFromBackend();
    }
    await _loadProfilePhoto();
  } catch (e) {
    _showSnackbar('Error initializing profile: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  // Fetch user data (username and email) from API
  Future<void> _fetchUserDataFromBackend() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      String? token = prefs.getString('token');

      if (userId == null || token == null) {
        throw Exception("User not logged in.");
      }

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String fetchedUsername = data['username'] ?? "No Name Found";
        String fetchedEmail = data['email'] ?? "No Email Found";

        // Update SharedPreferences with the fetched data
        await prefs.setString('username', fetchedUsername);
        await prefs.setString('email', fetchedEmail);

        setState(() {
          _username = fetchedUsername;
          _email = fetchedEmail;
        });
      } else {
        _showSnackbar('Failed to fetch user data. Status: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error fetching user data from backend: $e');
    }
  }

  // Load profile photo from API
  Future<void> _loadProfilePhoto() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("User not logged in.");
      }

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/profile/photo'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _profilePhotoBytes = response.bodyBytes;
        });
      } else {
        _showSnackbar('Failed to load profile photo. Status: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error loading profile photo: $e');
    }
  }

  // Upload new profile photo
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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token == null) {
          throw Exception("User not logged in.");
        }

        final url = Uri.parse('http://localhost:5000/api/profile/upload');
        final request = http.MultipartRequest('POST', url);

        request.headers['Authorization'] = 'Bearer $token';
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
          _showSnackbar('Failed to upload profile photo. Status: ${response.statusCode}');
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Profile Photo Section
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.purple.shade100,
                          backgroundImage: _profilePhotoBytes != null
                              ? MemoryImage(_profilePhotoBytes!)
                              : const AssetImage('assets/avatar.png')
                                  as ImageProvider,
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
                    const SizedBox(height: 20),
                    // Username
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.purple),
                        title: Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text('Username'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Email
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.email, color: Colors.purple),
                        title: Text(
                          _email,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Text('Email'),
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
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
