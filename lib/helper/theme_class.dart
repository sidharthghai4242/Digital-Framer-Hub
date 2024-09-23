import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeClass {
  static const Color colorPrimary = Color(0xff2ead1c);
  static const Color colorPrimaryLight = Color(0xffbff6b8);
  static const Color colorGreenDark = Color(0xff23880e);
  static const Color colorGreenLight = Color(0xff40d021);

  static const themeColorArray = [
    Colors.white,
    Colors.white,
  ];

  static ThemeData darktheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: colorPrimary,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: colorPrimary,
      secondary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      )
    ),
  );
}