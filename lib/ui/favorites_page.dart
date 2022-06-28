import 'package:flutter/material.dart';
import 'package:tinycinema/logic/favorites.dart';
import 'package:tinycinema/logic/websites/models.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/ui/pages/video_card.dart';

Doostiha doostiha = Doostiha();
Uptv uptv = Uptv();
Digimovie digimovie = Digimovie();

class MyFavoritesPage extends StatefulWidget {
  @override
  MyFavoritesPageState createState() => MyFavoritesPageState();
}

class MyFavoritesPageState extends State<MyFavoritesPage> {
  @override
  void initState() {
    super.initState();
    myFavorite.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        itemCount: myFavorite.favoriteList.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          maxCrossAxisExtent: 220,
          mainAxisExtent: 380,
        ),
        itemBuilder: (context, i) {
          final item = Post.fromJson(
              Map<String, dynamic>.from(myFavorite.favoriteList[i]));
          return VideoCard(
            image: item.image,
            title: item.title,
            imageHeight: 290,
            imageWidth: 220,
            slug: item.slug!,
            websiteType: item.websiteType,
          );
        },
      ),
    );
  }
}
