// flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi --obfuscate --split-debug-info build/debug --shrink --release --tree-shake-icons

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:whatsmytodaystasks/routes/routes.gr.dart';

void main() {
  runApp(WhatsMyTodaysTasks());
}

class WhatsMyTodaysTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "What's my today's task",
      debugShowCheckedModeBanner: false,
      color: Colors.blueGrey,
      builder: ExtendedNavigator<Router>(router: Router()),
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
            ),
            bodyText2: TextStyle(color: Colors.red[600]),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity),
    );
  }
}
