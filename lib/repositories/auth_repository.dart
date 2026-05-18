import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> registerWithEmailAndPassword(
      {String name = '',
      required String email,
      required String password}) async {
    try {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await credentials.user?.sendEmailVerification();
      if (name.isNotEmpty) {
        await credentials.user?.updateDisplayName(name);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      await isUserVerified(credentials.user);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> isUserVerified(User? user) async {
    try {
      if (user != null && user.emailVerified) {
        return true;
      } else if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        throw Exception("User not verified. Please Verify Your Email to Login");
      }
    } catch (e) {
      throw Exception(e);
    }
    return false;
  }

  Future<bool> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();

      if (kIsWeb) {
        await _firebaseAuth.signInWithPopup(googleAuthProvider);
      } else {
        await _googleSignIn.initialize(
            serverClientId:
                "412468287121-t3ov8gbb6faeqelsi3aa8kqs5sisdk7v.apps.googleusercontent.com");
        final user = await _googleSignIn.authenticate();
        final googleAuth = user.authentication;
        final credentials =
            GoogleAuthProvider.credential(idToken: googleAuth.idToken);
        final userCredential =
            await _firebaseAuth.signInWithCredential(credentials);
        return userCredential.user != null ? true : false;
      }
    } catch (e) {
      throw Exception(e);
    }
    return false;
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<User?> authStateStream() {
    return _firebaseAuth.authStateChanges();
  }
}
