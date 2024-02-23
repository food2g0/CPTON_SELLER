import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';
import '../global/global.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _user;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userData;

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
          'Profile',
          style: TextStyle(
            fontFamily: "Poppins",
            color: AppColors().white,
            fontSize: 12.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
            icon: Icon(
              Icons.edit,
              color: AppColors().white,
            ),
          ),
        ],
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
            String sellersImageUrl = userData['sellersImageUrl'] ?? '';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        borderRadius: const BorderRadius.all(Radius.circular(80)),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                sellersImageUrl,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50.h,),
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors().red, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        ' ${userData['sellersName']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, color: AppColors().red, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        ' ${userData['sellersEmail']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Add more profile information here based on your database structure
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
