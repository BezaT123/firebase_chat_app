class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentTime;
  final MessageType messageType;
  var duration;
  Message({
    required this.senderId,
    required this.receiverId,
    required this.sentTime,
    required this.content,
    required this.messageType,
    this.duration,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(
        receiverId: json['receiverId'],
        senderId: json['senderId'],
        sentTime: json['sentTime'].toDate(),
        content: json['content'],
        messageType:
            MessageType.fromJson(json['messageType']),
        duration: json['duration']?? "",
      );

  Map<String, dynamic> toJson() => {
        'receiverId': receiverId,
        'senderId': senderId,
        'sentTime': sentTime,
        'content': content,
        'messageType': messageType.toJson(),
        'duration': duration
      };
}

enum MessageType {
  text,
  image,
  audio;

  String toJson() => name;

  factory MessageType.fromJson(String json) =>
      values.byName(json);
}
