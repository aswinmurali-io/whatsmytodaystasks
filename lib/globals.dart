import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';

final allGradColors = [
  GradientColors.aqua,
  GradientColors.harmonicEnergy,
  GradientColors.noontoDusk,
  MoreGradientColors.azureLane,
  MoreGradientColors.instagram,
  MoreGradientColors.darkSkyBlue,
];

final weeks = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

// importance -> 0 low, 1 med, 2 high, 3 critical
// time format 00:00AM/PM, image -> null or string

Map<String, Map<String, Object>> userTasks = {
  "Test 1": {
    "time": "9:00AM",
    "endtime": "11:00AM",
    "notify": true,
    "description": "This is a test task, blah, blah, blah, blah, blah",
    "image": null,
    "importance": 0,
    "done": false,
    "week": 0
  },
  "Test 2": {
    "time": "11:00AM",
    "endtime": "12:00AM",
    "notify": true,
    "description": "This is a test task 2, blah, blah, blah, blah, blah",
    "image": null,
    "importance": 0,
    "done": false,
    "week": 1
  },
};

int allGradColorsIndex = 0;
int oneGradForAll = 0;

// TODO: pls optimise memory here
List<List<Color>> autoGenerateColorCard =
    List.generate(10000, (index) => allGradColors[Random().nextInt(allGradColors.length)]);

List<Color> getNextGradient() {
  allGradColorsIndex++;
  oneGradForAll++;
  if (allGradColorsIndex >= allGradColors.length) allGradColorsIndex = 0;
  //if (oneGradForAll < 49)
  return allGradColors[allGradColorsIndex];
  //else
  //  return GradientColors.aqua;
}

List<Color> getNextGradientForPlanView() {
  allGradColorsIndex++;
  if (allGradColorsIndex >= allGradColors.length) allGradColorsIndex = 0;
  return allGradColors[allGradColorsIndex];
}
