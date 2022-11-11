import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_app/fcm/message_helper.dart';
import 'package:flutter/material.dart';

import 'fcm/page_fcm_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(MessageHelper.fcm_BackgroundHandler);

//yêu cầu cấp quyền nhận tin nhắn trên thiết bị apple
  await FirebaseMessaging.instance
  .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true
  );

  //yêu cầu cấp quyền nhận tin nhắn

  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true
  );

  print('User granted permission: ${settings.authorizationStatus}');

  runApp(const PageAppFCM());
}

