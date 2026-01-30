import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // SharedPreferences-д суурилсан Auth Repository
  throw UnimplementedError(
    'SharedPreferences instance must be provided via override',
  );
});

final authStateProvider = StateProvider<String?>((ref) => null);

final currentUserProfileProvider = FutureProvider<AppUser?>((ref) async {
  final uid = ref.watch(authStateProvider);
  if (uid == null) return null;
  final repo = ref.watch(authRepositoryProvider);
  return repo.getUser(uid);
});

class AuthRepository {
  final SharedPreferences _prefs;
  static const String _userKeyPrefix = 'user_';

  AuthRepository(this._prefs);

  Future<AppUser?> getUser(String uid) async {
    final data = _prefs.getString('$_userKeyPrefix$uid');
    if (data == null) return null;
    return AppUser.fromJson(data);
  }

  Future<AppUser?> signIn(String email, String password) async {
    // Бүх хэрэглэгчдийг шалгах (энгийн байдлаар)
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_userKeyPrefix)) {
        final user = AppUser.fromJson(_prefs.getString(key)!);
        if (user.email == email && user.password == password) {
          if (!user.isActive) throw Exception('Бүртгэл идэвхгүй байна');
          return user;
        }
      }
    }
    throw Exception('Имэйл эсвэл нууц үг буруу байна');
  }

  void signOut(Ref ref) {
    ref.read(authStateProvider.notifier).state = null;
  }

  Future<void> register({
    required String uid,
    required String email,
    required String password,
    required String displayName,
    bool isAdmin = false,
    bool isActive = true,
    DateTime? createdAt,
  }) async {
    // Имэйл шалгах
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_userKeyPrefix)) {
        final user = AppUser.fromJson(_prefs.getString(key)!);
        if (user.email == email) throw Exception('Имэйл бүртгэгдсэн байна');
      }
    }

    final user = AppUser(
      uid: uid,
      email: email,
      password: password,
      displayName: displayName,
      role: isAdmin ? 'admin' : 'user',
      isActive: isActive,
      createdAt: createdAt ?? DateTime.now(),
    );

    await _prefs.setString('$_userKeyPrefix$uid', user.toJson());
  }
}
