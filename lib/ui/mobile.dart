import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/ui/navigator.dart';
import 'package:tinycinema/ui/pages/doostiha/doostiha_list.dart';
import 'package:tinycinema/ui/styles/theme_manager.dart';

class MobileLayout extends StatefulWidget {
  @override
  MobileLayoutState createState() => MobileLayoutState();
}

class MobileLayoutState extends State<MobileLayout> {
  int _bottomNavCurrentIndex = 0;
  Widget mainArea = DoostihaPage();
  List<BottomNavigationBarItem> menuItems = [];
  void _onBottomNavItemTapped(int index) {
    _bottomNavCurrentIndex = index;
    mainArea = menu[index]["page"];
    setState(() {});
  }

  @override
  void initState() {
    for (var item in menu) {
      menuItems.add(
        BottomNavigationBarItem(
          label: item["title"],
          icon: Icon(item["icon"]),
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        unselectedItemColor: Theme.of(context).textTheme.bodyText1!.color,
        items: menuItems,
        currentIndex: _bottomNavCurrentIndex,
        onTap: _onBottomNavItemTapped,
      ),
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: Consumer<MyThemeManager>(
          builder: (context, myThemeManager, child) => Container(
            color: myThemeManager.currentTheme.bodyBg,
            child: mainArea,
          ),
        ),
      ),
    );
  }
}
