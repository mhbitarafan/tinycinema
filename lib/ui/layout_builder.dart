import 'package:flutter/widgets.dart';
import 'package:tinycinema/ui/helpers/device_detectors.dart';
import 'package:tinycinema/ui/desktop.dart';
import 'package:tinycinema/ui/tv.dart';
import 'package:tinycinema/ui/mobile.dart';

class MyLayoutBuilder extends StatelessWidget {
  late Widget layout;
  @override
  Widget build(BuildContext context) {
    final dt = getDeviceType(context);
    switch (dt) {
      case deviceTypes.mobile:
        layout = MobileLayout();
        break;
      case deviceTypes.tv:
        layout = TvLayout();
        break;
      case deviceTypes.desktop:
        layout = DesktopLayout();
        break;
    }

    return layout;
  }
}