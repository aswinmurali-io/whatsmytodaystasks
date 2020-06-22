// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:whatsmytodaystasks/routes/weekend_plan_view.dart';
import 'package:whatsmytodaystasks/routes/account_view.dart';
import 'package:whatsmytodaystasks/routes/mytask_view.dart';

abstract class Routes {
  static const weekendPlanView = '/weekend-plan-view';
  static const accountSettingsView = '/account-settings-view';
  static const taskView = '/';
  static const all = {
    weekendPlanView,
    accountSettingsView,
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
      case Routes.weekendPlanView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => WeekendPlanView(),
          settings: settings,
        );
      case Routes.accountSettingsView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => AccountSettingsView(),
          settings: settings,
        );
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
