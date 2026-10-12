import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.gender,
    required super.image,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // DummyJSON returns 'accessToken' or 'token'
    final token = (json['accessToken'] ?? json['token'] ?? '') as String;
    return UserModel(
      id: (json['id'] ?? 0) as int,
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'token': token,
    };
  }
}
