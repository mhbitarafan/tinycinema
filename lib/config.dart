import 'package:flutter/material.dart';
import 'package:tinycinema/ui/favorites.dart';
import 'package:tinycinema/ui/pages/doostiha/doostiha_list.dart';
import 'package:tinycinema/ui/pages/search_page.dart';
import 'package:tinycinema/ui/pages/uptv/uptv_list.dart';

final appTitle = "تاینی سینما";
final potPlayerPath = "C:/Program Files/DAUM/PotPlayer/PotPlayerMini64.exe";

// animation
final animationSpeed = Duration(milliseconds: 500);
final animationCurve = Curves.easeIn;

// transition
final transitionSpeed = Duration(milliseconds: 500);

final sidebarWidth = 200.0;

final cardWidth = 250.0;

final List<Map<String, dynamic>> menu = [
  {
    "title": "دوستی ها",
    "page": DoostihaPage(),
    "icon": Icons.movie,
  },
  {
    "title": "آپ تیوی",
    "page": UptvPage(),
    "icon": Icons.movie,
  },
  {
    "title": "جستجو",
    "page": SearchPage(),
    "icon": Icons.tv,
  },
  {
    "title": "لیست تماشا",
    "page": MyFavoritesPage(),
    "icon": Icons.list,
  }
];
