import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/logic/favorites.dart';
import 'package:tinycinema/logic/remember_time.dart';
import 'package:tinycinema/ui/layout_builder.dart';
import 'package:tinycinema/ui/pages/doostiha/doostiha_list.dart';
import 'package:tinycinema/ui/styles/theme_manager.dart';

void main() async {
  MyFavorite();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late final Widget layout;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyThemeManager(),
      child: Consumer<MyThemeManager>(
        builder: (context, myThemeManager, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: appTitle,
          home: WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: SafeArea(
              child: MyLayoutBuilder(),
            ),
          ),
          theme: myThemeManager.currentTheme.themeData,
          localizationsDelegates: [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            Locale("fa", "IR"),
          ],
          locale: Locale("fa", "IR"),
          scrollBehavior: MyCustomScrollBehavior(),
          routes: {"/doostiha": (context) => DoostihaPage()},
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
