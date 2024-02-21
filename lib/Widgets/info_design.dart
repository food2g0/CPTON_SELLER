import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../global/global.dart';
import '../mainScreen/items_screen.dart';
import '../models/menus.dart';

class InfoDesignWidget extends StatefulWidget {
  final Menus? model;
  final BuildContext? context;

  const InfoDesignWidget({super.key, this.model, this.context});

  @override
  State<InfoDesignWidget> createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {

  void deleteMenu() async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion",
        style: TextStyle(fontFamily: "Poppins",
        fontSize: 20.sp,
        color: AppColors().red),),
        content: Text("Are you sure you want to delete this menu?",
        style: TextStyle(
          fontFamily: "Poppins"
        ),),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog and return false to indicate cancellation
              Navigator.pop(context, false);
            },
            child: Text("Cancel", style: TextStyle(
              color: AppColors().black,
              fontFamily: "Poppins"
            ),),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog and return true to indicate confirmation
              Navigator.pop(context, true);
            },
            child: Text("Delete",style: TextStyle(
    color: AppColors().red,
    fontFamily: "Poppins"
    ),),
          ),
        ],
      ),
    );

    // If user confirms deletion, proceed with deletion
    if (confirmDelete == true) {
      try {
        // Get the current user's sellersUID
        String? sellersUID = sharedPreferences!.getString("sellersUID");

        if (sellersUID != null) {
          // Delete the menu document from Firestore
          await FirebaseFirestore.instance
              .collection("sellers")
              .doc(sellersUID)
              .collection("menus")
              .doc(widget.model!.menuID) // Use the current menu's ID
              .delete();

          // Optionally, you can add a success message or perform any other actions
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Menu deleted successfully")),
          );
        }
      } catch (error) {
        // Handle any errors that occur during deletion
        print("Error deleting menu: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete menu")),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemsScreen(model: widget.model)));
      },
      splashColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          color: AppColors().white1,
          elevation: 2,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, // Set a fixed width for the image
                    height: 100, // Set a fixed height for the image
                    child: Image.network(
                      widget.model!.thumbnailUrl!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 10), // Add some space between the image and title
                  Text(
                    widget.model!.menuTitle!, // Display the menu title
                    style: TextStyle(
                      color: AppColors().black,
                      fontSize: 12.sp, // Increase font size for the title
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600, // Set title font weight to bold
                    ),
                  ),
                  SizedBox(height: 10), // Add some space between the title and buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle delete button press
                          deleteMenu();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.w)
                          ),
                          primary: AppColors().red, // Set delete button color
                        ),
                        icon: Icon(Icons.delete,
                        color: AppColors().black,), // Delete button icon
                        label: Text(
                          'Delete', // Delete button text
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12.sp,
                            color: AppColors().white
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10), // Add some space between the buttons and bottom edge
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}


