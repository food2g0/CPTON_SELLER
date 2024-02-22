import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/authentication/signup_page.dart';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Widgets/custom_text_field.dart';
import '../Widgets/error_dialog.dart';
import '../Widgets/loading_dialog.dart';
import '../global/global.dart';
import '../mainScreen/confirmation_screen.dart';
import '../mainScreen/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //login
      loginNow();
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Please write email/password.",
          );
        },
      );
    }
  }

  loginNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingDialog(
          message: "Checking Credentials",
        );
      },
    );

    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: error.message.toString(),
          );
        },
      );
    });
    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future<void> readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        String status = snapshot.data()!["status"];

        if (status == "disapproved") {
          print("Status is disapproved: $status");
          // Status is disapproved, navigate to the ConfirmationScreen
          Navigator.pop(context);
          Route newRoute = MaterialPageRoute(
            builder: (c) => const ConfirmationScreen(),
          );
          Navigator.pushReplacement(context, newRoute);
        } else if (status == "approved") {
          // Status is approved, proceed to the HomeScreen
          await sharedPreferences!
              .setString("sellersUID", currentUser.uid);
          await sharedPreferences!
              .setString("sellersEmail", snapshot.data()!["sellersEmail"]);
          await sharedPreferences!
              .setString("sellersName", snapshot.data()!["sellersName"]);
          await sharedPreferences!.setString(
              "sellersImageUrl", snapshot.data()!["sellersImageUrl"]);

          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const HomeScreen()),
          );
        } else {
          firebaseAuth.signOut();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AuthScreen()),
          );

          showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "No record exists.",
              );
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors().white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: w,
              height: h * 0.4,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/log.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(8.0.w),
                child: Column(
                  children: [
                    CustomTextField(
                      data: Icons.email,
                      hintText: "Enter your Email",
                      keyboardType: TextInputType.text,
                      hintStyle: TextStyle(
                        color: AppColors().black1,

                        fontFamily: "Poppins",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      inputTextStyle: TextStyle(
                          fontFamily: "Poppins",
                          color: AppColors().black,
                          fontSize: 12.sp
                      ),
                      isObsecure: false,
                      controller: emailController,
                    ),
                    SizedBox(height: 15.h,),
                    CustomTextField(
                      data: Icons.password,
                      keyboardType: TextInputType.text,
                      hintText: "Enter your Password",
                      hintStyle: TextStyle(
                        color: AppColors().black1,
                        fontFamily: "Poppins",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      inputTextStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: AppColors().black,
                        fontSize: 12.sp
                      ),
                      isObsecure: !isPasswordVisible,
                      controller: passwordController,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors().black,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: w * 0.08),
            ElevatedButton(
              child: Text(
                "Login",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w)),
                backgroundColor: AppColors().red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                formValidation();
              },
            ),
            SizedBox(height: w * 0.08),
            RichText(
              text: TextSpan(
                text: "Don\'t have an account?",
                style: TextStyle(
                  color: AppColors().black1,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: "  Create!",
                    style: TextStyle(
                      color: AppColors().red,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          Get.to(() => const SignUpPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
