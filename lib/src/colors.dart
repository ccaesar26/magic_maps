import 'dart:ui';
import 'package:flutter/material.dart';

Color _hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
  'hex color must be #rrggbb or #rrggbbaa');

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

class ColorConstants {
  static Color gulfStream = _hexToColor('#76BA99');
  static Color greenSpringRain = _hexToColor('#ADCF9F');
  static Color winterHazel = _hexToColor('#CED89E');
  static Color navajoWhite = _hexToColor('#FFDCAE');
}
