import 'dart:convert';

import 'package:cpton_food2go_sellers/global/global.dart';
import 'package:http/http.dart' as http;

class AssistantMethods
{
  sendNotificationToAllRidersNow(String deviceRegistrationToken, String orderId) async {
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };

    Map body = {
      "body": "Hurry!! there are new orders.",
      "title": "New Order arrived",
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "orderId": orderId,
    };

    Map officialNotificationFormat = {
      "notification": body,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    try {
      var responseNotification = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: header,
        body: jsonEncode(officialNotificationFormat),
      );
      // Handle response if needed
    } catch (e) {
      // Handle errors
      print('Failed to send notification: $e');
    }
  }

}