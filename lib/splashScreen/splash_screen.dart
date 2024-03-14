import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreen/confirmation_screen.dart';
import '../mainScreen/home_screen.dart';
import '../push notification/push_notification_system.dart';



class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}




class _MySplashScreenState extends State<MySplashScreen>
{

  startTimer() {
    Timer(const Duration(seconds: 5), () async {
      // Check if the user is logged in
      if (firebaseAuth.currentUser != null) {
        // If the user is logged in, check their status
        await checkUserStatus();
      } else {
        // If the user is not logged in, navigate to the authentication screen
        Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
      }
    });
  }

// Method to check user status
  Future<void> checkUserStatus() async {
    final currentUser = firebaseAuth.currentUser!;
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        String status = snapshot.data()!["status"];
        if (status == "disapproved") {
          // If status is disapproved, navigate to the confirmation screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const ConfirmationScreen()));
        } else {
          // If status is approved or any other status, navigate to the home screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
        }
      } else {
        // If no record exists, navigate to the authentication screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
      }
    }).catchError((error) {
      // Handle errors
      print("Error checking user status: $error");
      // If there's an error, navigate to the authentication screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();

  }


  @override
  Widget build(BuildContext context) {
    return Material(

      child: Container(
        color: AppColors().black,
        child: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(

                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 150.h,
                    width: 150.w,
                    child: Image.asset("images/delivery.png")),
              ),

              const   SizedBox(height: 10,),

             Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Welcome food2go merchant",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors().white,
                    fontSize: 10.sp,
                    fontFamily: "Poppins",
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

}


