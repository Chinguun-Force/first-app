import 'dart:convert';

class AppUser {
  final String uid;
  final String email;
  final String password;
  final String displayName;
  final String role; // 'admin' эсвэл 'user'
  final bool isActive;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.password,
    required this.displayName,
    this.role = 'user',
    this.isActive = true,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'displayName': displayName,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      displayName: map['displayName'] as String,
      role: map['role'] as String? ?? 'user',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUser.fromJson(String source) =>
      AppUser.fromMap(json.decode(source));

  AppUser copyWith({
    String? email,
    String? password,
    String? displayName,
    String? role,
    bool? isActive,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
