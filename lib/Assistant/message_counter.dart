import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../global/global.dart';

class ChatRoomProvider extends ChangeNotifier {
  int _unseenMessagesCount = 0;

  int get unseenMessagesCount => _unseenMessagesCount;

  Future<void> fetchUnseenMessagesCount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      print('userID : $userId');

      // Listen for real-time updates to the chat_rooms collection
      FirebaseFirestore.instance
          .collection("chat_rooms")
          .where("receiverId", isEqualTo: userId)
          .where("status", isEqualTo: "not seen")
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          _unseenMessagesCount = 0;
        } else {
          _unseenMessagesCount = querySnapshot.size;
        }


        // Notify listeners
        notifyListeners();
      });
    } catch (e) {
      print("Error fetching messages: $e");
      _unseenMessagesCount = 0;
    }
  }
}