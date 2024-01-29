import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _fireBaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _fireBaseAuth.currentUser!.uid;
    final String currentUserEmail = _fireBaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    // Create new Message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
      messageId: message,
    );

    // Construct chat room id from current user
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");




    // Add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    // Update or create chat room with the latest message
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'chatId': chatRoomId,
      'lastMessage': newMessage.message,
      'timestamp': timestamp,
      'senderEmail': currentUserEmail,
      'receiverId': receiverId,
    });
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
