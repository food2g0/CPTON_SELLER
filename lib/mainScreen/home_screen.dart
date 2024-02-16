import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/Widgets/Dimensions.dart';
import 'package:cpton_food2go_sellers/mainScreen/chat_screen.dart';
import 'package:cpton_food2go_sellers/mainScreen/products_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../Widgets/customers_drawer.dart';
import '../Widgets/error_dialog.dart';
import '../colors.dart';
import '../global/global.dart';
import '../models/Sales.dart';
import '../uploadScreen/menus_upload_screen.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'order_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  int _currentIndex = 0;
  late String sellersUID = '';

  @override
  void initState() {
    super.initState();
    fetchSellersUID();
  }

  Future<void> getOrderDetails() async {
    try {
      // Fetch all order documents from the "orders" collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("orders").get();

      // Check if there are any documents returned
      if (querySnapshot.docs.isNotEmpty) {
        // Iterate through each document
        for (DocumentSnapshot orderDoc in querySnapshot.docs) {
          // Retrieve the order ID
          String orderID = orderDoc.id;
          // Retrieve the orderBy field
          String customerUID = orderDoc["orderBy"];
          // Now you can use the orderID and customerUID as needed
          print("Order ID: $orderID, Ordered By: $customerUID");
        }
      } else {
        print("No order documents found.");
      }
    } catch (e) {
      print("Error fetching order details: $e");
    }
  }

  Future<void> confirmedParcelShipment(String orderID, String customerUID) async {
    try {
      // Get a reference to the order document using the provided orderID
      DocumentReference orderRef = FirebaseFirestore.instance.collection("orders").doc(orderID);

      // Update the status of the order to "accepted"
      await orderRef.update({
        "status": "accepted",
      });

      DocumentReference customerOrderRef = FirebaseFirestore.instance.collection("users").doc(customerUID).collection("orders").doc(orderID);

      await customerOrderRef.update({
        "status": "accepted",
      });

      // Get the updated order snapshot
      DocumentSnapshot orderSnapshot = await orderRef.get();

      // Check if the order is already accepted by another rider
      String currentStatus = orderSnapshot["status"];
      String updatedRiderUID = orderSnapshot["riderUID"];

      if (currentStatus == "accepted" && updatedRiderUID != sharedPreferences!.getString("uid")) {
        // Parcel has already been accepted by another rider
        Fluttertoast.showToast(
          msg: "Parcel has already been accepted by another rider",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print("Error confirming parcel shipment: $e");
    }
  }

  void fetchSellersUID() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        sellersUID = user.uid;
      });
    }
  }

  List<charts.Series<Sales, String>> _seriesBarData = [];

  late List<Sales> myData;

  _generateData(myData) {
    _seriesBarData.add(
      charts.Series(
        domainFn: (Sales sales, _) => sales.saleYear.toString(),
        measureFn: (Sales sales, _) => sales.saleVal,
        colorFn: (Sales sales, _) => charts.ColorUtil.fromDartColor(Color(int.parse(sales.colorVal))),
        id: 'Sales',
        data: myData,
        labelAccessorFn: (Sales row, _) => "${row.saleYear}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white,
      drawer: const CustomersDrawer(),
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('sellers').doc(sellersUID).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Welcome", style: TextStyle(color: AppColors().black1, fontSize: 12.sp));
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            var sellerName = snapshot.data!.get('sellersName');
            return RichText(
              text: TextSpan(
                text: 'Welcome, ',
                style: TextStyle(color: AppColors().black, fontSize: 14.sp, fontFamily: "Poppins"),
                children: [
                  TextSpan(
                    text: sellerName,
                    style: TextStyle(color: AppColors().white, fontSize: 14.sp, fontFamily: "Poppins"),
                  ),
                ],
              ),
            );
          },
        ),
        iconTheme: IconThemeData(color: AppColors().black),
        backgroundColor: AppColors().red,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
            },
            icon: Container(
              width: 26,
              height: 26,
              child: Image.asset('images/icons/bubble-chat.png', color: AppColors().black),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [

          SliverList(
            delegate: SliverChildListDelegate(
              [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('sellers').doc(sellersUID).collection("sales").snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LinearProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text('No data available');
                    } else {
                      List<Sales> sales = snapshot.data!.docs.map((documentSnapshot) => Sales.fromMap(documentSnapshot.data() as Map<String, dynamic>)).toList();
                      print(sales);
                      return _buildChart(context, sales);
                    }
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: EdgeInsets.all(Dimensions.height10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      color: AppColors().white1,
                      child: Padding(
                        padding: EdgeInsets.all(Dimensions.height10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: Dimensions.height10),
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 24,
                                  color: AppColors().red,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Transaction Summary',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold,
                                    color: AppColors().black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Card(
                                  elevation: 2,
                                  child: Container(
                                    width: Dimensions.width100,
                                    height: Dimensions.height100,
                                    child: Padding(
                                      padding: EdgeInsets.all(5.h),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Products',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w600,
                                              color: AppColors().red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  elevation: 2,
                                  child: Container(
                                    width: 110.w,
                                    height: 100.h,
                                    child: Padding(
                                      padding: EdgeInsets.all(5.w),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total Order',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w600,
                                              color: AppColors().red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Dimensions.height10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.height10),
                    child: Padding(
                      padding: EdgeInsets.all(Dimensions.height10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'View Products',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors().white,
                              backgroundColor: AppColors().red,
                              fixedSize: Size(160.w, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0.w),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => MenusUploadScreen()));

                            },
                            child: Text(
                              'Add Menu',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors().white,
                              backgroundColor: AppColors().red,
                              fixedSize: Size(160.w, 50.h), // Set width and height as needed
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Text("New Order"),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("orders").where("status", isEqualTo: "normal").orderBy("orderTime", descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              // Extract orders data from snapshot
              List<DocumentSnapshot> orders = snapshot.data!.docs;

              // Build your UI using the orders data
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
                          itemCount: 1, // Only one product
                          data: [firstProduct], // Pass the first product as a list
                          orderID: orderID,
                          sellerName: "", // Pass the seller's name
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
          )



        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppColors().black,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
              if (index == 2) {
                _navigateToAddProducts(context);
              }
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Container(
                width: 20.w,
                height: 20.h,
                child: Image.asset('images/icons/home.png', color: Colors.white),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 20.w,
                height: 20.h,
                child: Image.asset('images/icons/history.png', color: Colors.white),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 20.w,
                height: 20.h,
                child: Image.asset('images/icons/add-to-cart.png', color: Colors.white),
              ),
              label: 'Add Products',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 20.w,
                height: 20.h,
                child: Image.asset('images/icons/notification.png', color: Colors.white),
              ),
              label: 'Notification',
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey, // Change as needed
          selectedLabelStyle: TextStyle(
            fontFamily: 'Poppins', // Change the font family as needed
            fontSize: 10.sp, // Change the font size as needed
            fontWeight: FontWeight.bold, // Change the font weight as needed
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins', // Change the font family as needed
            fontSize: 10.sp, // Change the font size as needed
            fontWeight: FontWeight.normal, // Change the font weight as needed
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<Sales> sales) {
    myData = sales;
    _generateData(myData);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Container(
          height: 300, // Set a finite height
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  "Sales by Month",
                  style: TextStyle(
                    color: AppColors().black,
                    fontFamily: "Poppins",
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Expanded(
                  child: charts.BarChart(
                    _seriesBarData,
                    animate: true,
                    animationDuration: Duration(seconds: 2),
                    primaryMeasureAxis: charts.NumericAxisSpec(
                      renderSpec: charts.GridlineRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          fontSize: 6, // Adjust the font size as needed
                          color: charts.MaterialPalette.black, // Adjust the font color as needed
                          fontFamily: 'Poppins', // Change the font family to your desired font
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddProducts(BuildContext context) {}
}

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Tab Content'),
    );
  }
}

class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('History Tab Content'),
    );
  }
}

class NewOrderTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('New Order Tab Content'),
    );
  }
}
