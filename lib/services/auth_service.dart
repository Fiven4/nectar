import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'database_service.dart';
import '../models/user_model.dart';
import '../l10n/l10n.dart';
import '../utils/role_utils.dart';

class AuthService {
  factory AuthService() => _instance;

  AuthService._();

  static final AuthService _instance = AuthService._();

  /// While true the app keeps showing the signed-out UI even though Firebase
  /// already has a user. Login/registration flip it so the signed-in shell is
  /// only built after the profile has been created and validated.
  static final ValueNotifier<bool> gateHold = ValueNotifier<bool>(false);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _dbService = DatabaseService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String getErrorMessage(Object error) {
    if (error is DatabaseOperationException) {
      return error.message;
    }

    final l10n = AppLocale.strings;

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return l10n.authInvalidEmail;
        case 'user-disabled':
          return l10n.authUserDisabled;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return l10n.authWrongCredentials;
        case 'email-already-in-use':
          return l10n.authEmailInUse;
        case 'weak-password':
          return l10n.authWeakPassword;
        case 'network-request-failed':
          return l10n.authNetworkError;
        case 'too-many-requests':
          return l10n.authTooManyRequests;
      }
    }

    return l10n.genericError;
  }

  Future<UserCredential> registerBuyer({
    required String login,
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();
    final normalizedLogin = login.trim();

    gateHold.value = true;
    try {
      await _dbService.assertLoginAvailable(normalizedLogin);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      try {
        await userCredential.user?.updateDisplayName(normalizedName);

        await _dbService.createUser(
          UserModel(
            id: userCredential.user!.uid,
            login: normalizedLogin,
            name: normalizedName,
            email: normalizedEmail,
            phoneNumber: phoneNumber.trim(),
            role: AppRoles.buyer,
          ),
        );
        return userCredential;
      } catch (_) {
        await userCredential.user?.delete();
        rethrow;
      }
    } finally {
      gateHold.value = false;
    }
  }

  Future<UserCredential> login(String loginOrEmail, String password) async {
    final resolvedEmail = await _dbService.resolveEmailForIdentifier(loginOrEmail);
    return _signInGuarded(
      () => _auth.signInWithEmailAndPassword(
        email: resolvedEmail,
        password: password,
      ),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _signInGuarded(() => _auth.signInWithCredential(credential));
  }

  Future<UserCredential> _signInGuarded(Future<UserCredential> Function() signIn) async {
    gateHold.value = true;
    try {
      final userCredential = await signIn();
      final user = userCredential.user;
      if (user != null) {
        await _rejectIfDeleted(user);
      }
      return userCredential;
    } finally {
      gateHold.value = false;
    }
  }

  Future<void> _rejectIfDeleted(User user) async {
    // Сначала читаем профиль: удаленному пользователю запись в профиль запрещена
    // правилами, а сбой чтения не должен пропускать его в приложение.
    Map<String, dynamic>? profile;
    try {
      profile = await _dbService.getUserProfile(user.uid);
    } catch (error) {
      debugPrint('Profile check after sign-in failed: $error');
    }

    if (profile?['isDeleted'] == true) {
      await logout();
      throw DatabaseOperationException(AppLocale.strings.authAccountDeleted);
    }

    try {
      await _dbService.ensureUserProfileFromAuth(user);
    } catch (error) {
      debugPrint('Profile sync after sign-in failed: $error');
    }
  }

  Future<void> sendPasswordReset(String loginOrEmail) async {
    _auth.setLanguageCode(AppLocale.current.languageCode);
    final resolvedEmail = await _dbService.resolveEmailForIdentifier(loginOrEmail);
    await _auth.sendPasswordResetEmail(email: resolvedEmail);
  }

  bool get canChangePassword {
    return _auth.currentUser?.providerData.any((info) => info.providerId == 'password') ?? false;
  }

  /// Перед установкой нового пароля запрашивает текущий (повторная аутентификация).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw DatabaseOperationException(AppLocale.strings.authNotSignedIn);
    }

    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password' || error.code == 'invalid-credential') {
        throw DatabaseOperationException(AppLocale.strings.authWrongCurrentPassword);
      }
      rethrow;
    }

    await user.updatePassword(newPassword);
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('Google sign-out failed: $error');
    }
    await _auth.signOut();
  }
}
