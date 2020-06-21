// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:whatsmytodaystasks/routes/tasks_view.dart';

abstract class Routes {
  static const taskView = '/';
  static const all = {
    taskView,
  };
}

class Router extends RouterBase {
  @override
  Set<String> get allRoutes => Routes.all;

  @Deprecated('call ExtendedNavigator.ofRouter<Router>() directly')
  static ExtendedNavigatorState get navigator =>
      ExtendedNavigator.ofRouter<Router>();

  @override
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.taskView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => TaskView(),
          settings: settings,
        );
      default:
        return unknownRoutePage(settings.name);
    }
  }
}
