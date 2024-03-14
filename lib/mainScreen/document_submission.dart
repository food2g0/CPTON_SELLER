import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors.dart';
import '../global/global.dart';
import '../push notification/push_notification_system.dart';
import 'confirmation_screen.dart';

class DocumentSubmission extends StatefulWidget {
  const DocumentSubmission({Key? key});

  @override
  State<DocumentSubmission> createState() => _DocumentSubmissionState();
}

class _DocumentSubmissionState extends State<DocumentSubmission> {
  PlatformFile? driverLicenseFile;
  UploadTask? driverLicenseUploadTask;

  Future<void> selectDriverLicenseFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    setState(() {
      driverLicenseFile = result.files.first;
  });
  }

  Future<void> uploadDriverLicenseFile() async {
    final task = await _uploadFile(driverLicenseFile, (snapshot) {
      // Callback after upload completes
      print("Upload complete");
    });
    setState(() {
      driverLicenseUploadTask = task;
    });
  }


  Future<UploadTask> _uploadFile(
      PlatformFile? file,
      void Function(TaskSnapshot) onComplete,
      ) async {
    if (file == null) throw Exception("File is null");

    final path = 'SellerFiles/${file.name}';
    final fileContent = File(file.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    final uploadTask = ref.putFile(fileContent);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (dynamic error) {
      print('Upload error: $error');
    });

    final snapshot = await uploadTask;
    final urlDownload = await snapshot.ref.getDownloadURL();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await saveDataToFirestore(currentUser, urlDownload);
      onComplete(snapshot);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationScreen()),
      );
    }
    return uploadTask;
  }


  // Future<void> _uploadFile(
  //     PlatformFile? file,
  //     void Function(TaskSnapshot) onComplete,
  //     ) async {
  //   if (file == null) return;
  //
  //   final path = 'SellerFiles/${file.name}';
  //   final fileContent = File(file.path!);
  //
  //   final ref = FirebaseStorage.instance.ref().child(path);
  //
  //   setState(() {
  //     driverLicenseUploadTask = ref.putFile(fileContent);
  //   });
  //
  //   final snapshot = await driverLicenseUploadTask!;
  //   final urlDownload = await snapshot.ref.getDownloadURL();
  //
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     await saveDataToFirestore(currentUser, urlDownload);
  //     onComplete(snapshot);
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => ConfirmationScreen()),
  //     );
  //   }
  // }

  Future<void> saveDataToFirestore(User currentUser, String documentUrl) async {
    try {
      final uid = currentUser.uid;
      final userData = {"documentUrl": documentUrl};

      await FirebaseFirestore.instance
          .collection("sellersDocs")
          .doc(uid)
          .set(userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("documentUrl", documentUrl);
    } catch (error) {
      print("Error saving data to Firestore: $error");
    }
  }
  Future<void> _checkEmailVerification() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !currentUser.emailVerified) {
      // If email is not verified, show a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Email Not Verified'),
          content: Text('Please open your email to verify your account.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Document Submission",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12.sp,
            color: AppColors().white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (driverLicenseFile != null)
              Expanded(
                child: Container(
                  color: AppColors().white,
                  child: Center(
                    child: Text(driverLicenseFile!.name),
                  ),
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.w),
                ),
                minimumSize: Size(210, 40),
              ),
              onPressed: selectDriverLicenseFile,
              child: Text(
                "Select Business Permit File",
                style: TextStyle(
                  color: AppColors().white,
                  fontFamily: "Poppins",
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.w),
                ),
                minimumSize: Size(210, 40),
              ),
              onPressed: uploadDriverLicenseFile,
              child: Text(
                "Upload File",
                style: TextStyle(
                  color: AppColors().white,
                  fontSize: 12.sp,
                  fontFamily: "Poppins",
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
