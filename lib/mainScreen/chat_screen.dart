import 'package:cpton_food2go_sellers/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Widgets/Chat_page.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading....');
        }

        return Material(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return _buildUserListItem(snapshot.data!.docs[index]);
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Ensure the current user is not the customer themselves
    if (_auth.currentUser!.email != data['customersEmail']) {
      final customersUID = data['customersUID'];
      if (customersUID is String) {
        // Check if customersImageUrl is null
        final imageUrl = data['customerImageUrl'] as String?;
        final imageWidget = imageUrl != null
            ? CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        )
            : CircleAvatar(); // Provide a fallback avatar or leave it blank

        return ListTile(
          leading: imageWidget,
          title: Text(data['customersName'] ?? 'Customer'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => ChatPage(
                  receiverUserEmail: data['customersEmail'],
                  receiverUserID: customersUID,
                ),
              ),
            );
          },
        );
      } else {
        print('customersUID is not a String: $customersUID');
      }
    }

    return Container();
  }


  String _getChatRoomId(String otherUserId) {
    final userId = _auth.currentUser!.uid;
    List<String> ids = [userId, otherUserId];
    ids.sort();
    return ids.join("_");
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages",style:
          TextStyle(color: AppColors().white,
          fontSize: 12.sp,
          fontFamily: "Poppins"),),
        backgroundColor: AppColors().red,
      ),
      body: _buildUserList(),
    );
  }
}
