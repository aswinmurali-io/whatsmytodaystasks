// should handle local and firebase storage
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsmytodaystasks/globals.dart';

// autoconnect() function must be called first before doing anything
class Database {
  static String _uid;
  static SharedPreferences _storage;

  /*
  ERROR_WRONG_PASSWORD
  ERROR_EMAIL_ALREADY_IN_USE
  ERROR_TOO_MANY_REQUESTS
  ERROR_USER_NOT_FOUND
  */

  static Future register(String email, password) async {
    _uid = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)).user.uid;
    _storage.setString("email", email);
    _storage.setString("password", password);
    try {
      await Firestore.instance.collection(_uid).document('tasks').setData(userTasks);
    } catch (error) {
      print("$error @register()");
      return error;
    }
  }

  static Future<String> auth(String email, String password, Map<String, Map<String, dynamic>> userTasks) async {
    _storage.setString("email", email);
    _storage.setString("password", password);
    try {
      _uid = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user.uid;
    } catch (firebaseError) {
      print(firebaseError);
      _storage.setString("email", null);
      return firebaseError.code;
    }
    return null;
  }

  static Future autoconnect(userTasks) async {
    _storage = _storage ?? await SharedPreferences.getInstance();
    String _email = _storage.getString("email");
    if (_email != null) await auth(_email, _storage.getString("password"), userTasks);
  }

  static Future signOut() async {
    _storage.setString("email", null);
    _uid = null;
    await FirebaseAuth.instance.signOut();
  }

  static Future deleteAccount() async {
    _storage.setString("email", null);
    await Firestore.instance.collection(_uid).document("tasks").delete();
    _uid = null;
    await FirebaseAuth.instance.currentUser().then((user) => user.delete());
  }

  static upload(Map<String, Map<String, dynamic>> data) async {
    _storage.setString("data", jsonEncode(data));
    try {
      await Firestore.instance.collection(_uid).document('tasks').setData(data);
    } catch (error) {
      print("$error @upload()");
    }
  }

  static Future resetTasks(Map<String, Map<String, dynamic>> data, String week) async {
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
    try {
      await Firestore.instance.collection(_uid).document('tasks').setData(data);
    } catch (error) {
      print("$error @resetTasks()");
    }
  }

  static Future<Map<String, Map<String, Object>>> download() async {
    /*
      PlatformException(Error performing get, PERMISSION_DENIED: Missing or insufficient permissions., null)
      can happen if  sync button pressed after delete account/sign out
    */
    Map<String, Map<String, Object>> obj = {};
    String data = _storage.getString('data') ?? _storage.setString("data", jsonEncode(obj));
    // get the map and then convert it into a nested map (value is a map too)!
    if (data != null) jsonDecode(data).forEach((key, value) => obj.addAll({key: value}));
    try {
      if (_uid != null) obj.clear(); // if data in cloud thn remove local, use directly from cloud
      (await Firestore.instance.collection(_uid).document('tasks').get())
          .data
          .forEach((key, value) => obj.addAll({key: Map<String, Object>.from(value)}));
    } catch (error) {
      print("$error @download()");
    }
    return obj;
  }
}
