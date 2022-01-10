import 'dart:io';

import 'package:flutter/widgets.dart';

enum deviceTypes { mobile, tv, desktop }

deviceTypes getDeviceType(BuildContext context) {
  if (isDesktop()) {
    return deviceTypes.desktop;
  } else if (isPhone(context)) {
    return deviceTypes.mobile;
  } else {
    return deviceTypes.tv;
  }
}

bool isPhone(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide < 500;

bool isDesktop() {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
