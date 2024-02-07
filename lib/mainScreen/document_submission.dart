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
import 'confirmation_screen.dart';

class DocumentSubmission extends StatefulWidget {
  const DocumentSubmission({super.key});

  @override
  State<DocumentSubmission> createState() => _DocumentSubmissionState();
}

class _DocumentSubmissionState extends State<DocumentSubmission> {
  PlatformFile? driverLicenseFile;
  UploadTask? driverLicenseUploadTask;

  Future selectDriverLicenseFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      driverLicenseFile = result.files.first;
    });
  }

  Future uploadDriverLicenseFile() async {
    await _uploadFile(driverLicenseFile, (snapshot) {
      driverLicenseUploadTask = null;
    });
  }

  Future<void> _uploadFile(
      PlatformFile? file,
      void Function(TaskSnapshot) onComplete,
      ) async {
    if (file == null) return;

    final path = 'SellerFiles/${file.name}';
    final fileContent = File(file.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      driverLicenseUploadTask = ref.putFile(fileContent);
    });

    final snapshot = await driverLicenseUploadTask!.whenComplete(() {});

    // Get the download URL of the uploaded document
    final urlDownload = await snapshot.ref.getDownloadURL();

    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Save the document URL to Firestore
    await saveDataToFirestore(currentUser!, urlDownload);

    // Call onComplete callback
    onComplete(snapshot);

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfirmationScreen()),
    );
  }

  Future saveDataToFirestore(User currentUser, String documentUrl) async {
    // Get the current user's UID
    String uid = currentUser.uid;

    // Construct the data to be saved to Firestore
    Map<String, dynamic> userData = {
      "documentUrl": documentUrl, // URL of the submitted document
      // Add other user data as needed
    };

    try {
      // Save the data to Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set(userData);

      // Save data locally if needed
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("documentUrl", documentUrl);
    } catch (error) {
      print("Error saving data to Firestore: $error");
      // Handle error
    }
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
              onPressed: selectDriverLicenseFile,
              child: Text("Select Driver License File"),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: uploadDriverLicenseFile,
              child: Text("Upload Driver License File"),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
