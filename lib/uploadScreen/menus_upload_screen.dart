import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import '../Widgets/error_dialog.dart';
import 'package:path/path.dart' as path;

import '../global/global.dart';
import '../mainScreen/home_screen.dart';

class MenusUploadScreen extends StatefulWidget {
  const MenusUploadScreen({super.key});

  @override
  State<MenusUploadScreen> createState() => _MenusUploadScreenState();
}

class _MenusUploadScreenState extends State<MenusUploadScreen> {
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  TextEditingController shortInfoController = TextEditingController();
  String selectedOption = "Burger"; // Variable to hold the selected option
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;

  clearMenusUploadForm() {
    setState(() {
      shortInfoController.clear();
      imageXFile = null;
      selectedOption = ""; // Clear the selected option when clearing the form
    });
  }

  // Define a list of available options
  List<String> options = ["Burger", "Fries", "Drinks"];

  defaultScreen() {
    return Material(
      // Set the background color of the Material widget
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => HomeScreen()),
              );
            },
          ),
          title: Text(
            "Add New Menu",
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black45,
                  Colors.black26,
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shop_2_rounded,
                  color: Colors.red[900],
                  size: 200.0,
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  child: Text(
                    "Add New Menu",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.amber),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  onPressed: () {
                    takeImage(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Menu Image",
            style: TextStyle(
                color: Colors.red[900], fontWeight: FontWeight.bold),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                "Capture with Camera",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Select From Gallery",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  captureImageWithCamera() async {
    Navigator.pop(context);
    imageXFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 720,
      maxWidth: 1280,
    );

    setState(() {
      imageXFile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    imageXFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 720,
      maxWidth: 1280,
      imageQuality: 50, // Adjust image quality as needed
    );
    if (imageXFile != null) {
      String fileExtension = path.extension(imageXFile!.path);
      if (fileExtension.toLowerCase() == '.png') {
        setState(() {
          imageXFile;
        });
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please select a PNG image.",
            );
          },
        );
      }
    }
  }

  menusUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            clearMenusUploadForm();
          },
        ),
        actions: [],
        title: Text(
          "Uploading New Menu",
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          uploading == true ? LinearProgressIndicator() : Text(""),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(
                        File(imageXFile!.path),
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.perm_device_info_outlined,
                color: Colors.red[700]),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: shortInfoController,
                decoration: InputDecoration(
                  hintText: "Menu Info",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.fastfood_sharp, color: Colors.red[700]),
            title: Container(
              width: 250,
              child:DropdownButtonFormField<String>(
                value: selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue!;
                  });
                },
                items: options.map<DropdownMenuItem<String>>((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: "Select Menu Title",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            trailing: Container(
              width: 100,
              child: ElevatedButton(
                child: Text("Add Menu"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: uploading ? null : () => uploadValidateForm(),
              ),
            ),
          )
        ],
      ),
    );
  }

  uploadValidateForm() async {
    if (imageXFile != null) {
      if (shortInfoController.text.isNotEmpty && selectedOption.trim().isNotEmpty) {
        setState(() {
          uploading = true;
        });
        // Uploading image
        String downloadUrl = await uploadImage(File(imageXFile!.path));
        // Save info to Firestore
        saveInfo(downloadUrl, shortInfoController.text, selectedOption.trim());
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please fill all the forms.",
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Please Pick an Image for Menu.",
          );
        },
      );
    }
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

    storageRef.UploadTask uploadTask = reference.child(uniqueIdName + ".jpg").putFile(mImageFile);

    storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return imageXFile == null ? defaultScreen() : menusUploadFormScreen();
  }
}
