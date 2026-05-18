import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  User? getUser() {
    final user = _firebaseAuth.currentUser;
    return user;
  }

  List<UserInfo> getAuthProvider() {
    final user = getUser();
    if (user == null) return [];
    final providers = user.providerData;
    return providers;
  }

  Future<void> deleteEmailAndPasswordAccount(String password) async {
    try {
      final user = getUser();
      if (user == null || password.trim().isEmpty) return;
      final email = user.email;
      if (email != null) {
        user.reauthenticateWithCredential(
            EmailAuthProvider.credential(email: email, password: password));
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
