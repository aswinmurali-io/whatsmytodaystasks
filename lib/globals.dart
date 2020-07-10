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
  "Sunday",
  "All Days",
  "Any Day",
  "All Tasks",
];

// gradient text shader
final Shader textGradientShader =
      LinearGradient(colors: GradientColors.juicyOrange)
          .createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

// importance -> 0 low, 1 med, 2 high, 3 critical
// time format 00:00AM/PM, image -> null or string

Map<String, Map<String, Object>> userTasks = {};

int allGradColorsIndex = 0;

// TODO: pls optimise memory here
List<List<Color>> autoGenerateColorCard = List.generate(
    10000, (index) => allGradColors[Random().nextInt(allGradColors.length)]);

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
