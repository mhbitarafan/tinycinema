import 'package:flutter/widgets.dart';
import 'package:tinycinema/ui/pages/websites/doostiha_list.dart';

class MyNavigator extends ChangeNotifier {
  static final MyNavigator _myNavigator = MyNavigator._internal();
  factory MyNavigator() {
    return _myNavigator;
  }
  MyNavigator._internal();
  Widget mainArea = DoostihaPage();
  var currentRoute = "دوستی ها";
  void navigate(Widget newPage, linkTitle) {
    mainArea = newPage;
    currentRoute = linkTitle;
    notifyListeners();
  }

  void pop() {}
}
