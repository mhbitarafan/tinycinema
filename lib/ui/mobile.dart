import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/ui/website_pageview.dart';

class MobileLayout extends StatefulWidget {
  @override
  MobileLayoutState createState() => MobileLayoutState();
}

class MobileLayoutState extends State<MobileLayout> {
  int _bottomNavCurrentIndex = 0;
  List<BottomNavigationBarItem> menuItems = [];

  void _onBottomNavItemTapped(int index) {
    _bottomNavCurrentIndex = index;
    page.jumpToPage(index);
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
        selectedItemColor: Theme.of(context).primaryColor,
        items: menuItems,
        currentIndex: _bottomNavCurrentIndex,
        onTap: _onBottomNavItemTapped,
      ),
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: PageView(
          controller: page,
          children: pageViewChildren,
          onPageChanged: (p) {
            setState(() {
              _bottomNavCurrentIndex = p;
            });
          },
        ),
      ),
    );
  }
}
