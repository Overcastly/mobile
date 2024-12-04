import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile/mongodb.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _profilePicture;
  String? _currentProfilePictureUrl;
  String? _updateMessage;
  bool _isLoading = true;
  String? _userId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _userId = await MongoDatabase.getUserId();
      _token = await MongoDatabase.getToken();

      if (_userId == null || _token == null) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/users/$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _usernameController.text = userData['username'] ?? '';
          _currentProfilePictureUrl = userData['image'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
        _updateMessage = 'Failed to load user data';
      });
    }
  }

  Future<String?> _convertImageToBase64(File image) async {
    try {
      final bytes = await image.readAsBytes();
      return 'data:image/png;base64,${base64Encode(bytes)}';
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _updateMessage = null;
      });

      try {
        String? imageBase64;
        if (_profilePicture != null) {
          imageBase64 = await _convertImageToBase64(_profilePicture!);
        }

        final response = await http.put(
          Uri.parse('${dotenv.env['BASE_URL']}/updateuser/$_userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'username': _usernameController.text,
            if (imageBase64 != null) 'image': imageBase64,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            _updateMessage = 'Profile updated successfully';
          });
        } else {
          final error = jsonDecode(response.body)['error'];
          setState(() {
            _updateMessage = error ?? 'Failed to update profile';
          });
        }
      } catch (e) {
        print('Error updating profile: $e');
        setState(() {
          _updateMessage = 'Failed to update profile';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool isValidUrl(String str) {
    return str.toLowerCase().startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _profilePicture = File(pickedFile.path);
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePicture != null
                        ? FileImage(_profilePicture!)
                        : (_currentProfilePictureUrl != null && 
                           isValidUrl(_currentProfilePictureUrl!)
                            ? NetworkImage(_currentProfilePictureUrl!)
                            : null) as ImageProvider?,
                    child: _profilePicture == null && 
                          (_currentProfilePictureUrl == null || 
                           !isValidUrl(_currentProfilePictureUrl!))
                        ? const Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (_updateMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _updateMessage!,
                    style: TextStyle(
                      color: _updateMessage!.contains('successfully') 
                        ? Colors.green 
                        : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isLoading ? null : _updateProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Update Profile'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}