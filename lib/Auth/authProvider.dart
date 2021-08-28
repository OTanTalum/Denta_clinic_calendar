import 'package:flutter/cupertino.dart';

class AuthProvider with ChangeNotifier {

  String phoneNumber;
  String codeNumber;
  String verificationId;

  setPhoneNumber(String value){
    phoneNumber = value;
    notifyListeners();
  }

  setCodeNumber(String value){
    codeNumber = value;
    notifyListeners();
  }

  setVerificationId(String value){
    verificationId = value;
    notifyListeners();
  }

}