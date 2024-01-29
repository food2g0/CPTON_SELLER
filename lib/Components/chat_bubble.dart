
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

class ChatBubble extends StatelessWidget {

  final String message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius:  BorderRadius.circular(8),
        color: AppColors().red,
      ),
      child: Text(
        message,
        style: TextStyle(
          fontFamily: "Poppins",
          color: AppColors().white,
          fontSize: 16.sp
        ),
      ),
    );
  }
}
