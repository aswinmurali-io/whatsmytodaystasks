import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'routes/routes.gr.dart';

void main() {
  runApp(WhatsMyTodaysTasks());
}

class WhatsMyTodaysTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "What's my today's task",
      color: Colors.blueGrey,
      builder: ExtendedNavigator<Router>(router: Router()),
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
