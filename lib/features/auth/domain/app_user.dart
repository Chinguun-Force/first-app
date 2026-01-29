class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'admin' or 'user'
  final bool isActive;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'user',
    this.isActive = true,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'user',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(), // always update this
    };
  }

  AppUser copyWith({
    String? email,
    String? displayName,
    String? role,
    bool? isActive,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
