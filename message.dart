

class MyNotificationMessage{
  String? title, body, from, time;

  MyNotificationMessage({this.from, this.title, this.body, this.time});

  Map<String, dynamic> toJson(){
    return {
      'title' : title,
      'body' : body,
      'from' : from,
      'time' : time
    };
  }

  factory MyNotificationMessage.fromJson(Map<String, dynamic> json){
    return MyNotificationMessage(
      title: json['title'] as String,
      body: json['body'] as String,
      from: json['from'] as String,
      time: json['time'] as String,
    );
  }
}