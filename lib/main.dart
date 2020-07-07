import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mytask_view.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  if (!kIsWeb) {
    Crashlytics.instance.enableInDevMode = true;
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = Crashlytics.instance.recordFlutterError;
  }
  runApp(WhatsMyTodaysTasks());
}

class WhatsMyTodaysTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white30,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white30,
        systemNavigationBarIconBrightness: Brightness.dark));
    return MaterialApp(
      title: "What's my today's task",
      debugShowCheckedModeBanner: false,
      color: Colors.blueGrey,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      home: TaskView(),
      theme: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.transparent),
          brightness: Brightness.light,
          primarySwatch: Colors.blueGrey,
          primaryIconTheme: const IconThemeData.fallback().copyWith(color: Colors.red[600]),
          primaryTextTheme: TextTheme(
              headline6: TextStyle(
            color: Colors.blueGrey[200],
            fontWeight: FontWeight.bold,
          )),
          visualDensity: VisualDensity.adaptivePlatformDensity),
    );
  }
}
