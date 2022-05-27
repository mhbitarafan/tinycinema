import 'package:flutter/material.dart';
import 'package:tinycinema/logic/favorites.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/ui/pages/websites/doostiha_list.dart' as d;
import 'package:tinycinema/ui/pages/single_page.dart';
import 'package:tinycinema/ui/pages/video_card.dart';

Doostiha doostiha = Doostiha();
Uptv uptv = Uptv();
Digimovie digimovie = Digimovie();

class MyFavoritesPage extends StatefulWidget {
  @override
  MyFavoritesPageState createState() => MyFavoritesPageState();
}

class MyFavoritesPageState extends State<MyFavoritesPage> {
  MyFavorite myFavorite = MyFavorite();
  List<dynamic> doostihaFavorites = [];
  List<dynamic> uptvFavorites = [];
  List<dynamic> digiMovieFavorites = [];

  @override
  void initState() {
    doostihaFavorites = myFavorite.favoriteList["doostiha"];
    uptvFavorites = myFavorite.favoriteList["uptv"];
    digiMovieFavorites = myFavorite.favoriteList["digimovie"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 400,
        child: ListView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          children: [
            FavoriteRows(doostiha, doostihaFavorites),
            FavoriteRows(uptv, uptvFavorites),
            FavoriteRows(digimovie, digiMovieFavorites),
          ],
        ),
      ),
    );
  }
}

class FavoriteRows extends StatelessWidget {
  FavoriteRows(this.website, this.favorites);
  final Website website;
  final List<dynamic> favorites;
  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    for (var favorite in favorites) {
      rows.add(Container(
        width: 200,
        child: VideoCard(
            image: favorite["image"],
            title: favorite["title"],
            imageHeight: d.imageHeight,
            imageWidth: d.imageWidth,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SinglePage(
                  title: favorite["title"],
                  image: favorite["image"],
                  slug: favorite["slug"],
                  website: website,
                );
              }));
            }),
      ));
    }
    return Row(
      children: rows,
    );
  }
}
