import 'package:flutter/material.dart';
import '../widgets/auth/auth_form.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AuthScreen> {
  static const USER_NOT_FOUND = 'user-not-found';
  static const WRONG_PASSWORD = 'wrong-password';
  static const WEAK_PASSWORD = 'weak-password';
  static const EMAIL_ALREDAY_IN_USE = 'email-alreday-in-use';
  var _loading = false;
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
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

  void _submitAuthForm(String email, String password, String user, bool isLogin,
      BuildContext ctx) async {
    UserCredential userCredential;
    try {
      _toggleLoading(true);
      if (!isLogin) {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await _fireStore.collection('users').doc(userCredential.user.uid).set({
          'username': user,
          'email': email,
        });
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      }
      _toggleLoading(false);
    } on FirebaseAuthException catch (error) {
      _toggleLoading(false);
      _showErrorMsg(ctx, error);
    } catch (e) {
      print(e);
      _toggleLoading(false);
      _showSnackBar(ctx, e.toString());
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
