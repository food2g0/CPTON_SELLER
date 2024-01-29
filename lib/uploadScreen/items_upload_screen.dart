import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import '../Widgets/error_dialog.dart';
import 'package:path/path.dart' as path;

import '../global/global.dart';
import '../mainScreen/home_screen.dart';
import '../models/menus.dart';

class ItemsUploadScreen extends StatefulWidget
{
  final Menus? model;

  ItemsUploadScreen({this.model});


  @override
  State<ItemsUploadScreen> createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen> {
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();


  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;

  clearMenusUploadForm() {
    setState(() {
      imageXFile = null;
    });
  }

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
            "Add New Products",
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
                    "Add New Products",
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
      if (fileExtension.toLowerCase() == '.png' ||
          fileExtension == '.jpg' ||
          fileExtension == '.jpeg') {
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
          SingleChildScrollView(
            child: Container(
              height: 280,
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
          ),
          SizedBox(height: 30,),
          ListTile(
            leading: Icon(Icons.fastfood,
                color: Colors.red[700]),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined,
                color: Colors.red[700]),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.attach_money,
              color: Colors.red[700],
            ),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: priceController, // Use priceController for the price input
                keyboardType: TextInputType.number, // Set the keyboard type to number
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly // Allow only digits
                ],
                decoration: InputDecoration(
                  hintText: "Price",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.shopping_cart,
              color: Colors.red[700],
            ),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: quantityController, // Use quantityController for the quantity input
                keyboardType: TextInputType.number, // Set the keyboard type to number
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly // Allow only digits
                ],
                decoration: InputDecoration(
                  hintText: "Quantity",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Center(
            child: SizedBox(
              width: 150, // Set the width as desired
              child: ElevatedButton(
                onPressed: uploading ? null : () => uploadValidateForm(),
                child: Text("Upload Products"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),

            ),
          ),



        ],
      ),
    );
  }

  uploadValidateForm() async {
    if (imageXFile != null) {
      if (descriptionController.text.isNotEmpty && titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
        setState(() {
          uploading = true;
        });
        //uploading image
        String downloadUrl = await uploadImage(File(imageXFile!.path));
        //save info to fireStore
        saveInfo(downloadUrl);
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
  // Method to delete the item


  saveInfo(
      String downloadUrl
      ) {
    final ref = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("sellersUID"))
        .collection("menus").doc(widget.model!.menuID)
        .collection("items");

    ref.doc(uniqueIdName).set({
      "productsID": uniqueIdName,
      "menuID": widget.model!.menuID,
      "sellersUID": sharedPreferences!.getString("sellersUID"),
      "sellersName": sharedPreferences!.getString("sellersName"),
      "productDescription": descriptionController.text.toString(),
      "productTitle": titleController.text.toString(),
      "productPrice": int.parse(priceController.text),
      "productQuantity": int.parse(quantityController.text),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl,
    }).then((value) {
      final itemsRef = FirebaseFirestore.instance
          .collection("items");

      itemsRef.doc(uniqueIdName).set({
        "productsID": uniqueIdName,
        "menuID": widget.model!.menuID,
        "sellersUID": sharedPreferences!.getString("sellersUID"),
        "sellersName": sharedPreferences!.getString("sellersName"),
        "productDescription": descriptionController.text.toString(),
        "productTitle": titleController.text.toString(),
        "productPrice": int.parse(priceController.text),
        "productQuantity": int.parse(quantityController.text),
        "publishedDate": DateTime.now(),
        "status": "available",
        "thumbnailUrl": downloadUrl,
      });
    }).then((value){
    clearMenusUploadForm();
    setState(() {
      uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
      uploading = false;
    });
    });
  }


  uploadImage(mImageFile) async {
    storageRef.Reference reference = storageRef.FirebaseStorage.instance.ref()
        .child("items");

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