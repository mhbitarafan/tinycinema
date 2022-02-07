import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

// const databaseUrl =
//     "https://tinycinema-app-default-rtdb.europe-west1.firebasedatabase.app";
// const secret = "pNiOI1MlM0A63loxX2SsVB9rWutd4hJreYHyW6Vv";

// Dio fbFavoritesClient = Dio(BaseOptions(
//   baseUrl: databaseUrl + "/favorites.json",
//   queryParameters: {"auth": secret},
// ));

class MyFavorite {
  static final MyFavorite _myFavorite = MyFavorite._internal();
  factory MyFavorite() => _myFavorite;
  MyFavorite._internal() {
    loadFavoriteList();
  }
  Future<File> getfavoriteFile() async {
    WidgetsFlutterBinding.ensureInitialized();
    var appDocDir = await getApplicationDocumentsDirectory();
    return File(appDocDir.path + "/favorites.json").create();
  }

  Map<String, dynamic> favoriteList = {"doostiha": [], "uptv": []};
  File? favoriteFile;

  void addFavorite(Map<String, dynamic> post, String websiteKey) async {
    favoriteList[websiteKey]!.add(post);
    favoriteFile?.writeAsStringSync(json.encode(favoriteList));
  }

  void removeFavorite(Map<String, dynamic> post, String website) async {
    (favoriteList[website]! as List)
        .removeWhere((element) => element["title"] == post["title"]);
    favoriteFile?.writeAsString(json.encode(favoriteList));
  }

  Future<void> loadFavoriteList() async {
    favoriteFile = await getfavoriteFile();
    if (favoriteFile != null && favoriteFile!.readAsStringSync().isNotEmpty) {
      favoriteList = json.decode(favoriteFile!.readAsStringSync());
    }
  }

  bool isFavorite(Map<String, dynamic> post, String websiteKey) {
    final l = favoriteList[websiteKey]! as List;
    for (var a in l) {
      if (a["title"] == post["title"]) {
        return true;
      }
    }
    return false;
  }
}
