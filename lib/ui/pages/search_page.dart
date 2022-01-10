import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinycinema/logic/websites/models.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/ui/pages/doostiha/doostiha_list.dart' as d;
import 'package:tinycinema/ui/pages/uptv/uptv_list.dart' as u;
import 'package:tinycinema/ui/pages/single_page.dart';
import 'package:tinycinema/ui/pages/video_card.dart';

Doostiha doostiha = Doostiha();
Uptv uptv = Uptv();

class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  List<Post> _doostihaResults = [];
  List<Post> _uptvResults = [];
  List<bool> _loading = [false, false];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Focus(
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                node.nextFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                  fillColor: Theme.of(context).cardColor,
                  filled: true,
                  border: OutlineInputBorder(),
                  labelText: 'جستجو ...'),
              onSubmitted: (String q) async {
                setState(() {
                  _loading[0] = true;
                });
                _doostihaResults = await doostiha.search(q);
                setState(() {
                  _loading[0] = false;
                });

                setState(() {
                  _loading[1] = true;
                });
                _uptvResults = await uptv.search(q);
                setState(() {
                  _loading[1] = false;
                });
              },
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: ListView(
              children: [
                _loading[0]
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _doostihaResults.length > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                      itemBuilder: (context, i) {
                                        return SizedBox(
                                          width: d.imageWidth,
                                          child: VideoCard(
                                            image: _doostihaResults[i].image,
                                            title: _doostihaResults[i].title,
                                            imageHeight: d.imageHeight,
                                            imageWidth: d.imageWidth,
                                            summary:
                                                _doostihaResults[i].summary,
                                            meta: _doostihaResults[i].meta,
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) {
                                                  return SinglePage(
                                                    title: _doostihaResults[i]
                                                        .title,
                                                    image: _doostihaResults[i]
                                                        .image,
                                                    slug: _doostihaResults[i]
                                                        .slug!,
                                                    website: doostiha,
                                                  );
                                                },
                                              ));
                                            },
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            width: 10,
                                          ),
                                      itemCount: _doostihaResults.length),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                SizedBox(
                  height: 15,
                ),
                _loading[1]
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _uptvResults.length > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                      itemBuilder: (context, i) {
                                        return SizedBox(
                                          width: u.imageWidth,
                                          child: VideoCard(
                                            image: _uptvResults[i].image,
                                            title: _uptvResults[i].title,
                                            imageHeight: u.imageHeight,
                                            imageWidth: u.imageWidth,
                                            summary: _uptvResults[i].summary,
                                            meta: _uptvResults[i].meta,
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) {
                                                  return SinglePage(
                                                    title:
                                                        _uptvResults[i].title,
                                                    image:
                                                        _uptvResults[i].image,
                                                    slug: _uptvResults[i].slug!,
                                                    website: uptv,
                                                  );
                                                },
                                              ));
                                            },
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            width: 10,
                                          ),
                                      itemCount: _uptvResults.length),
                                ),
                              ],
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
