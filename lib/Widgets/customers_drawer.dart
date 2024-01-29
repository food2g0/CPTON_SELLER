import 'package:flutter/material.dart';

import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';

class CustomersDrawer extends StatelessWidget {
  const CustomersDrawer({super.key });

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Colors.black87, // Set your desired background color here
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [
                // Header of the drawer
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(80)),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          sharedPreferences!.getString("sellersImageUrl")!,
                        ),
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
                  capitalize (sharedPreferences!.getString("sellersName")!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: "Roboto",
                  ),
                ),
                 )
                ),
              ],
            ),
          ),
          //body drawer
          ListTile(
            leading: const Icon(
              Icons.home_max_outlined,
              color: Colors.red,
            ),
            title: const Text("Home"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.motorcycle,
              color: Colors.red,
            ),
            title: const Text("History - Orders"),
            onTap: () {
              // Handle the Settings item tap
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.attach_money_outlined,
              color: Colors.red,
            ),
            title: const Text("My Earnings"),
            onTap: () {
              // Handle the About item tap
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.reorder_outlined,
              color: Colors.red,
            ),
            title: const Text("New Order"),
            onTap: () {
              // Handle the Favorites item tap
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            title: const Text("Logout"),
            onTap: () {
              firebaseAuth.signOut().then((value){
                Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
              });
            },
          ),
        ],
      ),
    );
  }
}
