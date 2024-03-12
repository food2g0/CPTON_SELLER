
import 'package:cpton_food2go_sellers/mainScreen/view_ratings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../colors.dart';
import '../global/global.dart';


class ItemDetailsScreen extends StatefulWidget {
  final dynamic model;
  final String? sellersUID;

  const ItemDetailsScreen({Key? key, required this.model, this.sellersUID}) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {


  late String customersUID; // Declare customersUID without initialization
  String selectedVariationPrice = '';
  String selectedFlavorsPrice = '';
  String selectedVariationName = ''; // Define selected variation name
  String selectedFlavorsName = '';


  void updateItemStatus(BuildContext context, bool isOutOfStock) {
    String productsID = widget.model.productsID; // Get the product ID
    String newStatus = isOutOfStock ? "out of stock" : "available";

    // Update status in the menu's 'items' collection
    final menuItemsRef = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("sellersUID"))
        .collection("menus")
        .doc(widget.model!.menuID)
        .collection("items");

    menuItemsRef.doc(productsID).update({"status": newStatus})
        .then((_) {
      // Handle success
      print('Item status updated to $newStatus in menu\'s items collection');
      showToast("Item status updated successfully");
    }).catchError((error) {
      // Handle error
      print('Error updating item status in menu\'s items collection: $error');
    });

    // Update status in the 'items' collection
    final itemsRef = FirebaseFirestore.instance.collection("items");

    itemsRef.doc(productsID).update({"status": newStatus})
        .then((_) {
      // Handle success
      print('Item status updated to $newStatus in items collection');
      showToast("Item status updated successfully");
    }).catchError((error) {
      // Handle error
      print('Error updating item status in items collection: $error');
    });

    setState(() {
      // Update the widget model
      widget.model.status = newStatus;
    });
  }




  void performStatusUpdate(BuildContext context, bool isOutOfStock) {
    String productsID = widget.model.productsID; // Get the product ID

    // Define the status based on the current status
    String status = isOutOfStock ? 'available' : 'out of stock';

    // Update status in the menu's 'items' collection
    final menuItemsRef = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("sellersUID"))
        .collection("menus")
        .doc(widget.model!.menuID)
        .collection("items");

    menuItemsRef.doc(productsID).update({"status": status}).then((_) {
      // Handle success
      print('Item status updated to $status in menu\'s items collection');
      showToast("Item status updated successfully");
    }).catchError((error) {
      // Handle error
      print('Error updating item status in menu\'s items collection: $error');
    });

    // Update status in the 'items' collection
    final itemsRef = FirebaseFirestore.instance.collection("items");

    itemsRef.doc(productsID).update({"status": status}).then((_) {
      // Handle success
      print('Item status updated to $status in items collection');
      showToast("Item status updated successfully");
    }).catchError((error) {
      // Handle error
      print('Error updating item status in items collection: $error');
    });
  }


  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }



  @override
  void initState() {
    super.initState();
    customersUID = getCurrentUserUID(); // Initialize customersUID in initState
    print('Debug: customersUID in initState: $customersUID');
  }

  String getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      print('Debug: User is not signed in. Returning default UID.');
      return 'default_uid';
    }
  }

  // Function to calculate average rating from Firestore document snapshots
  double calculateAverageRating(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) return 0.0;

    var ratings = docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as num?)
        .toList();

    double averageRating = 0;
    if (ratings.isNotEmpty) {
      var totalRating = ratings
          .map((rating) => rating ?? 0)
          .reduce((a, b) => a + b);
      averageRating = totalRating / ratings.length;
    }

    return averageRating;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.model?.thumbnailUrl ?? 'default_image_url.jpg';

    return Scaffold(
      backgroundColor: AppColors().white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200.0), // Set the preferred height of the AppBar
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0, // Remove elevation
          flexibleSpace: Container(
            decoration: BoxDecoration(
            ),
            child: ClipRRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),

                ],
              ),
            ),
          ),

        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), // Adjust the radius as needed
            topRight: Radius.circular(20.0), // Adjust the radius as needed
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 15.0.h),
                  // Product Title, Price, and Ratings
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFF890010), width: 1.0),
                        borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.fastfood_outlined, size: 20.0.sp, color: AppColors().red),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  (widget.model!.productTitle.length > 20)
                                      ? ' ${widget.model!.productTitle.substring(0, 20)}...'
                                      : ' ${widget.model!.productTitle}',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors().black,
                                  ),
                                ),
                              ),

                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Image.asset(
                                'images/icons/peso.png',
                                width: 14.w,
                                height: 14.h,
                                color: AppColors().red,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                ' ${selectedVariationPrice != '' ? selectedVariationPrice : widget.model.productPrice?.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors().black1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0.h),
                          buildRatingSection(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h,),
                  Container(
                    color: Colors.white,
                    height: 50.h,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.delivery_dining, size: 24.sp, color: AppColors().red),
                          Text(
                            "  Cost ",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors().black),
                          ),
                          Text(
                            ' Php: 50',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  // Product Description
                  Container(
                    color: AppColors().white,
                    child: Padding(
                      padding: EdgeInsets.all(16.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, size: 15.0.sp),
                              SizedBox(width: 10.0.w),
                              Text(
                                "Product Description",
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors().black),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0.h),
                          SingleChildScrollView(
                            child: Text(
                              widget.model.productDescription!,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 10.sp,
                                color: AppColors().black1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Product Reviews
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      children: [
                        Icon(Icons.reviews, size: 15.0.sp),
                        SizedBox(width: 10.0.w),
                        Text(
                          "Product Reviews",
                          style: TextStyle(
                              color: AppColors().black,
                              fontSize: 10.sp,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10.0.w),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c)=>ViewRatings()));
                          },
                          child: Text(
                            'View All Reviews',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors().red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Display Single Review
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("items")
                        .doc(widget.model.productsID)
                        .collection("itemRecord")
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(
                        ));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      var reviews = snapshot.data!.docs.map((doc) {
                        final rating = (doc.data() as Map<String, dynamic>)['rating'] as num?;
                        final comment = (doc.data() as Map<String, dynamic>)['comment'] as String?;
                        final userName = (doc.data() as Map<String, dynamic>)['userName'] as String?;
                        return {'rating': rating, 'comment': comment, 'userName': userName};
                      }).toList();

                      // Display Single Review
                      if (reviews.isNotEmpty) {
                        return buildReviewItem(reviews[0]);
                      } else {
                        return Container(); // No reviews to display
                      }
                    },
                  ),
                ],
                ),
              ),
            ]
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors().white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                bool isOutOfStock = widget.model.status == 'out of stock'; // Check if the current status is out of stock
                // Call the function to update the status
                updateItemStatus(context, !isOutOfStock);
              },
              child: Text(
                widget.model.status == 'out of stock' ? 'Restock' : 'Out of Stock',
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors().white
                ),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.model.status == 'out of stock' ? Colors.green : AppColors().red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  )
              ),
            ),
          ],
        ),
      ),


    );




  }


  Widget buildReviewItem(Map<String, dynamic> reviewData) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors().red,
                    child: Text(
                      (reviewData['userName'] as String?)?.substring(0, 1) ?? '?',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User', // Replace 'User' with the actual user's name
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors().black1,
                        ),
                      ),
                      SizedBox(height: 5),
                      SmoothStarRating(
                        rating: (reviewData['rating'] as num?)?.toDouble() ?? 0.0,
                        allowHalfRating: false,
                        starCount: 5,
                        size: 16.sp,
                        color: Colors.yellow,
                        borderColor: Colors.black45,
                      ),
                      Text(
                        'Comment: ${(reviewData['comment'] as String?) ?? ""}',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: AppColors().black1,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget buildRatingSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("items")
          .doc(widget.model.productsID)
          .collection("itemRecord")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        double averageRating = calculateAverageRating(snapshot.data!.docs);

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Row(
                  children: [
                    SmoothStarRating(
                      rating: averageRating,
                      allowHalfRating: false,
                      starCount: 5,
                      size: 25,
                      color: Colors.yellow,
                      borderColor: Colors.black45,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '${averageRating.toStringAsFixed(2)}/5.00',
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: AppColors().black1,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }


}