import 'package:flutter/material.dart';

const kGreen = Color(0xFF2E7D32);
const kBackground = Color(0xFFF3F7F3);
const kRed = Color(0xFFD32F2F);
const kOrange = Color(0xFFF57C00);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
    scaffoldBackgroundColor: kBackground,
  );
}
