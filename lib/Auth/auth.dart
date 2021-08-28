import 'dart:developer';
import 'dart:io';

import 'package:denta_clinic/Auth/authProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthorization {
  static FirebaseAuthorization _firebase = FirebaseAuthorization._internal();

  static FirebaseAuth auth = FirebaseAuth.instance;

  factory FirebaseAuthorization() {
    return _firebase;
  }


  static init(FirebaseApp app) async {
    FirebaseAuth.instanceFor(app: app);
  }

  static Future<void> authWithPhone({
    BuildContext context,
    Function onError,
    Function onCodeSent,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: "+${Provider.of<AuthProvider>(context, listen: false).phoneNumber}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (Platform.isAndroid) {
          UserCredential result = await auth.signInWithCredential(credential);
          log("User login was successful. ${result.user.uid}");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("uid", result.user.uid);
          return result;
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        log("Error verification $e");
      },
      codeSent: (String verificationId, int resendToken)=>
        Provider.of<AuthProvider>(context, listen: false).setVerificationId(verificationId),
      codeAutoRetrievalTimeout: (String verificationId) {
      },
      timeout: Duration(seconds: 30),

    );
  }

  static Future<void> signInWithPhone({BuildContext context })async{
    try{
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: Provider.of<AuthProvider>(context, listen: false).verificationId,
        smsCode:Provider.of<AuthProvider>(context, listen: false).codeNumber,
      );

      final User user = (await auth.signInWithCredential(credential)).user;
      log("User signInWithPhone was successful. ${user.uid}");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("uid", user.uid);
    }catch(e){

    }
  }

  FirebaseAuthorization._internal();
}
