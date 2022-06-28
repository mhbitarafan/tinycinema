import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final firstSidebarFNode = FocusNode();