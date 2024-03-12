import 'package:cpton_food2go_sellers/mainScreen/Earnings_screen.dart';
import 'package:cpton_food2go_sellers/mainScreen/History_Screen.dart';
import 'package:cpton_food2go_sellers/mainScreen/New_OrderScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';
import '../mainScreen/ProfileScreen.dart';

class CustomersDrawer extends StatefulWidget {
  const CustomersDrawer({Key? key});

  @override
  State<CustomersDrawer> createState() => _CustomersDrawerState();
}

class _CustomersDrawerState extends State<CustomersDrawer> {
  late String _imageUrl = ''; // Store the imageUrl in state

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('sellers').doc(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          _imageUrl = snapshot.data()!['sellersImageUrl'] ?? ''; // Get the imageUrl from Firestore
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(80)),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircleAvatar(
                        backgroundImage: _imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : AssetImage('assets/default_avatar.png') as ImageProvider<Object>?,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      capitalize(sharedPreferences!.getString("sellersName")!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.person,
              color: Colors.red,
            ),
            title: const Text("Profile",style: TextStyle( fontFamily: "Poppins",),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.motorcycle,
              color: Colors.red,
            ),
            title: const Text("History - Orders",style: TextStyle( fontFamily: "Poppins",),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.attach_money_outlined,
              color: Colors.red,
            ),
            title: const Text("My Earnings",style: TextStyle( fontFamily: "Poppins",),),
            onTap: () {
              // Handle the About item tap
              Navigator.push(context, MaterialPageRoute(builder: (c)=> EarningsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.reorder_outlined,
              color: Colors.red,
            ),
            title: const Text("New Order",style: TextStyle( fontFamily: "Poppins",),),
            onTap: () {
              // Handle the Favorites item tap
              Navigator.push(context, MaterialPageRoute(builder: (context) => NewOrderScreen()));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            title: const Text("Logout",style: TextStyle( fontFamily: "Poppins",),),
            onTap: () {
              firebaseAuth.signOut().then((value) {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
              });
            },
          ),
        ],
      ),
    );
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
