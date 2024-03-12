import 'dart:async';

import 'package:cpton_food2go_sellers/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';
import '../push notification/push_notification_system.dart';



class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}




class _MySplashScreenState extends State<MySplashScreen>
{

  startTimer()
  {


    Timer(const Duration(seconds: 5),()async{

      //if seller is already logged in

      if(firebaseAuth.currentUser != null)
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
      }
      //if seller is not logged in
      else
        {
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
        }


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


