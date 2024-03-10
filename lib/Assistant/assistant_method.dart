import 'dart:convert';

import 'package:cpton_food2go_sellers/global/global.dart';
import 'package:http/http.dart' as http;

class AssistantMethods
{
  static sendNotificationToUserNow(String registrationToken, String orderId) async {
    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };

    Map bodyNotification = {
      "body": "Your order is ready to pick and ready to be delivered.",
      "title": "Order is ready to pick"
    };

    Map dataMap = {
      "clcik_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "ToPay",
      "orderId": orderId
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": registrationToken,
    };

    var responseNotification = await http.post( // Await the http.post() call
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );

    // Handle response if needed
    if (responseNotification.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${responseNotification.statusCode}');
      print('Response body: ${responseNotification.body}');
    }
  }

}