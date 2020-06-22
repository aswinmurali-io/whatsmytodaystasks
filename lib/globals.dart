import 'dart:ui';

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

List<Color> getNextGradient() {
  allGradColorsIndex++;
  if (allGradColorsIndex >= allGradColors.length) allGradColorsIndex = 0;
  return allGradColors[allGradColorsIndex];
}
