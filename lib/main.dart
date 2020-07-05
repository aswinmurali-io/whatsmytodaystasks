import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mytask_view.dart';
 
void main() => runApp(WhatsMyTodaysTasks());

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
      home: TaskView(),
      theme: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.transparent),
          brightness: Brightness.light,
          primarySwatch: Colors.blueGrey,
          primaryIconTheme:
              const IconThemeData.fallback().copyWith(color: Colors.red[600]),
          primaryTextTheme: TextTheme(
              headline6: TextStyle(
            color: Colors.blueGrey[200],
            fontWeight: FontWeight.bold,
          )),
          visualDensity: VisualDensity.adaptivePlatformDensity),
    );
  }
}
