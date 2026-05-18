import 'dart:async';

import 'package:docforge/repositories/auth_repository.dart';
import 'package:docforge/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StreamProvider(
    (ref) => ref.watch(authRepositoryProvider).authStateStream());

final authProvider = AsyncNotifierProvider<AuthNotifier, void>(
  () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<void> {
  late final AuthRepository _authRepository;
  @override
  FutureOr<void> build() {
    _authRepository = ref.read(authRepositoryProvider);
  }

  Future<bool> registerWithEmailAndPassword(
      {String name = '',
      required String email,
      required String password}) async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.registerWithEmailAndPassword(
          name: name, email: email, password: password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
    return false;
  }

  Future<bool> loginInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      state = const AsyncValue.loading();

      await _authRepository.loginWithEmailAndPassword(
          email: email, password: password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
    return false;
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String getProviderId() {
    final userInfo = ref.read(userRepositoryProvider).getAuthProvider();
    return userInfo.first.providerId;
  }

  Future<void> deletePasswordAccount(String password) async {
    try {
      state = const AsyncValue.loading();
      await ref
          .read(userRepositoryProvider)
          .deleteEmailAndPasswordAccount(password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSocialAccount() async {
    try {
      state = const AsyncValue.loading();
      await ref.read(userRepositoryProvider).deleteSocialAccount();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userRepositoryProvider = Provider((ref) => UserRepository());

final currentUserProvider = Provider((ref) {
  final user = ref.watch(userRepositoryProvider).getUser();
  return user;
});
