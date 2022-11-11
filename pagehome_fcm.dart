

import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_app/fcm/message_helper.dart';
import 'package:firebase_messaging_app/fcm/page_fcm_mesage.dart';
import 'package:firebase_messaging_app/fcm/pagelist_message.dart';
import 'package:flutter/material.dart';


String authorization_key ='	AAAAnH9SG50:APA91bEyJa7TS-_TvX5FxRXkr80VBT9zWFmzXvngt2dJt0tPPJ-2W5y8RUE2RcFSwaRj6viWAf8nbLrqdbjjTh2jJyaIjlyDoazoUYyM4TdUSH-zH1Zx0ZcmxGs_GUXtbKqcfLDwI8Vy';
String topic = 'my_fcm_message';
class PageHomeFCM extends StatefulWidget {
  const PageHomeFCM({Key? key}) : super(key: key);

  @override
  State<PageHomeFCM> createState() => _PageHomeFCMState();
}

class _PageHomeFCMState extends State<PageHomeFCM> {
  int count = 10;
  int index = 0;
  String? token;
  String topicStatus = 'None';
  String incoming_message = 'No message';
  TextEditingController messageCtrl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //lấy mã thông báo fcm mặc định cho thiết bị này
    FirebaseMessaging.instance.getToken().then((value){
      print('Token message: $value');
      setState(() {
        token = value;
      });
    });

    //Đăng ký với topic
    FirebaseMessaging.instance.subscribeToTopic(topic).whenComplete((){
      setState(() {
        topicStatus = topic;
      });
    });

    //Lấy số lượng tin nhắn và cập nhật lên badge widget
    MessageHelper.getCountMessage().then((value){
      setState(() {
        count = value ;
      });
    });

    //sự kiện khi người dùng bấm vào tin nhắn trên thanh trạng thái
    //khi người dùng đang chạy dưới background

    FirebaseMessaging.onMessageOpenedApp.listen((removeMessage){
      MessageHelper.fcmOpenMessageHandler(
        context: context,
        message: removeMessage,
        messageHandler: (context, message){

          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PageFCM_Mesage(message: message),)
          );
        }
      );
    });
    //sự kiện khi người dùng bấm vào tin nhắn trên thanh trạng thái
    //khi người dùng đang ở trạng thái terminate

    FirebaseMessaging.instance.getInitialMessage().then((remoteMessage){
      if(remoteMessage != null){
        MessageHelper.fcmOpenMessageHandler(
            message: remoteMessage,
            context: context,
            messageHandler: (context, message){
              //Điều hướng tới trang hiển thị tin nhắn
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PageFCM_Mesage(message: message),)
              );
            }
        );
      }
    });

    //sự kiện khi người dùng bấm vào tin nhắn trên thanh trạng thái
    //khi người dùng đang ở trạng thái foreground

    FirebaseMessaging.onMessage.listen((remoteMessage){
      MessageHelper.fcm_ForegroundHandler(
          message: remoteMessage,
          context: context,
          messageHandler: (context, message){
            //Xử lí thêm việc nhận tn ở đây
            setState(() {
              incoming_message = message.notification?.body ?? 'Không có nội dung';
            });
            //Cập nhật hiển thị số lượng tn cho badge
            MessageHelper.getCountMessage().then((value){
              setState(() {
                count = value;
              });
            });
          }
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Demo'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value){
          if(value == 1 && count >0){
            setState(() {
              count =0;
            });
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PageListMessage(),)
            );
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.blue[800],),
            label: 'Home'
          ),
          BottomNavigationBarItem(
              icon: Badge(
                badgeColor: Colors.red,
                showBadge: count > 0,
                position: BadgePosition.topEnd(top: -12, end: -18),
                badgeContent: Text("$count", style: const TextStyle(color: Colors.white),),
                child: const Icon(Icons.message, color: Colors.green,),
              ),
              label: 'Messages'
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FCM token : $token'),
              const SizedBox(height: 10,),
              Text('Topic: $topicStatus'),
              const SizedBox(height: 10,),
              Text('Message: $incoming_message'),
              const SizedBox(height: 10,),
              Center(
                child: ElevatedButton(
                  child: Text('Subscribe to topic'),
                  onPressed: (){
                    FirebaseMessaging.instance.subscribeToTopic(topic).whenComplete((){
                      setState(() {
                        topicStatus = topic;
                      });
                    });
                  },
                ) ,
              ),
              Center(
                child: ElevatedButton(
                  child: Text('Unsubscribe from topic'),
                  onPressed: (){
                    FirebaseMessaging.instance.unsubscribeFromTopic(topic).whenComplete((){
                      setState(() {
                        topicStatus = 'None';
                      });
                    });
                  },
                ),
              ),
              TextField(
                controller: messageCtrl,
                decoration: const InputDecoration(label: Text('Nội dung tin nhắn')),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text('Send message to topic'),
                  onPressed: (){
                    String messageToSend = MessageHelper.constructFCMPayload(
                        content: messageCtrl.text,
                        to: topic,
                        topic: true);
                    MessageHelper.sendPushMessageByHTTP_Post(
                      authorization_key: authorization_key,
                      message: messageToSend,
                      token: token
                    );
                  },
                ) ,
              ),
              Center(
                child: ElevatedButton(
                  child: Text('Send message to myself'),
                  onPressed: (){
                    String messageToSend = MessageHelper.constructFCMPayload(
                        content: messageCtrl.text,
                        to: token!,
                        topic: false);
                    MessageHelper.sendPushMessageByHTTP_Post(
                        authorization_key: authorization_key,
                        message: messageToSend,
                        token: token
                    );
                  },
                ) ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
