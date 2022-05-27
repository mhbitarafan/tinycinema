import 'package:flutter/material.dart';
import 'package:tinycinema/ui/favorites.dart';
import 'package:tinycinema/ui/pages/websites/digimovie_list.dart';
import 'package:tinycinema/ui/pages/websites/doostiha_list.dart';
import 'package:tinycinema/ui/pages/search_page.dart';
import 'package:tinycinema/ui/pages/websites/uptv_list.dart';

final appTitle = "تاینی سینما";
final mpvPlayerPath = r"E:\software\Media\video\mpv\mpv.exe";

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
    "title": "دیجی مووی",
    "page": DigimoviePage(),
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
