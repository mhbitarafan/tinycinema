import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinycinema/global_keys.dart';
import 'package:tinycinema/logic/websites/models.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/types.dart';
import 'package:tinycinema/ui/pages/websites/doostiha_list.dart' as d;
import 'package:tinycinema/ui/pages/websites/uptv_list.dart' as u;
import 'package:tinycinema/ui/pages/video_card.dart';

Doostiha doostiha = Doostiha();
Uptv uptv = Uptv();
Digimovie digimovie = Digimovie();

class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  List<Post> _doostihaResults = [];
  List<Post> _uptvResults = [];
  List<Post> _digimovieResults = [];
  List<bool> _loading = [false, false, false];
  FocusNode searchInputNode = FocusNode(
    onKey: (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        firstSidebarFNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );

  @override
  void initState() {
    searchInputNode.requestFocus();
    super.initState();
  }

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
                node.requestFocus(firstSidebarFNode);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              focusNode: searchInputNode,
              decoration: InputDecoration(
                fillColor: Theme.of(context).cardColor,
                filled: true,
                border: OutlineInputBorder(),
                labelText: 'جستجو ...',
              ),
              onSubmitted: (String q) async {
                setState(() {
                  _loading[0] = true;
                });
                _digimovieResults = await digimovie.search(q);
                setState(() {
                  _loading[0] = false;
                });

                setState(() {
                  _loading[1] = true;
                });

                _doostihaResults = await doostiha.search(q);
                setState(() {
                  _loading[1] = false;
                });

                setState(() {
                  _loading[2] = true;
                });
                _uptvResults = await uptv.search(q);
                setState(() {
                  _loading[2] = false;
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
                    : _digimovieResults.length > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "دیجی موویز",
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
                                            image: _digimovieResults[i].image,
                                            title: _digimovieResults[i].title,
                                            imageHeight: d.imageHeight,
                                            imageWidth: d.imageWidth,
                                            summary:
                                                _digimovieResults[i].summary,
                                            meta: _digimovieResults[i].meta,
                                            slug: _digimovieResults[i].slug!,
                                            websiteType: WebsiteType.digimoviez,
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            width: 10,
                                          ),
                                      itemCount: _digimovieResults.length),
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
                                  height: u.imageHeight + 80,
                                  child: ListView.separated(
                                      reverse: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, i) {
                                        return SizedBox(
                                          width: u.imageWidth,
                                          child: VideoCard(
                                            image: _doostihaResults[i].image,
                                            title: _doostihaResults[i].title,
                                            imageHeight: u.imageHeight,
                                            imageWidth: u.imageWidth,
                                            summary:
                                                _doostihaResults[i].summary,
                                            meta: _doostihaResults[i].meta,
                                            slug: _doostihaResults[i].slug!,
                                            websiteType: WebsiteType.doostiha,
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
                _loading[2]
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
                                            slug: _uptvResults[i].slug!,
                                            websiteType: WebsiteType.uptv,
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
