import 'package:flutter/widgets.dart';
import 'package:tinycinema/ui/helpers/device_detectors.dart';
import 'package:tinycinema/ui/desktop.dart';
import 'package:tinycinema/ui/tv.dart';
import 'package:tinycinema/ui/mobile.dart';

// ignore: must_be_immutable
class MyLayoutBuilder extends StatelessWidget {
  // pls dont make it final or you get empty screen!
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
