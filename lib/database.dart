// should handle local and firebase storage
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsmytodaystasks/globals.dart';

// autoconnect() function must be called first before doing anything, then auth()
class Database {
  static String _uid;
  static SharedPreferences _storage;

  static Future auth(String email, String password) async {
    _storage.setString("email", email);
    _storage.setString("password", password);
    try {
      _uid = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user.uid;
    } catch (exception) {
      _uid = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)).user.uid;
    }
  }

  static Future<bool> autoconnect() async {
    if (_storage == null) _storage = await SharedPreferences.getInstance();
    String _email = _storage.getString("email");
    if (_email != null) {
      String _password = _storage.getString("password");
      await auth(_email, _password);
      return true;
    }
    return false;
  }

  static Future signOut() async {
    _storage.clear();
    await FirebaseAuth.instance.signOut();
  }

  static Future deleteAccount() async {
    _storage.clear();
    await Firestore.instance.collection(_uid).document("tasks").delete();
    await FirebaseAuth.instance.currentUser().then((user) => user.delete());
  }

  static void upload(Map<String, Map<String, dynamic>> data) async {
    _storage.setString("data", jsonEncode(data));
    if (_uid != null)
      await Firestore.instance.collection(_uid).document('tasks').setData(data).catchError((error) => print(error));
  }

  static Future<void> resetTasks(Map<String, Map<String, dynamic>> data, String week) async {
    bool reset = _storage.getBool("reset");
    if (reset == null)
      _storage.setBool("reset", false);
    else {
      if (week == "Monday" && reset) {
        for (String task in userTasks.keys) if (userTasks[task]["repeat"] ?? false) userTasks[task]["done"] = false;
        _storage.setBool("reset", false);
      } else if (week != "Monday" && !reset) {
        _storage.setBool("reset", true);
      }
    }
    _storage.setString("data", jsonEncode(data));
    if (_uid != null) {
      await Firestore.instance.collection(_uid).document('tasks').setData(data).catchError((error) => print(error));
    }
  }

  static Future<Map<String, Map<String, Object>>> download() async {
    Map<String, Map<String, Object>> obj = {};
    String data = _storage.get('data') ?? _storage.setString("data", jsonEncode(obj));
    // get the map and then convert it into a nested map (value is a map too)!
    if (data != null) jsonDecode(data).forEach((key, value) => obj.addAll({key: value}));
    if (_uid == null)
      print("UID not received, prolly no internet");
    else {
      obj.clear(); // if data in cloud thn remove local use directly from cloud
      try {
        (await Firestore.instance.collection(_uid).document('tasks').get())
            .data
            .forEach((key, value) => obj.addAll({key: Map<String, Object>.from(value)}));
      } catch (exception) {
        // PlatformException(Error performing get, PERMISSION_DENIED: Missing or insufficient permissions., null)
        // can happen if  sync button pressed after delete account/ sign out
        print(exception);
      }
    }
    return obj;
  }
}
