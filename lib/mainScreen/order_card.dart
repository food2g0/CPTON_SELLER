import 'package:cpton_food2go_sellers/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'order_details_screen.dart';


class OrderCard extends StatelessWidget {
  final int itemCount;
  final List<Map<String, dynamic>> data;
  final String orderID;
  final String sellerName;
  final String? paymentDetails;
  final String? totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final productData;
  final List<Map<String, dynamic>> data1;

  OrderCard({
    required this.itemCount,
    required this.data,
    required this.orderID,
    required this.sellerName,
    this.paymentDetails,
    this.totalAmount,
    required this.cartItems,
    this.productData, required,
    required this.data1 ,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: InkWell(
        onTap: ()  {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => OrderDetailsScreen(orderID: orderID)),
          );
        },
        child: Card(
          elevation: 1,
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return placedOrderDesignWidget(context, index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget placedOrderDesignWidget(BuildContext context, int index) {
  Map<String, dynamic> snapshot = data[index];
  return Container(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              cartItems[index]['thumbnailUrl'], // Use cartItems instead of data
              width: 50.w,
              height: 50.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItems[index]['productTitle'], // Use cartItems instead of data
                  style: TextStyle(
                    color: AppColors().black,
                    fontSize: 12.sp,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5,),

                Row(
                  children: [
                    Text(
                      "Price: ",
                      style: TextStyle(
                        color: AppColors().black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      cartItems[index]['productPrice'].toString(), // Use cartItems instead of data
                      style: TextStyle(
                        color: AppColors().black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "x ",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      cartItems[index]['itemCounter'].toString(), // Use cartItems instead of data
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.sp,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            // Handle button press (e.g., navigate to details screen)
          },
          child: Text(
            "View Details",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
        ),
      ],
    ),
  );
}

}
