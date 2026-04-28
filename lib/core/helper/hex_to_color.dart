import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  hex = hex.toUpperCase().replaceAll("#", "");

  if (hex.startsWith("0X")) {
    return Color(int.parse(hex.substring(2), radix: 16));
  }

  if (hex.length == 6) {
    hex = "FF$hex";
  }

  return Color(int.parse(hex, radix: 16));
}
