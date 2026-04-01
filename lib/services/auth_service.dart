import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/auth/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  static Future<UserModel?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String secretWord,
  }) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        secretWord: secretWord,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(userModel.toMap());

      await _saveUserToLocal(userModel);

      return userModel;
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      try {
        final doc =
            await _firestore.collection('users').doc(cred.user!.uid).get();
        if (doc.exists) {
          final userModel = UserModel.fromMap(doc.data()!);
          await _saveUserToLocal(userModel);
          return userModel;
        }
      } catch (e) {
        final userModel = UserModel(
          id: cred.user!.uid,
          name: cred.user!.displayName ?? 'User',
          email: email,
          phone: cred.user!.phoneNumber ?? '',
          secretWord: '',
          createdAt: DateTime.now(),
        );
        await _saveUserToLocal(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await Hive.box('user').clear();
  }

  static Future<bool> resetPassword({
    required String email,
    required String secretWord,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (doc.docs.isEmpty) {
        throw Exception('No account found with this email');
      }

      final userData = doc.docs.first.data();
      if (userData['secretWord'] != secretWord) {
        throw Exception('Invalid secret word');
      }

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  static Future<UserModel?> getCurrentUser() async {
    final userBox = Hive.box('user');
    final userData = userBox.get('currentUser');
    if (userData != null) {
      return UserModel.fromMap(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  static Future<void> updateProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
    await _saveUserToLocal(user);
  }

  static Future<void> _saveUserToLocal(UserModel user) async {
    final userBox = Hive.box('user');
    await userBox.put('currentUser', user.toMap());
  }

  static String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email already registered';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak';
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
