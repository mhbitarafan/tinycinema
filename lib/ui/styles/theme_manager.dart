import 'package:flutter/material.dart';
import 'package:tinycinema/ui/styles/dark.dart';
import 'package:tinycinema/ui/styles/light.dart';
import 'package:tinycinema/ui/styles/theme.dart';
import 'package:tinycinema/utils.dart';

MyTheme autoTheme() {
  return isNight() ? DarkTheme() : LightTheme();
}

class MyThemeManager with ChangeNotifier {
  late MyTheme currentTheme;
  void loop() async {
    while (true) {
      await Future.delayed(Duration(minutes: 1));
      currentTheme = autoTheme();
      notifyListeners();
    }
  }

  MyThemeManager() {
    currentTheme = autoTheme();
    loop();
  }
}
