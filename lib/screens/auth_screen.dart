import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/auth/auth_form.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthScreen extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AuthScreen> {
  static const USER_NOT_FOUND = 'user-not-found';
  static const WRONG_PASSWORD = 'wrong-password';
  static const WEAK_PASSWORD = 'weak-password';
  static const EMAIL_ALREDAY_IN_USE = 'email-already-in-use';
  static const INVALID_EMAIL = 'invalid_email';
  var _loading = false;
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;
  void _showSnackBar(BuildContext ctx, String message) {
    ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    scaffoldMessengerState.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }

  void _showErrorMsg(BuildContext ctx, FirebaseAuthException e) {
    var errorMsg = 'An error occured, please check your credentials!';
    if (e.message != null) {
      errorMsg = e.message;
    }
    _showSnackBar(ctx, errorMsg);
  }

  void _toggleLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  void _submitAuthForm(String email, String password, String user, File image,
      bool isLogin, BuildContext ctx) async {
    print(isLogin);
    UserCredential userCredential;
    try {
      _toggleLoading(true);
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email.trim(), password: password);
      }
      if (!isLogin) {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
        // perform image upload
        final ref = _firebaseStorage
            .ref()
            .child('user_images')
            .child('${userCredential.user.uid}.jpg');
        await ref
            .putFile(image)
            .whenComplete(() => print('Image has been uploaded successfully'));
        final url = await ref.getDownloadURL();
        await _fireStore.collection('users').doc(userCredential.user.uid).set({
          'username': user,
          'email': email,
          'imageUrl': url,
        });
      }
      _toggleLoading(false);
    } on FirebaseAuthException catch (firebaseAuthError) {
      switch (firebaseAuthError.code) {
        case USER_NOT_FOUND:
        case WRONG_PASSWORD:
        case WEAK_PASSWORD:
        case EMAIL_ALREDAY_IN_USE:
        case INVALID_EMAIL:
          _showErrorMsg(ctx, firebaseAuthError);
          break;
        default:
          _showErrorMsg(ctx, firebaseAuthError);
          break;
      }
      _toggleLoading(false);
    } catch (e) {
      _showSnackBar(ctx, e.toString());
      _toggleLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _loading),
    );
  }
}
