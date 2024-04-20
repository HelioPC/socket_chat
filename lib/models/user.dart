import 'dart:convert';

class User {
  User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.nameId,
    required this.description,
    required this.email,
    required this.profileImage,
  });

  final int id;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String nameId;
  final String? description;
  final String email;
  final String? profileImage;

  User copyWith({
    String? createdAt,
    String? updatedAt,
    String? name,
    String? nameId,
    String? description,
    String? email,
    String? profileImage,
  }) {
    return User(
      id: id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      nameId: nameId ?? this.nameId,
      description: description ?? this.description,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'name': name,
      'nameId': nameId,
      'description': description,
      'email': email,
      'profileImage': profileImage,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      name: map['name'] as String,
      nameId: map['nameId'] as String,
      description: map['description'] as String?,
      email: map['email'] as String,
      profileImage: map['profileImage'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(name: $name, email: $email, profileImage: $profileImage)';
  }

  @override
  bool operator == (covariant User other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.profileImage == profileImage;
  }

  @override
  int get hashCode {
    return name.hashCode ^
    email.hashCode ^
    profileImage.hashCode;
  }
}
