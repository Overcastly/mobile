import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  File? _profilePicture;
  String? _currentProfilePictureUrl;
  String? _updateMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    print("Debug: Fetched userDataString = $userDataString"); // Debugging

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      print("Debug: Decoded userData = $userData"); // Debugging

      setState(() {
        _firstNameController.text = userData['firstName'] ?? '';
        _lastNameController.text = userData['lastName'] ?? '';
        _usernameController.text = userData['username'] ?? '';
        _currentProfilePictureUrl = userData['profilePictureUrl'];
      });

      print(
          "Debug: Loaded data into controllers -> First Name: ${_firstNameController.text}, Last Name: ${_lastNameController.text}, Username: ${_usernameController.text}"); // Debugging
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        final token = userData['token'];
        final baseUrl = userData['baseUrl'];

        // mistake here
        final url = Uri.parse('$baseUrl/api/updateuser/${userData['userId']}');
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'username': _usernameController.text,
            if (_profilePicture != null) 'image': await _convertImageToBase64(_profilePicture!),
          }),
        );

        if (response.statusCode == 200) {
          // Update local user data
          final updatedUserData = {
            ...userData,
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'username': _usernameController.text,
            if (_profilePicture != null) 'profilePictureUrl': await _convertImageToBase64(_profilePicture!),
          };
          await prefs.setString('userData', jsonEncode(updatedUserData));
          setState(() {
            _updateMessage = 'Profile updated successfully';
          });
        } else {
          setState(() {
            _updateMessage = 'Failed to update profile';
          });
        }
      }
    }
  }

  Future<String?> _convertImageToBase64(File image) async {
    try {
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
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
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
                        : (_currentProfilePictureUrl != null
                            ? NetworkImage(_currentProfilePictureUrl!)
                            : null) as ImageProvider?,
                    child: _profilePicture == null && _currentProfilePictureUrl == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(200, 50),
                  ),
                  onPressed: _updateProfile,
                  child: Text('Update Profile'),
                ),
              ),
              if (_updateMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Text(
                      _updateMessage!,
                      style: TextStyle(
                        color: _updateMessage!.contains('successfully') ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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