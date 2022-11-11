
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyFirebaseConnect extends StatefulWidget {

  final Widget Function(BuildContext context)? builder;
  final String? errorMessage;
  final String? connectingMessage;
  const MyFirebaseConnect({Key? key,
    required this.connectingMessage,
    required this.errorMessage,
    required this.builder}) : super(key: key);

  @override
  State<MyFirebaseConnect> createState() => _MyFirebaseConnectState();
}

class _MyFirebaseConnectState extends State<MyFirebaseConnect> {
  bool loi = false;
  bool ketnoi = false;
  @override
  Widget build(BuildContext context) {
    if(loi){
      return
          Container(
            color: Colors.white,
            child: Center(
              child: Text(widget.errorMessage!),
            ),
          );
    }else{
      if(!ketnoi){
        return
          Container(
            color: Colors.white,
            child: Center(
              child: Text(widget.connectingMessage!),
            ),
          );
      }else{
        return widget.builder!(context);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _khoiTaoFirebase();
  }
  _khoiTaoFirebase() async {
    try{
      await Firebase.initializeApp();
      setState(() {
        ketnoi = true;
      });
    }catch(e){
      print(e);
      setState(() {
        loi = true;
      });
    }
  }
}


