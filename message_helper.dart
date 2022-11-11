

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'message.dart';

class MessageHelper{

  static String key_massage_list = 'fcm_messages';
  static String key_count_message = 'count_message';



  //lấy số lượng tin nhắn đã ghi
  static Future<int> getCountMessage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return (sharedPreferences.getInt(key_count_message) ?? 0);
  }

  //ghi lại mess nhận đc khi ở background
  static Future<bool> writeMessage(MyNotificationMessage notifMessage) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? strMessage = sharedPreferences.getStringList(key_massage_list);
    int count = (sharedPreferences.getInt(key_count_message) ?? 0) +1;
    FlutterAppBadger.updateBadgeCount(count);
    await sharedPreferences.setInt(key_count_message, count);
    if(strMessage != null){
      strMessage.add(jsonEncode(notifMessage));
      return sharedPreferences.setStringList(key_massage_list, strMessage);
    }else{
      return sharedPreferences.setStringList(key_massage_list, [jsonEncode(notifMessage)]);
    }
  }

  //đọc thông báo tư shared Preference
  static Future<List<MyNotificationMessage>?> readMessage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? strMessage = sharedPreferences.getStringList(key_massage_list);
    sharedPreferences.remove(key_massage_list);
    sharedPreferences.remove(key_count_message);
    //xoá số lượng trên icon
    FlutterAppBadger.removeBadge();
    return strMessage?.map((strUserMessage) => MyNotificationMessage.fromJson (jsonDecode(strUserMessage))).toList();
  }

  static Future<void> fcm_BackgroundHandler(RemoteMessage message)async{
    //xử lí tn nhận được ở trạng thái background
    print('Handling a background message ${message.messageId}');
  }

  //nhận tin nhắn ở foreground
  static void fcm_ForegroundHandler({
    required RemoteMessage message,
    required BuildContext context,
    void Function(BuildContext context, RemoteMessage message)? messageHandler
  }){
    writeMessage(
        MyNotificationMessage(
            title: message.notification?.title,
            body: message.notification?.body,
            from: message.from,
            time: message.sentTime.toString()
        )
    );
    if(messageHandler != null){
      messageHandler(context,message);
    }else{
      print('Message write in foreground');
    }
  }

  //mở tin nhắn từ thông báo
  static void fcmOpenMessageHandler({
    required RemoteMessage message,
    required BuildContext context,
    //***
    void Function(BuildContext context, RemoteMessage message)? messageHandler
  }){
    print('Open fcm message');
    if(messageHandler != null){
      messageHandler(context,message);
    }else{
      print('Message write in foreground');
    }
  }

  //mở list tn trong app
  static void fcm_OpenAllMessageHandler({
    required BuildContext context,
    void Function(BuildContext context, List<MyNotificationMessage>)? messageHandler
  }) async {
    List<MyNotificationMessage>? list = await readMessage();
    if(messageHandler != null){
      messageHandler(context, list!);
    }
  }


  //gửi tin nhắn
  static String constructFCMPayload({
    required content, required String to, required bool topic
  }){
    String address = to;
    if(topic){
      //***
      address = '/topics/$to';
    }

    return jsonEncode(
        {
          'to': address,
          'priority': 'high',
          'data': <String, dynamic>{
            'via': 'FlutterFire cloud messaging!!!'
          },
          'notification': <String, dynamic>{
            'title': 'Hello FlutterFire',
            'body': content,
            'sound': 'true'
          },
        });
  }
  static Future<Response> sendPushMessageByHTTP_Post({
    String? message,
    //token ứng dụng đang gửi thông báo
    String? token,
    String? authorization_key
  }) async{
    if(token == null){
      print('Unable to send FCM message, no token exists');
      return Future.error('Chưa có token');
    }
    try{
      Response response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type' : 'application/json',
          //***
          'Authorization' : 'key=${authorization_key!}'
        },
        body: message,
      );
      print('FCM request for device send!');
      return response;
    }catch(e){
      print(e);
      return Future.error(e);
    }
  }
}