// flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi --obfuscate --split-debug-info build/debug --shrink --release --tree-shake-icons

import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

import 'routes/routes.gr.dart';

void main() => runApp(WhatsMyTodaysTasks());

class WhatsMyTodaysTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set up mobile system status and navigation bar style
    FlutterStatusbarcolor.setStatusBarColor(Colors.white30);
    FlutterStatusbarcolor.setNavigationBarColor(Colors.white30);

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
