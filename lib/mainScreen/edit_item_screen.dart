import 'dart:io';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:cpton_food2go_sellers/mainScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Service/items_service.dart';
import '../models/items.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;

class EditItemScreen extends StatefulWidget {
  final Items item;

  EditItemScreen({required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final ItemsService _itemsService = ItemsService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  File? imageFile; // Variable to hold the new image file

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.productTitle!;
    descriptionController.text = widget.item.productDescription!;
    priceController.text = widget.item.productPrice.toString();
    quantityController.text = widget.item.productQuantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Edit Item',
          style: TextStyle(
            color: AppColors().white,
            fontSize: 12.sp,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the existing or updated image
            if (imageFile != null)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(imageFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Button to pick a new image
            ElevatedButton(
              onPressed: () => _pickImage(),
              child: Text('Pick New Image',
              style: TextStyle(
                color: AppColors().white,
                fontSize: 12.sp,
                fontFamily: "Poppins"
              ),),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),

                )
              ),
            ),
            // Other input fields for title, description, price, and quantity
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            // Save changes button
            SizedBox( height: 20.h,),
            ElevatedButton(
              onPressed: () => _updateItemDetails(),
              child: Text('Save Changes'
       ,
                style: TextStyle(
                    color: AppColors().white,
                    fontSize: 12.sp,
                    fontFamily: "Poppins"
                ),),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors().red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),

                  )
              ),
            ),

          ],
        ),
      ),
    );
  }

  // Function to pick a new image
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  // Function to update item details
  // Function to update item details
  void _updateItemDetails() async {
    try {
      String? downloadUrl; // Declare downloadUrl variable

      // Show circular progress indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Check if a new image has been selected
      if (imageFile != null) {
        // Upload the new image
        downloadUrl = await _uploadImage(imageFile!);

        // Assign the new download URL to the thumbnailUrl property
        widget.item.thumbnailUrl = downloadUrl;
      }

      // Update other item details
      final updatedItem = widget.item.copyWith(
          productTitle: titleController.text,
          productDescription: descriptionController.text,
          productPrice: double.parse(priceController.text).toInt(),
          productQuantity: int.parse(quantityController.text),
          thumbnailUrl: downloadUrl // Use downloadUrl here
      );

      // Update the item data in the database
      await _itemsService.updateItemData(updatedItem);
      await _itemsService.updateItemDataInItems(updatedItem);

      // Close the progress dialog
      Navigator.pop(context);

      // Navigate back to the home screen
      Navigator.pop(context);

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Item details updated successfully!'),
      ));
    } catch (error) {
      print('Error updating item details: $error');
      // Close the progress dialog
      Navigator.pop(context);
      // Show an error message if something went wrong
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating item details. Please try again later.'),
      ));
    }
  }







  // Function to upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    final storageRef.Reference reference = storageRef.FirebaseStorage.instance.ref().child("items");
    final uploadTask = reference.child("${DateTime.now().millisecondsSinceEpoch}.jpg").putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
}
