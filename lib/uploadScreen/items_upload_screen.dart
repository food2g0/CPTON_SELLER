import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import '../Widgets/error_dialog.dart';
import 'package:path/path.dart' as path;

import '../global/global.dart';
import '../mainScreen/home_screen.dart';
import '../models/menus.dart';

class ItemsUploadScreen extends StatefulWidget {
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
  bool hasVariation = false; // Flag to determine if the product has variations

  List<Map<String, dynamic>> variations = []; // List to store variations and prices

  List<Map<String, dynamic>> flavors = []; // List to store dynamically added flavors

  Widget defaultScreen() {
    return Material(
      child: Scaffold(
        backgroundColor: AppColors().white,
        appBar: AppBar(
          backgroundColor: AppColors().red,
          automaticallyImplyLeading: true,
          title: Text(
            "Add New Products",
            style: TextStyle(
              color: AppColors().white,
              fontSize: 12.sp,
              fontFamily: "Poppins",
            ),
          ),
        ),
        body: Container(
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
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors().white,
                      fontSize: 12.sp,
                      fontFamily: "Poppins",
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      AppColors().red,
                    ),
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
      imageQuality: 50,
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

  Widget menusUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        automaticallyImplyLeading: true,
        actions: [],
        title: Text(
          "Uploading New Products",
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors().white,
          ),
        ),
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
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Product Has Variation?',
                style: TextStyle(fontFamily: "Poppins", fontSize: 12.sp),
              ),
              Switch(
                value: hasVariation,
                onChanged: (value) {
                  setState(() {
                    hasVariation = value;
                  });
                },
              ),
            ],
          ),
          // Conditionally render buildVariationInputs() based on hasVariation flag
          if (hasVariation) buildVariationInputs(),
          SizedBox(height: 20),
          // Input fields for title, description, quantity, and price
          ListTile(
            leading: Icon(Icons.fastfood, color: AppColors().red),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: AppColors().black1),
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(
                    color: AppColors().black1,
                    fontSize: 12.sp,
                    fontFamily: "Poppins",
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: AppColors().red),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: AppColors().black1),
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(
                    color: AppColors().black1,
                    fontSize: 12.sp,
                    fontFamily: "Poppins",
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart, color: AppColors().red),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: AppColors().black1),
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: "Quantity",
                  hintStyle: TextStyle(
                    color: AppColors().black1,
                    fontSize: 12.sp,
                    fontFamily: "Poppins",
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.attach_money, color: AppColors().red),
            title: Container(
              width: 250,
              child: TextFormField(
                style: TextStyle(color: AppColors().black1),
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: "Price",
                  hintStyle: TextStyle(
                    color: AppColors().black1,
                    fontSize: 12.sp,
                    fontFamily: "Poppins",
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          // Button to add new flavor
          ElevatedButton(
            onPressed: uploading ? null : () => uploadValidateForm(),
            child: Text(
              "Upload Products",
              style: TextStyle(
                color: AppColors().white,
                fontSize: 12.sp,
                fontFamily: "Poppins",
              ),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w))),
          ),
        ],
      ),
    );
  }

  Widget buildVariationInputs() {
    return Column(
      children: [
        // Iterate through the list of variations and build input fields for each
        for (int i = 0; i < variations.length; i++)
          Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.fastfood,
                  color: AppColors().red,
                ),
                title: Container(
                  width: 250,
                  child: TextFormField(
                    style: TextStyle(color: AppColors().black1),
                    onChanged: (value) {
                      setState(() {
                        variations[i]['name'] = value; // Update variation name
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Variation",
                      hintStyle: TextStyle(
                        color: AppColors().black1,
                        fontSize: 12.sp,
                      ),
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
                title: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      variations[i]['price'] = value; // Update variation price
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(
                      color: AppColors().black1,
                      fontSize: 12.sp,
                      fontFamily: "Poppins",
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),

        // Button to add new variation
        ElevatedButton(
          onPressed: () {
            setState(() {
              variations.add({'name': '', 'price': ''}); // Add new variation
            });
          },
          child: Text(
            "Add Variations",
            style: TextStyle(
              color: AppColors().white,
              fontSize: 12.sp,
              fontFamily: "Poppins",
            ),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors().red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w))),
        ),
        SizedBox(height: 20),
        // Dynamic flavor inputs
        for (int i = 0; i < flavors.length; i++)
          Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.fastfood,
                  color: AppColors().red,
                ),
                title: Container(
                  width: 250,
                  child: TextFormField(
                    style: TextStyle(color: AppColors().black1),
                    onChanged: (value) {
                      setState(() {
                        flavors[i]['name'] = value; // Update flavor name
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Flavor",
                      hintStyle: TextStyle(
                        color: AppColors().black1,
                        fontSize: 12.sp,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),

        // Button to add new flavor
        ElevatedButton(
          onPressed: () {
            setState(() {
              flavors.add({'name': ''}); // Add new flavor
            });
          },
          child: Text(
            "Add Flavor",
            style: TextStyle(
              color: AppColors().white,
              fontSize: 12.sp,
              fontFamily: "Poppins",
            ),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors().red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w))),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  clearMenusUploadForm() {
    setState(() {
      imageXFile = null;
    });
  }

  uploadValidateForm() async {
    if (imageXFile != null) {
      setState(() {
        uploading = true;
      });
      String downloadUrl = await uploadImage(File(imageXFile!.path));
      saveInfo(downloadUrl);
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

  saveInfo(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("sellersUID"))
        .collection("menus")
        .doc(widget.model!.menuID)
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
      "variations": variations,
      "flavors": flavors, // Include flavors in the saved data
    }).then((value) {
      final itemsRef = FirebaseFirestore.instance.collection("items");

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
        "variations": variations,
        "flavors": flavors, // Include flavors in the saved data
      });
    }).then((value) {
      clearMenusUploadForm();
      setState(() {
        uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
        uploading = false;
      });
    });
  }

  uploadImage(mImageFile) async {
    storageRef.Reference reference = storageRef.FirebaseStorage.instance
        .ref()
        .child("items");

    storageRef.UploadTask uploadTask = reference
        .child(uniqueIdName + ".jpg")
        .putFile(mImageFile);

    storageRef.TaskSnapshot taskSnapshot =
    await uploadTask.whenComplete(() {});

    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return imageXFile == null ? defaultScreen() : menusUploadFormScreen();
  }
}
