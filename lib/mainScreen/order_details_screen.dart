import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/Assistant/assistant_method.dart';
import 'package:cpton_food2go_sellers/mainScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../Widgets/progress_bar.dart';
import '../colors.dart';
import '../global/global.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String? orderID;

  OrderDetailsScreen({this.orderID});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String orderStatus = "";
  String orderByUser = "";
  String sellerId = "";
  String products = "";
  String paymentDetails = "";
  late Future<DocumentSnapshot> _orderInfoFuture;
  String? get orderId => widget.orderID;
  static String? _token;
  @override
  void initState() {
    super.initState();
    _orderInfoFuture = getOrderInfo();

  }

  Future<DocumentSnapshot> getOrderInfo() {
    return FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID)
        .get();
  }

  void sendNotificationToUserNow(String orderId, String orderBy) {
    FirebaseFirestore.instance.collection("users").doc(orderBy).get().then((DocumentSnapshot snap) {
      if (snap.exists) {
        Map<String, dynamic>? userData = snap.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('registrationToken')) {
          String registrationToken = userData['registrationToken'] as String;

          //send notification
          AssistantMethods.sendNotificationToUserNow(registrationToken, orderId,);


          if (registrationToken.isNotEmpty) {
            // Send notification using the registrationToken
            print('Registration token found: $registrationToken');
            // Call your notification sending function here with the registrationToken
          } else {
            print('Registration token not found or empty.');
          }
        } else {
          print('Registration token not found in user data.');
        }
      } else {
        print('User document not found for order by: $orderBy');
      }
    }).catchError((error) {
      print("Error retrieving user document: $error");
    });
  }




  Future<DocumentSnapshot> getCustomerInfo(String customerId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(orderByUser)
        .get();
  }
  Future<void> confirmedParcelShipment(BuildContext context,) async {
    try {
      // Get a reference to the order document
      DocumentReference orderRef = FirebaseFirestore.instance.collection("orders").doc(widget.orderID);

      // Update the order status to "accepted" and set the rider details
      await orderRef.update({
        "status": "To Pick",
      });

      DocumentReference orderRefs = FirebaseFirestore.instance.collection("users").doc(orderByUser)
          .collection("orders").doc(widget.orderID);

      await orderRefs.update({
        "status": "To Pick",
      });

      // Show toast if update is successful
      Fluttertoast.showToast(
        msg: "Order status updated successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors().black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      // Show toast if there's an error
      Fluttertoast.showToast(
        msg: "Error updating order status: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors().black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Order Details",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors().white,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: _orderInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: circularProgress());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            Map? dataMap = snapshot.data!.data()! as Map<String, dynamic>;
            orderStatus = dataMap["status"].toString();
            orderByUser = dataMap["orderBy"].toString();
            sellerId = dataMap["sellerUID"].toString();
            products = dataMap["products"].toString();
            paymentDetails = dataMap["paymentDetails"].toString();

            List<Map<String, dynamic>> productList =
            List<Map<String, dynamic>>.from(dataMap["products"]);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Text(
                    "Total Amount (including shipping fee): Php ${dataMap?["totalAmount"]}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Text(
                    "Payment: ${dataMap?["paymentDetails"]}",
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                        color: AppColors().black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Order Id = ${widget.orderID!}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Order at: ${DateFormat("dd MMMM, yyyy - hh:mm aa").format(
                      DateTime.fromMillisecondsSinceEpoch(
                        int.parse(dataMap?["orderTime"]),
                      ),
                    )}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors().black1,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors().white,
                      borderRadius: BorderRadius.all(Radius.circular(5.w))
                    ),

                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> product = productList[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              product["thumbnailUrl"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            product["productTitle"],
                            style: TextStyle(
                              color: AppColors().black,
                              fontFamily: "Poppins",
                              fontSize: 12.sp,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price: ${product["productPrice"]}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontFamily: "Poppins",
                                  color: AppColors().black,
                                ),
                              ),
                              Text(
                                "Quantity: ${product["itemCounter"]}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontFamily: "Poppins",
                                  color: AppColors().black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors().white,
                        borderRadius: BorderRadius.all(Radius.circular(5.w))
                    ),
                    width: MediaQuery.of(context).size.width * 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: getCustomerInfo(orderByUser),
                        builder: (context, customerSnapshot) {
                          if (customerSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: circularProgress());
                          }
                          if (customerSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${customerSnapshot.error}'));
                          }
                          Map? customerData =
                          customerSnapshot.data!.data()! as Map<String, dynamic>;
                          String customerName =
                              customerData?["customersName"] ?? "N/A";
                          String customerEmail =
                              customerData?["customersEmail"] ?? "N/A";
                          String customerPhone =
                              customerData?["phone"] ?? "N/A";

                          return Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Customer Details",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                SizedBox(height: 12.h,),
                                Text(
                                  "Name: $customerName",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                SizedBox(height: 5.h,),
                                Text(
                                  "Email: $customerEmail",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                SizedBox(height: 5.h,),
                                Text(
                                  "Phone: $customerPhone",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100.h,),
                Center(
                  child: ElevatedButton(onPressed: (){
                    sendNotificationToUserNow(orderId!, orderByUser);
                    confirmedParcelShipment(context);
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
                  },
                      child: Text("Ready to pick up",
                      style: TextStyle(
                        color: AppColors().white,
                        fontFamily: "Poppins",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500
                      ),),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors().white,
                        backgroundColor: AppColors().red,
                        fixedSize: Size(190.w, 60.h), // Set width and height as needed
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                )
              ],

            );

          },

        ),

      ),
    );
  }
}
