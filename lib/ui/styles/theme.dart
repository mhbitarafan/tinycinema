import 'package:flutter/material.dart';
import 'package:tinycinema/ui/helpers/color_utils.dart';

Color bodyBg = Colors.grey[900]!;
Color sidebarBg = Colors.black;
Color sidebarLinkColor = Colors.white;

abstract class MyTheme {
  late ThemeData themeData;
  Color bodyBg = Colors.black12;
  Color sidebarBg = Colors.white;
  Color sidebarLinkColor = Colors.black87;

  MyTheme() {
    themeData = themeGen(Brightness.light);
  }

  ThemeData themeGen(Brightness brightness) {
    return ThemeData(
      fontFamily: 'irsans',
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(sidebarLinkColor),
          overlayColor: MaterialStateColor.resolveWith(
            (states) => lighten(Colors.deepPurple),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
      ),
      primaryColor: Colors.deepPurple[400],
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
          .copyWith(
              secondary: Colors.amber[600],
              brightness: brightness,
              primary: Colors.deepPurple),
    );
  }
}
