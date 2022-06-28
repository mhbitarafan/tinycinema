import 'package:flutter/widgets.dart';
import 'package:tinycinema/config.dart';

class MyNavigator extends ChangeNotifier {
  static final MyNavigator _myNavigator = MyNavigator._internal();
  factory MyNavigator() {
    return _myNavigator;
  }
  MyNavigator._internal();
  Widget mainArea = menu[0]["page"];
  var currentRoute = menu[0]["title"];
  void navigate(Widget newPage, linkTitle) {
    mainArea = newPage;
    currentRoute = linkTitle;
    notifyListeners();
  }

  void pop() {}
}
