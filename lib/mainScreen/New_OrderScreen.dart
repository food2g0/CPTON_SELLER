import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';
import 'order_card.dart';


class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({Key? key}) : super(key: key);

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}
Future<String?> getCurrentUserID() async {
  // Get the current user from Firebase Authentication
  User? user = FirebaseAuth.instance.currentUser;

  // Check if the user is logged in
  if (user != null) {
    // Return the user ID
    return user.uid;
  } else {
    // User is not logged in, return null
    return null;
  }
}



class _NewOrderScreenState extends State<NewOrderScreen> {
  String? currentUserId;
  @override
  void initState() {
    super.initState();

    // Call the method to get the current user ID
    getCurrentUserID().then((userId) {
      // Assign the user ID to currentUserId
      setState(() {
        currentUserId = userId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text("New Order",style:
          TextStyle(
            color: AppColors().white,
            fontSize: 12.sp,
          ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CustomScrollView(
          slivers: [

            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  "New Order",
                  style: TextStyle(
                    color: AppColors().black,
                    fontSize: 12.sp,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("orders")
                  .where("status", isEqualTo: "normal")
                  .where("sellerUID", isEqualTo: currentUserId)
              // Add more conditions if needed
                  .orderBy("orderTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }

                // Extract orders data from snapshot
                List<DocumentSnapshot> orders = snapshot.data!.docs;

                // Filter orders based on conditions
                orders = orders
                    .where((order) => order.get("status") == "normal")
                // Add more conditions if needed
                    .toList();

                // Build your UI using the filtered orders data
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      // Extract order details from each document snapshot
                      String orderID = orders[index].id;
                      dynamic productsData = orders[index].get("products");
                      List<Map<String, dynamic>> productList = [];
                      if (productsData != null && productsData is List) {
                        productList = List<Map<String, dynamic>>.from(productsData);
                      }

                      print("Order ID: $orderID, Product List: $productList");

                      // Display only the first product in the OrderCard
                      Map<String, dynamic> firstProduct = {};
                      if (productList.isNotEmpty) {
                        firstProduct = productList.first;
                      }

                      return Column(
                        children: [
                          OrderCard(
                            data1: productList,
                            itemCount: 1,
                            // Only one product
                            data: [firstProduct],
                            // Pass the first product as a list
                            orderID: orderID,
                            sellerName: "",
                            // Pass the seller's name
                            paymentDetails: orders[index].get("paymentDetails"),
                            totalAmount: orders[index].get("totalAmount").toString(),
                            cartItems: productList, // Pass the full products list if needed
                          ),
                          SizedBox(height: 10), // Adjust the height as needed
                        ],
                      );
                    },
                    childCount: orders.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
