import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewRatings extends StatefulWidget {
  const ViewRatings({Key? key}) : super(key: key);

  @override
  State<ViewRatings> createState() => _ViewRatingsState();
}

class _ViewRatingsState extends State<ViewRatings> {
  late Future<List<Map<String, dynamic>>?> sellersRecords;

  @override
  void initState() {
    super.initState();
    sellersRecords = fetchSellersRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Ratings'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: sellersRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          List<Map<String, dynamic>>? records = snapshot.data;
          if (records == null || records.isEmpty) {
            return Center(
              child: Text('No ratings available.'),
            );
          }
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              var record = records[index];
              return ListTile(
                title: Text('Rating: ${record['rating']}'),
                subtitle: Text('Comment: ${record['comment']}'),
              );
            },
          );
        },
      ),
    );
  }
}

Future<List<Map<String, dynamic>>?> fetchSellersRecords() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(user.uid) // Assuming the current user ID is the seller's document ID
          .collection('sellersRecord')
          .get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } else {
      // User is not logged in
      return null;
    }
  } catch (e) {
    // Handle any errors
    print('Error fetching sellers records: $e');
    return null;
  }
}

