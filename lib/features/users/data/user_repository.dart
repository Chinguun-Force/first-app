import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/app_user.dart';

final userRepositoryProvider = Provider(
  (ref) => UserRepository(FirebaseFirestore.instance),
);

final usersListProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).getUsersStream();
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Stream<List<AppUser>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> createUserProfile(AppUser user) async {
    // Note: This does NOT create the Auth user.
    // Ideally this is called by a Cloud Function or after the user registers.
    // For Admin "Add User", we create the doc acts as a placeholder or pre-approved profile.
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> softDeleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isActive': false});
  }
}
