
import 'dart:io';

import 'package:denta_clinic/Auth/auth.dart';
import 'package:denta_clinic/Auth/authProvider.dart';
import 'package:denta_clinic/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  Function() callback;
  AuthPage({void Function() callback});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController phoneController = new TextEditingController();
  TextEditingController codeController = new TextEditingController();
  bool phoneIsComplate = false;

  @override
  void initState() {
    phoneController.addListener(phoneFieldListener);
    codeController.addListener(codeFieldListener);
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    super.dispose();
  }

  phoneFieldListener() {
    if (phoneController.text.length == 12) {
      Provider.of<AuthProvider>(context, listen: false).setPhoneNumber(phoneController.text);
      setState(() {
        phoneIsComplate = true;
      });

      FirebaseAuthorization.authWithPhone(
        context: context,
        onCodeSent: () => print("onSent"),
        onError: () => print("onError"),
      );
    }
  }

  codeFieldListener() async{
    if (codeController.text.length == 6) {
      Provider.of<AuthProvider>(context, listen: false).setCodeNumber(codeController.text);
      await FirebaseAuthorization.signInWithPhone(context: context).then((value) =>
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>MyHomePage()))
      );
      widget.callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Вхід"),
      ),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              phoneIsComplate?"Введіть код із смс: ":"Введіть номер телефону: ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
              ),
            ), phoneIsComplate
                ? buildPhoneField(isPhoneEntering:false)
                : buildPhoneField(isPhoneEntering:true)
          ],
        ),
      ),
    );
  }

  // login() async {
  //
  //   await FirebaseAuthorization().auth.verifyPhoneNumber(
  //     phoneNumber: '+${phoneController.text}',
  //     timeout: Duration(minutes:2),
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       await FirebaseAuthorization().auth.signInWithCredential(credential).then((UserCredential result){
  //         Navigator.pushReplacement(context, MaterialPageRoute(
  //             builder: (context) => MyHomePage()
  //         ));
  //       }).catchError((e){
  //         print("TROUBLE VERIFICATION NOT COMPLITED");
  //       });
  //       print("COmplated");
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       print("ERRRRORRRRRRR");
  //       print(e);
  //     },
  //     codeSent: (String verificationId, int resendToken) async {
  //      String smsCode = await showCodeField(context);
  //      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
  //      await FirebaseAuthorization().auth.signInWithCredential(phoneAuthCredential);
  //       print("codeSent $verificationId");
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {
  //       print("timeOut");
  //     },
  //   );
  // }

  buildPhoneField({bool isPhoneEntering}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: TextField(
        controller:isPhoneEntering? phoneController:codeController,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(12),
          FilteringTextInputFormatter.digitsOnly
        ],
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon: Icon(isPhoneEntering?Icons.phone:Icons.sms_outlined),
          border: const OutlineInputBorder(),
        ),
        style: TextStyle(
          letterSpacing: 2.0,
          fontSize: 24,
        ),
      ),
    );
  }

 Future <String> showCodeField(context)async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: TextField(
              onChanged: (value){
                if(value.length==6){
                  Navigator.pop(context, codeController.text);
                }
              },
              controller: codeController,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                focusColor: Colors.amberAccent,
                prefixIcon: Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(
                letterSpacing: 2.0,
                fontSize: 24,
              ),
            ),
          ),
        );
    },
    );
  }
}
