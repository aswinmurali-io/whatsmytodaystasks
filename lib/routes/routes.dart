// flutter pub run build_runner watch --delete-conflicting-outputs

import 'package:auto_route/auto_route_annotations.dart';

import 'account_view.dart';
import 'mytask_view.dart';
import 'weekend_plan_view.dart';

@MaterialAutoRouter()
class $Router {
  WeekendPlanView weekendPlanView;
  AccountSettingsView accountSettingsView;
  @initial
  TaskView taskView;
}
