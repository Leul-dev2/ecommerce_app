import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Custom Exception for Authentication Errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool rememberMe = false;

  /// Load remember me preference
  Future<void> loadRememberedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.getBool('rememberMe') ?? false;
    notifyListeners();
  }

  /// Toggle remember me
  Future<void> toggleRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe = value;
    await prefs.setBool('rememberMe', value);
    notifyListeners();
  }

  /// Sign in with email and password
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _updateUserToken(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw AuthException('Google Sign-In cancelled.');

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _updateUserToken(userCredential.user!.uid);
      }
    } catch (e) {
      throw AuthException('Google login failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the user's FCM token in Firestore
  Future<void> _updateUserToken(String uid) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _db.collection('users').doc(uid).update({
        'fcmToken': fcmToken,
      });
      debugPrint('FCM token sent to backend.');
    }
  }

  /// Local biometrics
  Future<bool> loginWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck || !rememberMe) return false;

      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login',
      );

      return didAuth;
    } on PlatformException {
      return false;
    }
  }

  /// Helper: map Firebase errors
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'User account has been disabled.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}