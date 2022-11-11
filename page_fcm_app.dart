

import 'package:firebase_messaging_app/fcm/pagehome_fcm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widget/widget_connect_firebase.dart';

class PageAppFCM extends StatelessWidget {
  const PageAppFCM({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyFirebaseConnect(
      errorMessage: 'Lỗi kết nối',
      connectingMessage: 'Đang kết nối',
      builder: (context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FCM App',
        home: PageHomeFCM(),
      ),
    );
  }
}
