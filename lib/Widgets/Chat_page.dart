import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/Widgets/text_field.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Components/chat_bubble.dart';
import '../colors.dart';
import '../services/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({required this.receiverUserEmail, required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage () async{
    if (_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);

      // clear controller
      _messageController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(widget.receiverUserEmail),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(),
          ),
          _builMessageInput(),

          SizedBox(height: 20.sp,)
        ],
      ),
    );
  }
  // build message list
  Widget _buildMessageList(){
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot){
          if (snapshot.hasError){
            return Text('Error${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Text('Loading..');
          }
          return ListView(
            children: snapshot.data!.docs.map((document) => _buildMessageItems(document)).toList(),
          );

        });
  }

  //build message item
  Widget _buildMessageItems(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic >;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,

          mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            SizedBox(height: 5.sp,),
            ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }


  // build message input
  Widget _builMessageInput(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        //text Field
        children: [
          Expanded(child:
          MyTextField(
            controller: _messageController,
            hint: 'Enter your Message',
          ),
          ),
          IconButton(onPressed: sendMessage,
              icon: Icon
                (Icons.send,size: 25.sp,))
        ],
      ),
    );
  }
}
