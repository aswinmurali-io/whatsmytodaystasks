import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class Database {
  static String uid;

  static void auth(String email, String password) async {
    try {
      uid = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)).user.uid;
    } on PlatformException catch (exception) {
      print(exception);
      switch (exception.code) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          uid = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user.uid;
          break;
        default:
          break;
      }
    }
  }

  static void sync() {
    
  }
}
