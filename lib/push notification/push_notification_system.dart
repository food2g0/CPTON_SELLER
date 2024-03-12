import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PushNotificationSystem {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initializeCloudMessaging() async {
    // Terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        // Display the order request
        print("This is remote Message:: ");
        print(remoteMessage.data["status"]);

        // Call the appropriate method to handle the message
        // readUserOrderInformation(remoteMessage.data["status"]);
      }
    });

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      // Handle foreground messages
      print("This is remote Message:: ");
      print(remoteMessage.data["status"]);
      // Call the appropriate method to handle the message
      // readUserOrderInformation(remoteMessage.data["status"]);

      // You can also display a notification or update the UI here
      // depending on your app's requirements
    });

    // Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      // Handle background messages
      print("This is remote Message:: ");
      print(remoteMessage.data["status"]);
      // Call the appropriate method to handle the message
      // readUserOrderInformation(remoteMessage.data["status"]);
    });
  }




  // readUserOrderInformation(String currentUser)
  // {
  //   FirebaseFirestore.instance.collection("sellers")
  //       .doc(currentUser).get().then((snapData)
  //   {
  //     if(snapData.exists){
  //       String status = (snapData.exists as Map)["status"];
  //
  //     }else
  //     {
  //       Fluttertoast.showToast(msg: "This order is not exist");
  //     }
  //   });
  // }


  Future<String?> generatingAndGetToken() async {
    String? registrationToken;

    try {
      registrationToken = await messaging.getToken();

      if (registrationToken != null && registrationToken.isNotEmpty) {
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('sellers')
            .doc(currentUserId)
            .update({
          'registrationToken': registrationToken,
        });
        print('Registration token saved successfully: $registrationToken');
        print("FCM Registration Token: ");
        print(registrationToken);
      } else {
        print('Failed to get registration token');
      }
    } catch (e) {
      print('Failed to save registration token: $e');
    }

    // Subscribe to topics
    messaging.subscribeToTopic("allRiders");
    messaging.subscribeToTopic("allUsers");
    messaging.subscribeToTopic("allSellers");

    return registrationToken;
  }
}
