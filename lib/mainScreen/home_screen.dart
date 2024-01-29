import 'package:cpton_food2go_sellers/Widgets/Dimensions.dart';
import 'package:cpton_food2go_sellers/mainScreen/chat_screen.dart';
import 'package:cpton_food2go_sellers/mainScreen/products_screen.dart';
import 'package:flutter/material.dart';
import '../Widgets/customers_drawer.dart';
import '../colors.dart';
import '../global/global.dart';
import '../uploadScreen/menus_upload_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;


  final List<Widget> _screens = [
    HomeTab(),
    HistoryTab(),
    Container(),
    NewOrderTab(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey,
      drawer: const CustomersDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors().red,
        automaticallyImplyLeading: true,
        actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen()));
            },
              icon: Container(
                width: 26,
                height: 26,
                child: Image.asset('images/icons/bubble-chat.png',color: Colors.white,),
              ),)
        ],

        title: Text(
          sharedPreferences!.getString("sellersName")!,
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // Adjust the height as needed
          child: Container(
            height: 40,
            color: Colors.black,
            child: Center(
              child:
                Text(
                  "Dashboard",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: Dimensions.font18,
                    fontFamily: "Poppins",

                  ),
                ),

            ),
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors().dark, AppColors().DarkBlue], // Adjust colors as needed
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Sales',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                          color: AppColors().white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Php: 1,000 ',
                        style: TextStyle(
                          fontSize: Dimensions.font20,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          color: AppColors().white,
                        ),
                      ),
                    ],
                  ),
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
                  color: Colors.white70,
                  child: Padding(
                    padding:  EdgeInsets.all(Dimensions.height10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Dimensions.height10),
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 24,
                              color: Color(0xFF721F1F),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Transaction Summary',
                              style: TextStyle(
                                fontSize: Dimensions.font14,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Card(
                              color: AppColors().DarkBlue,
                              child: Container(
                                width: Dimensions.width100,
                                height: Dimensions.height100,
                                child:Padding(
                                  padding: EdgeInsets.all(Dimensions.height5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                      Text(
                                        'Products',
                                        style: TextStyle(
                                          fontSize: Dimensions.font12,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w500,
                                          color: AppColors().yellow,
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                              ),
                            ),

                            Card(
                              color: AppColors().DarkBlue,
                              child: Container(
                                width: Dimensions.width100,
                                height: Dimensions.height100,
                                child:Padding(
                                  padding:  EdgeInsets.all(Dimensions.height5),
                                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        Text(
                                          'Total Order',
                                          style: TextStyle(
                                            fontSize: Dimensions.font12,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.w500,
                                            color: AppColors().yellow,
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: AppColors().DarkBlue,
                              child: Container(
                                width: Dimensions.width100,
                                height: Dimensions.height100,
                                child:Padding(
                                  padding:  EdgeInsets.all(Dimensions.height5),
                                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        Text(
                                          'Cancelled',
                                          style: TextStyle(
                                            fontSize: Dimensions.font12,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.w500,
                                            color: AppColors().yellow,
                                          ),
                                        ),
                                      ]
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
                child: Container(
                  color: Colors.white70,
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
                            primary: AppColors().red, // Background color
                            onPrimary: Colors.white, // Text color
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
                            primary: AppColors().red, // Background color
                            onPrimary: Colors.white, // Text color
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
          )






// ...



          // stream builder here


        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor:
              AppColors().red, // Set the background color of the navigation bar
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;

              // Check if the "Add Products" tab is pressed and navigate to the Add Products page
              if (index == 2) {
                _navigateToAddProducts(context);
              }
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Container(
                width: 25,
                height: 25,
                child: Image.asset('images/icons/home.png',color: Colors.white,),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 25,
                height: 25,
                child: Image.asset('images/icons/history.png',color: Colors.white,),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 25,
                height: 25,
                child: Image.asset('images/icons/add-to-cart.png',color: Colors.white,),
              ),
              label: 'Add Products',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 25,
                height: 25,
                child: Image.asset('images/icons/notification.png',color: Colors.white,),
              ),
              label: 'Notification',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddProducts(BuildContext context) {
    // Navigate to the Add Products page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenusUploadScreen(),
      ),
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
