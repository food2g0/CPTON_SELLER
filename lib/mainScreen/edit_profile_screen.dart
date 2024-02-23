import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../colors.dart';
import '../global/global.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late User? _user;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userData;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userData = FirebaseFirestore.instance.collection('sellers').doc(_user!.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: "Poppins",
            color: AppColors().white,
            fontSize: 12.sp,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User data not found.'));
          } else {
            Map<String, dynamic> userData = snapshot.data!.data()!;
            _nameController.text = userData['sellersName'];
            _emailController.text = userData['sellersEmail'];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : NetworkImage(userData['sellersImageUrl']) as ImageProvider<Object>?,

                    ),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Implement update profile functionality
                      _updateProfile(_nameController.text, _emailController.text);
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _updateProfile(String name, String email) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _userData;
      final userData = snapshot.data()!;
      String imageUrl = userData['sellersImageUrl']; // Default to current image URL

      if (_imageFile != null) {
        imageUrl = await _uploadImageToStorage(); // Upload new image and get URL
      }

      await FirebaseFirestore.instance.collection('sellers').doc(_user!.uid).update({
        'sellersName': name,
        'sellersEmail': email,
        'sellersImageUrl': imageUrl,
      });

      // Show success message or navigate back to profile screen
      Navigator.pop(context); // Navigate back to profile screen after successful update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
        ),
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  Future<String> _uploadImageToStorage() async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final imageName = fileName;
    final storageRef = storage.ref().child('sellers/$imageName');
    final uploadTask = storageRef.putFile(_imageFile!);
    final snapshot = await uploadTask.whenComplete(() => null);
    final imageUrl = await snapshot.ref.getDownloadURL();

    return imageUrl;
  }
}
