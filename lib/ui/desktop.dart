import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/ui/navigator.dart';
import 'package:tinycinema/ui/styles/theme_manager.dart';

class DesktopLayout extends StatefulWidget {
  @override
  DesktopLayoutState createState() => DesktopLayoutState();
}

class DesktopLayoutState extends State<DesktopLayout> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyNavigator(),
      child: Consumer<MyNavigator>(
        builder: (context, myNavigator, child) => Scaffold(
          body: Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
            },
            child: Row(
              children: [
                sidebar(),
                Expanded(
                  child: Consumer<MyThemeManager>(
                    builder: (context, myThemeManager, _) => Container(
                        color: myThemeManager.currentTheme.bodyBg,
                        child: myNavigator.mainArea),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget sidebar() {
  List<Widget> menuItems = [];
  for (var item in menu) {
    menuItems.add(
      sidebarLink(
        item["title"],
        item["page"],
      ),
    );
  }
  return Consumer2<MyNavigator, MyThemeManager>(
    builder: (context, myNavigator, myThemeManager, _) => Container(
      color: myThemeManager.currentTheme.sidebarBg,
      height: double.infinity,
      width: sidebarWidth,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: menuItems),
    ),
  );
}

Color? linkBgColor;
Color? linkTextColor;

Widget sidebarLink(String title, Widget newPage) {
  return Consumer<MyNavigator>(
    builder: (context, myNavigator, child) {
      if (title == myNavigator.currentRoute) {
        linkBgColor = Theme.of(context).primaryColor;
        linkTextColor = Colors.white;
      } else {
        linkBgColor = null;
        linkTextColor = null;
      }
      return AnimatedContainer(
        decoration: BoxDecoration(
          color: linkBgColor,
        ),
        duration: animationSpeed,
        curve: animationCurve,
        child: TextButton(
          onPressed: () {
            myNavigator.navigate(newPage, title);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(color: linkTextColor),
            ),
          ),
        ),
      );
    },
  );
}
