import 'dart:io';
import 'package:cpton_food2go_sellers/Widgets/text_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  void sendMessage () async{
    if (_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  Future<void> sendImage() async {
    final XFile? imageFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      // Upload the image to Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child('chat_images').child(DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(File(imageFile.path));

      // Get the download URL once the image is uploaded
      String imageUrl = await (await uploadTask).ref.getDownloadURL();

      // Send the image URL along with the message
      await _chatService.sendMessage(widget.receiverUserID, imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(widget.receiverUserEmail,
          style: TextStyle(
              color: AppColors().white,
              fontFamily: "Poppins",
              fontSize: 12.sp
          ),),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
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

  // build message item
  Widget _buildMessageItems(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(data['senderEmail'], style: TextStyle(fontFamily: "Poppins", fontSize: 12.sp),),
            SizedBox(height: 5.sp),
            if (data['message'] != null && data['message'].toString().startsWith('http')) // Check if message is a URL (image)
              Image.network(data['message'], width: 150, height: 150),
            if (data['message'] != null && !data['message'].toString().startsWith('http')) // Display text message if not an image URL
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
        children: [
          IconButton(
            onPressed: sendImage,
            icon: Icon(Icons.image, size: 25.sp,),
          ),
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hint: 'Enter your Message',
            ),
          ),


          IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.send_rounded, size: 25.sp,
            color: AppColors().red,),
          ),
        ],
      ),
    );
  }
}
