import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/Widgets/Dimensions.dart';
import 'package:cpton_food2go_sellers/mainScreen/chat_screen.dart';
import 'package:cpton_food2go_sellers/mainScreen/products_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Widgets/customers_drawer.dart';
import '../colors.dart';
import '../global/global.dart';
import '../uploadScreen/menus_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      AppColors.contentColorCyan,
      AppColors.contentColorBlue,
    ];

    bool showAvg = false;
    return Scaffold(
      backgroundColor: AppColors().white1,
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
                style: TextStyle(color: AppColors().black1, fontSize: 14.sp, fontFamily: "Poppins"),
                children: [
                  TextSpan(
                    text: sellerName,
                    style: TextStyle(color: AppColors().red, fontSize: 14.sp, fontFamily: "Poppins"),
                  ),
                ],
              ),
            );
          },
        ),
        iconTheme: IconThemeData(color: AppColors().black),
        backgroundColor: AppColors().white1,
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
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('sellers').doc(sellersUID).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        var earnings = snapshot.data!.get('earnings') ?? 0.0; // Default value if earnings is null
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Sales',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                                color: AppColors().black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '\Php $earnings',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontFamily: "Poppins",
                                color: AppColors().black,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Stack(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1.70,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 18,
                              left: 12,
                              top: 24,
                              bottom: 12,
                            ),
                            child: LineChart(
                              showAvg ? avgData() : mainData(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          height: 34,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                showAvg = !showAvg;
                              });
                            },
                            child: Text(
                              'avg',
                              style: TextStyle(
                                fontSize: 12,
                                color: showAvg ?AppColors().red : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                            fontSize: Dimensions.font14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: AppColors().red,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height10,
                            horizontal: Dimensions.width20,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenusUploadScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Add Products',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: Dimensions.font14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: AppColors().red,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height10,
                            horizontal: Dimensions.width20,
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

  void _navigateToAddProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenusUploadScreen(),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontFamily: "Poppins"
    );
    late Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('Jan', style: style);
        break;
      case 5:
        text = const Text('Feb', style: style);
        break;
      case 8:
        text = const Text('March', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 10,
      fontFamily: "Poppins"
    );
    late String text;
    switch (value.toInt()) {
      case 1:
        text = '100';
        break;
      case 3:
        text = '500';
        break;
      case 5:
        text = '1000';
        break;
      default:
        return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    List<Color> gradientColors = [
      AppColors.contentColorCyan,
      AppColors.contentColorBlue,
    ];

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 40.w,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots:  [
            FlSpot(2.9, 2),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
            FlSpot(0, 0),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppColors().red,
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors().red,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 10,
      maxX: 11,
      minY: 10,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 0),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: AppColors().green, end: AppColors().green)
                  .lerp(0.2)!,
              ColorTween(begin: AppColors().green, end: AppColors().green)
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: AppColors().green, end: AppColors().green)
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: AppColors().green, end: AppColors().green)
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
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
