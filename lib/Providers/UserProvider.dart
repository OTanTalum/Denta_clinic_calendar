
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProvider with ChangeNotifier {
  UserCredential _user;

  get user => _user;

  init(UserCredential userData){
    _user = userData;
    notifyListeners();
  }

}