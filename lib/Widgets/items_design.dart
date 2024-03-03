import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/Widgets/Dimensions.dart';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:cpton_food2go_sellers/mainScreen/edit_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../global/global.dart';
import '../mainScreen/item_details_screen.dart';
import '../models/items.dart';

class ItemsDesignWidget extends StatefulWidget {
  final Items? model;
  final BuildContext? context;

  const ItemsDesignWidget({Key? key, this.model, this.context});

  @override
  State<ItemsDesignWidget> createState() => _ItemsDesignWidgetState();
}


class _ItemsDesignWidgetState extends State<ItemsDesignWidget> {
  @override
  Widget build(BuildContext context) {

    void deleteItem() async {
      try {
        // Get the current user's sellersUID
        String? sellersUID = sharedPreferences!.getString("sellersUID");

        if (sellersUID != null) {
          // Delete the item document from the 'menus' collection
          await FirebaseFirestore.instance
              .collection("sellers")
              .doc(sellersUID)
              .collection("menus")
              .doc(widget.model!.menuID)
              .collection("items")
              .doc(widget.model!.productsID)
              .delete();

          // Delete the item document from the 'items' collection
          await FirebaseFirestore.instance
              .collection("items")
              .doc(widget.model!.productsID)
              .delete();

          // Optionally, you can add a success message or perform any other actions
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Menu and associated items deleted successfully")),
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



    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemDetailsScreen(model: widget.model)));
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                height: 100,
                width: 170,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.w),
                  child: Image.network(
                    widget.model!.thumbnailUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 10),
              // Add some space between the image and text/icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fastfood_outlined,
                    color: Colors.amber,
                    size: 12.sp,
                  ),
                  SizedBox(width: 4),
                  Text(
                    widget.model!.productTitle!,
                    style: TextStyle(
                      color: AppColors().black,
                      fontSize: 12.sp,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // Center the icon and text horizontally
                children: [
                  Image.asset('images/icons/peso.png',
                      width: 20.w,
                      height: 20.h,
                      color: AppColors().red),
                  SizedBox(width: 4),
                  Text(
                    'Php. ' + widget.model!.productPrice.toString() + '.00',
                    style: TextStyle(
                      color: AppColors().black1,
                      fontSize: 12.sp,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditItemScreen(item: widget.model!),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit),
                    color: AppColors().green, // Set the color of the icon as needed
                    iconSize: 24.sp, // Set the size of the icon as needed
                  ),

                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // Handle the button tap
                      deleteItem();
                    },
                    icon: Icon(Icons.delete),
                    color: AppColors().red, // Set the color of the icon to red
                    iconSize: 24.sp, // Set the size of the icon as needed
                  ),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}