
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';
import '../push notification/push_notification_system.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}


class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();

    readCurrentSellerInformation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (appBar:
    AppBar(
      backgroundColor: AppColors().red,
      title: Text(
        "Waiting for Confirmation",
        style: TextStyle(
            fontSize: 10.sp,
            color: AppColors().white,
            fontFamily: "Poppins"
        ),
      ),
    ),
      body: Center(
        child: Text("Were validating your account please wait...",
          style: TextStyle(
              fontSize: 10.sp,
              fontFamily: "Poppins",
              color: AppColors().black1
          ),),
      ),
    );
  }
  readCurrentSellerInformation()async
  {
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging();
    pushNotificationSystem.generatingAndGetToken();
  }
}