import 'package:cpton_food2go_sellers/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  late User? _user;
  double totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    fetchEarnings();
  }

  void fetchEarnings() async {
    try {
      // Get the sales document for the current user for the month of March
      DocumentSnapshot<Map<String, dynamic>> salesSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(_user!.uid)
          .collection('sales')
          .doc('03_March')
          .get();

      // Check if the document exists
      if (salesSnapshot.exists) {
        // Extract the sale value from the document and update the total earnings
        setState(() {
          totalEarnings = salesSnapshot['saleVal'] ?? 0.0;
        });
      } else {
        // If the document doesn't exist, set earnings to 0
        setState(() {
          totalEarnings = 0.0;
        });
      }
    } catch (error) {
      print('Error fetching earnings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate 10% of total earnings
    double tenPercent = totalEarnings * 0.1;
    // Calculate earnings after deducting 10%
    double earningsAfterDeduction = totalEarnings - tenPercent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Earnings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors().green.withOpacity(0.5), // Set the opacity here
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Total Earnings',
                        style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '\Php $totalEarnings',
                        style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors().green.withOpacity(0.5), // Set the opacity here
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Deduction (10%)',
                        style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '\Php $earningsAfterDeduction',
                        style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors().green.withOpacity(0.5), // Set the opacity here
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        '10% Deduction',
                        style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '\Php $tenPercent',
                        style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Add spacing between the Row and the reminder text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors().white1,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Reminders: the 10% deduction serve as your rental to food2go application, failure to turnover the desired amount will face account termination or suspension',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
