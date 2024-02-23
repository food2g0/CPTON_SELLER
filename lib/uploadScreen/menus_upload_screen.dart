import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:cpton_food2go_sellers/mainScreen/products_screen.dart';
import 'package:cpton_food2go_sellers/uploadScreen/items_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import '../Widgets/error_dialog.dart';
import 'package:path/path.dart' as path;

import '../global/global.dart';
import '../mainScreen/home_screen.dart';

class MenusUploadScreen extends StatefulWidget {
  const MenusUploadScreen({Key? key}) : super(key: key);

  @override
  State<MenusUploadScreen> createState() => _MenusUploadScreenState();
}

class _MenusUploadScreenState extends State<MenusUploadScreen> {
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  TextEditingController shortInfoController = TextEditingController();
  String selectedOption = "Burger";
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false; // Track upload status
  double uploadProgress = 0; // Track upload progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Add New Menu",
          style: TextStyle(
            color: AppColors().white,
            fontSize: 12.sp,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    takeImage(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColors().red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        color: AppColors().black,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Add Menu Image",
                        style: TextStyle(
                          color: AppColors().white,
                          fontSize: 12.sp,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              if (imageXFile != null) ...[
                Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(
                        File(imageXFile!.path),
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: shortInfoController,
                  decoration: InputDecoration(
                    hintText: "Menu Info (Optional)",
                    hintStyle: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 10.sp
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: selectedOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOption = newValue!;
                    });
                  },
                  items: ["Coffee", "Fries", "Drinks","Milk tea", "Pizza", "Chicken", "Dessert","Burger" ]
                      .map<DropdownMenuItem<String>>((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(
                          fontFamily: "Poppins", // Set the font family
                          fontSize: 12.sp, // Set the font size
                          color: AppColors().black, // Set the text color
                        ),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    hintText: "Select Menu Title",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 40.h),
                uploading // Show circular progress indicator if uploading
                    ? Center(
                  child: CircularProgressIndicator(
                    value: uploadProgress,
                    color: AppColors().red,
                  ),
                )
                    : Center(
                  child: GestureDetector(
                    onTap: uploadValidateForm,
                    child: Container(
                      height: 50.h,
                      width: 200.w,
                      child: ElevatedButton(
                        onPressed: uploadValidateForm,
                        style: ElevatedButton.styleFrom(
                          primary: AppColors().red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Text(
                            "Add Menu",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors().white,
                              fontSize: 12.sp,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  takeImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Menu Image",
            style: TextStyle(
              color: AppColors().black,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
              fontSize: 14.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  captureImageWithCamera();
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.camera_alt,
                      color: AppColors().red,),
                    SizedBox(width: 8),
                    Text(
                      "Capture with Camera",
                      style: TextStyle(
                        color: AppColors().black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h,),
              InkWell(
                onTap: () {
                  pickImageFromGallery();
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.photo_library,
                      color: AppColors().red,),
                    SizedBox(width: 8),
                    Text(
                      "Select From Gallery",
                      style: TextStyle(
                        color: AppColors().black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  captureImageWithCamera() async {
    imageXFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 720.h,
      maxWidth: 1280.w,
    );

    setState(() {});
  }

  pickImageFromGallery() async {
    imageXFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 720.h,
      maxWidth: 1280.w,
      imageQuality: 50,
    );

    if (imageXFile != null) {
      String fileExtension = path.extension(imageXFile!.path);
      if (fileExtension.toLowerCase() != '.png') {
        // Show an error message and return early if the file is not a PNG image
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: "Please select a PNG image.",
            );
          },
        );
        return;
      }
    }

    setState(() {});
  }


  uploadValidateForm() async {
    if (imageXFile != null && selectedOption.trim().isNotEmpty) {
      setState(() {
        uploading = true; // Set uploading to true when upload starts
      });

      bool optionExists = await checkOptionExists(selectedOption.trim());
      if (optionExists) {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: "The selected option already exists in the menu.",
            );
          },
        );
        clearMenusUploadForm();
        setState(() {
          uploading = false; // Set uploading to false when upload completes
        });
      } else {
        String downloadUrl = await uploadImage(File(imageXFile!.path));
        saveInfo(downloadUrl, shortInfoController.text, selectedOption.trim());
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            message: "Please fill all the forms and select an image.",
          );
        },
      );
    }
    Navigator.push(context, MaterialPageRoute(builder: (c)=>ProductsScreen()));
  }

  Future<bool> checkOptionExists(String option) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("sellersUID"))
        .collection("menus")
        .where("menuTitle", isEqualTo: option)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  saveInfo(String downloadUrl, String shortInfo, String titleMenu) {
    final ref = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("sellersUID"))
        .collection("menus");

    ref.doc(uniqueIdName).set({
      "menuID": uniqueIdName,
      "sellersUID": sharedPreferences!.getString("sellersUID"),
      "menuInfo": shortInfoController.text.toString(),
      "menuTitle": selectedOption.toString(),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl,
    });

    clearMenusUploadForm();
    setState(() {
      uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
      uploading = false;
    });
  }

  uploadImage(mImageFile) async {
    storageRef.Reference reference = storageRef.FirebaseStorage.instance.ref()
        .child("menus");

    storageRef.UploadTask uploadTask = reference.child(uniqueIdName + ".png").putFile(mImageFile);

    // Listen to the task snapshots to track the upload progress
    uploadTask.snapshotEvents.listen((storageRef.TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      setState(() {
        uploadProgress = progress;
      });
    });

    // Wait for the upload task to complete
    storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  }

  clearMenusUploadForm() {
    shortInfoController.clear();
    imageXFile = null;
    selectedOption = "";
  }
}
