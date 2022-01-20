import 'package:flutter/material.dart';
import 'package:tinycinema/logic/favorites.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/ui/pages/doostiha/doostiha_list.dart' as d;
import 'package:tinycinema/ui/pages/single_page.dart';
import 'package:tinycinema/ui/pages/uptv/uptv_list.dart' as u;
import 'package:tinycinema/ui/pages/video_card.dart';

Doostiha doostiha = Doostiha();
Uptv uptv = Uptv();

class MyFavoritesPage extends StatefulWidget {
  @override
  MyFavoritesPageState createState() => MyFavoritesPageState();
}

class MyFavoritesPageState extends State<MyFavoritesPage> {
  MyFavorite myFavorite = MyFavorite();
  List<dynamic> doostihaFavorites = [];
  List<dynamic> uptvFavorites = [];

  @override
  void initState() {
    doostihaFavorites = myFavorite.favoriteList["doostiha"]!;
    uptvFavorites = myFavorite.favoriteList["uptv"]!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          SizedBox(
            height: 15,
          ),
          Text(
            "دوستی ها",
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: d.imageHeight + 80,
            child: ListView.separated(
                reverse: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    width: d.imageWidth,
                    child: VideoCard(
                      image: doostihaFavorites[index]["image"],
                      title: doostihaFavorites[index]["title"],
                      imageHeight: d.imageHeight,
                      imageWidth: d.imageWidth,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return SinglePage(
                              title: doostihaFavorites[index]["title"],
                              image: doostihaFavorites[index]["image"],
                              slug: doostihaFavorites[index]["slug"],
                              website: doostiha,
                            );
                          },
                        ));
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                      width: 10,
                    ),
                itemCount: doostihaFavorites.length),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "آپ تی وی",
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: u.imageHeight + 80,
            child: ListView.separated(
                reverse: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    width: u.imageWidth,
                    child: VideoCard(
                      image: uptvFavorites[index]["image"],
                      title: uptvFavorites[index]["title"],
                      imageHeight: u.imageHeight,
                      imageWidth: u.imageWidth,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return SinglePage(
                              title: uptvFavorites[index]["title"],
                              image: uptvFavorites[index]["image"],
                              slug: uptvFavorites[index]["slug"],
                              website: uptv,
                            );
                          },
                        ));
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                      width: 10,
                    ),
                itemCount: uptvFavorites.length),
          ),
        ],
      ),
    );
  }
}
