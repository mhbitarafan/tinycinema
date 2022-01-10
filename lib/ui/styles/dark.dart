import 'package:flutter/material.dart';
import 'package:tinycinema/ui/styles/theme.dart';

class DarkTheme extends MyTheme {
  DarkTheme() {
    bodyBg = Colors.black54;
    sidebarBg = Colors.black87;
    sidebarLinkColor = Colors.white;
    themeData = themeGen(Brightness.dark);
  }
}
