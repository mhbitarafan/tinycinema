import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:tinycinema/logic/websites/models.dart';

class MyFavorite extends ChangeNotifier {
  MyFavorite() {
    favoriteList = _storage.get("list", defaultValue: favoriteList);
  }

  var _storage = Hive.box("favorites");

  List favoriteList = [];

  void addFavorite(Post post) async {
    favoriteList.add(post.toJson());
    _update();
  }

  void removeFavorite(Post post) async {
    favoriteList.removeWhere((element) => element["title"] == post.title);
    _update();
  }

  bool isFavorite(Post post) => favoriteList.any((item) =>
      item["title"] == post.title && item["websiteKey"] == post.websiteKey);

  void _update() {
    _storage.put("list", favoriteList);
    notifyListeners();
  }
}

MyFavorite myFavorite = MyFavorite();
