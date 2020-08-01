import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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
  "Sunday",
  "Daily",
  "Any Day",
  "All Tasks",
];

// gradient text shader
final Shader textGradientShader =
    LinearGradient(colors: GradientColors.juicyOrange).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

// importance -> 0 low, 1 med, 2 high, 3 critical
// time format 00:00AM/PM, image -> null or string

Map<String, Map<String, Object>> userTasks = {};

int allGradColorsIndex = 0;

// TODO: pls optimise memory here
List<List<Color>> autoGenerateColorCard =
    List.generate(10000, (index) => allGradColors[Random().nextInt(allGradColors.length)]);

List<Color> getNextGradient() {
  allGradColorsIndex++;
  if (allGradColorsIndex >= allGradColors.length) allGradColorsIndex = 0;
  return allGradColors[allGradColorsIndex];
}

List<Color> getNextGradientForPlanView() {
  allGradColorsIndex++;
  if (allGradColorsIndex >= allGradColors.length) allGradColorsIndex = 0;
  return allGradColors[allGradColorsIndex];
}

String getWeekNameFromIndex(int index) {
  switch (index) {
    case 0:
      return "Monday";
    case 1:
      return "Tuesday";
    case 2:
      return "Wednesday";
    case 3:
      return "Thursday";
    case 4:
      return "Friday";
    case 5:
      return "Saturday";
    case 6:
      return "Sunday";
    case 7:
      return "Daily";
    case 8:
      return "Any Day";
    case 9:
      return "All Tasks";
    default:
      return "Unknown";
  }
}
