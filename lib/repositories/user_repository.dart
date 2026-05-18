import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        await user.reauthenticateWithCredential(
            EmailAuthProvider.credential(email: email, password: password));
        user.delete();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteSocialAccount() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      final user = getUser();
      if (kIsWeb) {
        await user?.reauthenticateWithProvider(GoogleAuthProvider());
        await user?.delete();
      } else {
        await googleSignIn.initialize(
            serverClientId:
                "412468287121-t3ov8gbb6faeqelsi3aa8kqs5sisdk7v.apps.googleusercontent.com");
        final googleUser = await googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final credentials =
            GoogleAuthProvider.credential(idToken: googleAuth.idToken);
        await user?.reauthenticateWithCredential(credentials);
        user?.delete();
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
