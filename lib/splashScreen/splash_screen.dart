import 'dart:async';

import 'package:flutter/material.dart';


import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';



class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}




class _MySplashScreenState extends State<MySplashScreen>
{

  startTimer()
  {


    Timer(const Duration(seconds: 1),()async{

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
        color: Colors.black,
        child: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(

                padding: const EdgeInsets.all(8.0),
                child: Image.asset("images/splashscreen.png"),
              ),

              const   SizedBox(height: 10,),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 40,
                    fontFamily: "Signatra",
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


