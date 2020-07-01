import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// autoconnect() function must be called first before doing anything, then auth()
class Database {
  static String _uid;
  static SharedPreferences _storage;

  static Future<void> auth(String email, String password) async {
    try {
      _uid = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)).user.uid;
      _storage.setString("email", email);
      _storage.setString("password", password);
    } on PlatformException catch (exception) {
      print(exception);
      switch (exception.code) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          _uid = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user.uid;
          _storage.setString("email", email);
          _storage.setString("password", password);
      }
    }
  }

  static Future<bool> autoconnect() async {
    if (_storage == null) _storage = await SharedPreferences.getInstance();
    String _email = _storage.getString("email");
    if (_email != null) {
      String _password = _storage.getString("password");
      auth(_email, _password);
      return true;
    }
    return false;
  }

  static void signOut() async {
    _storage.clear();
    await FirebaseAuth.instance.signOut();
  }

  static void deleteAccount() async {
    _storage.clear();
    await Firestore.instance.document(_uid).delete();
    FirebaseAuth.instance.currentUser().then((user) => user.delete());
  }

  static void upload(Map<String, Map<String, dynamic>> data) async {
    _storage.setString("data", jsonEncode(data));
    if (_uid != null)
      await Firestore.instance.collection(_uid).document('tasks').setData(data).catchError((error) => print(error));
  }

  static Future<Map<String, Map<String, Object>>> download() async {
    Map<String, Map<String, Object>> obj = {};

    String data = _storage.get('data');
    if (data != null)
      // get the map and then convert it into a nested map (value is a map too)!
      jsonDecode(data).forEach((key, value) => obj.addAll({key: value}));
    else
      _storage.setString("data", jsonEncode(obj));
    if (_uid == null)
      print("UID not received, prolly no internet");
    else {
      obj.clear(); // if data in cloud thn remove local use directly from cloud
      try {
        (await Firestore.instance.collection(_uid).document('tasks').get().catchError((error) => print(error)))
            .data
            .forEach((key, value) => obj.addAll({key: Map<String, Object>.from(value)}));
      } on NoSuchMethodError catch (exception) {
        /* NoSuchMethodError: The method 'forEach' was called on null
           Happens when a new user is registered but no data in database */
        print("User just registered but no data in user. Will upload dummy data first, error > $exception");
        await Firestore.instance.collection(_uid).document('tasks').setData({}).catchError((error) => print(error));
        _storage.setString("data", jsonEncode({}));
      }
    }
    return obj;
  }
}
