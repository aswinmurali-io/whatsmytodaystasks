// flutter packages pub run build_runner build

import 'package:auto_route/auto_route_annotations.dart';

import 'account_view.dart';
import 'mytask_view.dart';

@MaterialAutoRouter()
class $Router {
  AccountSettingsView accountSettingsView;
  @initial
  TaskView taskView;
}
