
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageFCM_Mesage extends StatelessWidget {

  RemoteMessage message;
  PageFCM_Mesage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Info'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message.notification!.title!),
          Text(message.from!),
          Text(message.notification!.body!),
          Text('${message.sentTime}'),
        ],
      ),
    );
  }
}
