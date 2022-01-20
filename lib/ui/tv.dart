import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/controller/video_info_state.dart';
import 'package:tinycinema/ui/navigator.dart';
import 'package:tinycinema/ui/styles/theme_manager.dart';

class TvLayout extends StatefulWidget {
  @override
  TvLayoutState createState() => TvLayoutState();
}

class TvLayoutState extends State<TvLayout> {
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
                Sidebar(),
                Expanded(
                  child: Consumer<MyThemeManager>(
                    builder: (context, myThemeManager, child) => Container(
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

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  List<Widget> menuItems = [];

  @override
  void initState() {
    for (var item in menu) {
      menuItems.add(
        sidebarLink(
          item["title"],
          item["page"],
        ),
      );
    }
    super.initState();
    videoMeta.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MyNavigator, MyThemeManager>(
      builder: (context, myNavigator, myThemeManager, _) => Container(
        color: myThemeManager.currentTheme.sidebarBg,
        height: double.infinity,
        width: sidebarWidth,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...menuItems,
              Divider(
                thickness: 2,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        videoSummary.value,
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        videoMeta.value,
                      ),
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }
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
          child: Text(
            title,
            style: TextStyle(color: linkTextColor),
          ),
        ),
      );
    },
  );
}
