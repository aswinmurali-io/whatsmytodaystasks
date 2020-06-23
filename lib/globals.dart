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

int allGradColorsIndex = 0;
int oneGradForAll = 0;

List<Color> getNextGradient() {
  allGradColorsIndex++;
  oneGradForAll++;
  if (allGradColorsIndex >= allGradColors.length) allGradColorsIndex = 0;
  if (oneGradForAll < 49)
    return allGradColors[allGradColorsIndex];
  else
    return GradientColors.aqua;
}

List<Color> getNextGradientForPlanView() {
  allGradColorsIndex++;
  if (allGradColorsIndex >= allGradColors.length) allGradColorsIndex = 0;
    return allGradColors[allGradColorsIndex];
}
