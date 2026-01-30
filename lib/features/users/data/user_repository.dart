import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/domain/app_user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  // SharedPreferences-д суурилсан User Repository
  throw UnimplementedError(
    'SharedPreferences instance must be provided via override',
  );
});

final usersListProvider = FutureProvider<List<AppUser>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUsers();
});

class UserRepository {
  final SharedPreferences _prefs;
  static const String _userKeyPrefix = 'user_';

  UserRepository(this._prefs);

  Future<List<AppUser>> getUsers() async {
    final keys = _prefs.getKeys();
    final users = <AppUser>[];
    for (final key in keys) {
      if (key.startsWith(_userKeyPrefix)) {
        users.add(AppUser.fromJson(_prefs.getString(key)!));
      }
    }
    return users;
  }

  Future<void> createUserProfile(AppUser user) async {
    await _prefs.setString('$_userKeyPrefix${user.uid}', user.toJson());
  }

  Future<void> updateUser(AppUser user) async {
    await _prefs.setString('$_userKeyPrefix${user.uid}', user.toJson());
  }

  Future<void> softDeleteUser(String uid) async {
    final data = _prefs.getString('$_userKeyPrefix$uid');
    if (data != null) {
      final user = AppUser.fromJson(data);
      final updated = user.copyWith(isActive: false);
      await _prefs.setString('$_userKeyPrefix$uid', updated.toJson());
    }
  }
}
