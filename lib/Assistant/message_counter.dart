import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageCounter extends ChangeNotifier {
  int _messageCounter = 0;

  int get count => _messageCounter;

  Future<void> displayMessageCounter() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Listen for real-time updates to the chat_rooms collection
      FirebaseFirestore.instance
          .collection("chat_rooms")
          .where("receiverId", isEqualTo: userId)
          .where("status", isEqualTo: "not seen")
          .snapshots()
          .listen((querySnapshot) {
        _messageCounter = querySnapshot.size;

        print('Message counter updated: $_messageCounter');

        // Notify listeners
        notifyListeners();
      });
    } catch (e) {
      print("Error fetching messages: $e");
      _messageCounter = 0;
    }
  }
}
