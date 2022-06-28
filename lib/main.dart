import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/global_keys.dart';
import 'package:tinycinema/ui/helpers/color_utils.dart';
import 'package:tinycinema/ui/layout_builder.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tinycinema/ui/pages/single_page.dart';

void initLogger() {
  if (kReleaseMode) {
    Logger.root.level = Level.OFF;
  } else {
    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(MyApp());
}

Future<void> initServices() async {
  await Hive.initFlutter();
  await Hive.openBox('favorites');
}

class MyApp extends StatelessWidget {
  late final Widget layout;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      title: appTitle,
      theme: ThemeData(
        fontFamily: 'irsans',
        brightness: Brightness.dark,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black87),
            overlayColor: MaterialStateColor.resolveWith(
              (states) => lighten(Colors.deepPurple),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
        ),
        primaryColor: Colors.deepPurple[400],
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(
          secondary: Colors.amber[500],
          brightness: Brightness.dark,
          primary: Colors.deepPurple[600],
        ),
      ),
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
      initialRoute: "/",
      routes: {
        "/singlepage": (context) => SinglePage(),
      },
      home: SafeArea(
        child: MyLayoutBuilder(),
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
