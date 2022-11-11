
import 'package:firebase_messaging_app/fcm/message.dart';
import 'package:firebase_messaging_app/fcm/message_helper.dart';
import 'package:flutter/material.dart';

import 'message.dart';


class PageListMessage extends StatefulWidget {
  const PageListMessage({Key? key}) : super(key: key);

  @override
  State<PageListMessage> createState() => _PageListMessageState();
}

class _PageListMessageState extends State<PageListMessage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of messages'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: FutureBuilder<List<MyNotificationMessage>?>(
          future: MessageHelper.readMessage(),
          builder: (context, snapshot){
            if(snapshot.hasError){
              return const Text('Có lỗi xãy ra!');
            }else{
              if(!snapshot.hasError){
                return const Text('Không có dữ liệu');
              }else{
                List<MyNotificationMessage>? listMessage = snapshot.data;
                return ListView.separated(
                  itemCount: listMessage!.length,
                  itemBuilder: ((context, index) => ListTile(
                    leading: Text(listMessage[index].from ?? 'Unknow'),
                    title:  Text(listMessage[index].title ?? 'No Title'),
                    subtitle: Column(
                      children: [
                        Text(listMessage[index].body ?? 'No body'),
                        Text(listMessage[index].time ?? 'Unknow')
                      ],
                    ),
                  )), separatorBuilder: (BuildContext context, int index) { return const Divider(thickness: 1,); },
                );
              }
            }
          },
        ),
      ),
    );
  }
}
