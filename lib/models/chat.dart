import 'dart:convert';

import 'package:socket_test/models/message.dart';

class Chat {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String description;
  final List<Message> messages = [];

  Chat({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.description,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      name: map['name'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'name': name,
      'description': description,
    };
  }

  factory Chat.fromJson(String source) {
    return Chat.fromMap(json.decode(source));
  }

  String toJson() {
    return json.encode(toMap());
  }
}
