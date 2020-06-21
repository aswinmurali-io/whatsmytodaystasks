// flutter pub run build_runner watch --delete-conflicting-outputs

import 'package:auto_route/auto_route_annotations.dart';

import 'tasks_view.dart';

@MaterialAutoRouter()
class $Router {
  @initial
  TaskView taskView;
}