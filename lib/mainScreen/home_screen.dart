import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/Widgets/Dimensions.dart';
import 'package:cpton_food2go_sellers/mainScreen/chat_screen.dart';
import 'package:cpton_food2go_sellers/mainScreen/products_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../Widgets/customers_drawer.dart';
import '../Widgets/error_dialog.dart';
import '../colors.dart';
import '../global/global.dart';
import '../models/Sales.dart';
import '../uploadScreen/menus_upload_screen.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

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

  void fetchSellersUID() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        sellersUID = user.uid;
      });
    }
  }
  List<charts.Series<Sales, String>> _seriesBarData = [];

  late List<Sales>  myData;

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
          SliverToBoxAdapter(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('sellers').doc(sellersUID)
                          .collection("sales").snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return LinearProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No data available');
                        } else {
                          List<Sales> sales = snapshot.data!.docs
                              .map((documentSnapshot) => Sales.fromMap(documentSnapshot.data() as Map<String, dynamic>))
                              .toList();
                          print(sales);
                          return _buildChart(context, sales);
                        }
                      },
                    ),


                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
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
          ),
          SliverToBoxAdapter(
            child: Padding(
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
                          foregroundColor: AppColors().white, backgroundColor: AppColors().red,
                          fixedSize: Size(160.w, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0.w),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c)=>MenusUploadScreen()));
                        },
                        child: Text(
                          'Add Menu',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12.sp,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors().white, backgroundColor: AppColors().red,
                          fixedSize: Size(160.w, 50.h), // Set width and height as needed
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Set border radius as needed
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
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



  Widget _buildChart(BuildContext context, List<Sales> sales){
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




  void _navigateToAddProducts(BuildContext context) {

  }
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
