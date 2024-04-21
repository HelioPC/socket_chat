import 'dart:convert';

class Message {
  final int id;
  final String content;
  final int userId;
  final int groupChatId;
  final String createdAt;
  final String updatedAt;

  Message({
    required this.id,
    required this.content,
    required this.userId,
    required this.groupChatId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      content: map['content'],
      userId: map['userId'],
      groupChatId: map['groupChatId'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'groupChatId': groupChatId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Message.fromJson(String source) {
    return Message.fromMap(json.decode(source));
  }

  String toJson() {
    return json.encode(toMap());
  }
}
