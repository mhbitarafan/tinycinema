import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/global_keys.dart';
import 'package:tinycinema/ui/website_pageview.dart';
import 'package:collapsible_sidebar/collapsible_sidebar.dart';

class DesktopLayout extends StatefulWidget {
  @override
  DesktopLayoutState createState() => DesktopLayoutState();
}

class DesktopLayoutState extends State<DesktopLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: Row(
          children: [
            Sidebar(
              items: menu
                  .map(
                    (item) => SidebarItem(
                      title: item["title"],
                      icon: item["icon"],
                    ),
                  )
                  .toList(),
            ),
            Expanded(
              child: PageView(
                controller: page,
                children: pageViewChildren,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatefulWidget {
  Sidebar({Key? key, required this.items}) : super(key: key);
  final List<SidebarItem> items;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: 200,
      padding: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, i) {
          final selected = selectedIndex == i;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: TextButton(
              focusNode: i == 0 ? firstSidebarFNode : null,
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(16)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )),
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered) ||
                        states.contains(MaterialState.focused) ||
                        states.contains(MaterialState.pressed))
                      return Colors.black;
                    return selected
                        ? Colors.black
                        : Colors.white; // Defer to the widget's default.
                  },
                ),
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered) ||
                        states.contains(MaterialState.focused) ||
                        states.contains(MaterialState.pressed))
                      return Colors.amber;
                    return null; // Defer to the widget's default.
                  },
                ),
                backgroundColor: selected
                    ? MaterialStateProperty.all<Color>(Colors.amber)
                    : null,
              ),
              onPressed: () {
                page.jumpToPage(i);
                setState(() {
                  selectedIndex = i;
                });
              },
              child: Row(
                children: [
                  Icon(
                    widget.items[i].icon,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(widget.items[i].title),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SidebarItem {
  const SidebarItem({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
