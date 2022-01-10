import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/logic/favorites.dart';
import 'package:tinycinema/logic/websites/models.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/ui/pages/doostiha/doostiha_list.dart';
import 'package:tinycinema/ui/pages/video_player.dart';

class SinglePage extends StatefulWidget {
  const SinglePage(
      {Key? key,
      required this.title,
      required this.slug,
      required this.image,
      required this.website})
      : super(key: key);
  final String title;
  final String slug;
  final String image;
  final Website website;
  @override
  SinglePageState createState() => SinglePageState();
}

class SinglePageState extends State<SinglePage> with TickerProviderStateMixin {
  MyFavorite myFavorite = MyFavorite();
  late SinglePageModel _singlePage;
  late TabController _tabController;
  late Post post;
  bool _loading = true;
  @override
  void initState() {
    post = Post(widget.title, widget.slug, widget.image);
    widget.website.parseSinglePage(widget.slug).then((value) {
      _singlePage = value;
      _tabController =
          TabController(length: _singlePage.links.length, vsync: this);
      _loading = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: _loading == false
                  ? Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            runSpacing: 10,
                            spacing: 10,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: 250),
                                child: Image.network(widget.image),
                              ),
                              Container(
                                width: 600,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _singlePage.summary,
                                      style:
                                          TextStyle(height: 2.5, fontSize: 18),
                                    ),
                                    Text(
                                      _singlePage.meta.join("\n"),
                                      style: TextStyle(
                                          height: 2.5,
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    myFavorite.isFavorite(
                                            post.toJson(), widget.website.key)
                                        ? ElevatedButton(
                                            onPressed: () {
                                              myFavorite.removeFavorite(
                                                  post.toJson(),
                                                  widget.website.key);
                                              setState(() {});
                                            },
                                            child: Text("حذف از لیست"),
                                          )
                                        : ElevatedButton(
                                            onPressed: () {
                                              myFavorite.addFavorite(
                                                  post.toJson(),
                                                  widget.website.key);
                                              setState(() {});
                                            },
                                            child: Text("افزودن به لیست"),
                                          ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 500,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                controller: _tabController,
                                labelColor: Theme.of(context).primaryColor,
                                isScrollable: true,
                                tabs: createTabs(_singlePage.links),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: createTabsContent(
                                      _singlePage.links, context),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> createTabs(Map<String, dynamic> links) {
  List<Widget> _tabs = [];
  links.forEach((key, _) {
    _tabs.add(Tab(
      text: key,
    ));
  });
  return _tabs;
}

List<Widget> createTabsContent(
    Map<String, dynamic> links, BuildContext context) {
  List<Widget> _tabsContent = [];
  links.forEach((_, box) {
    final linkColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );
    box.forEach((groupKey, groupValue) {
      final linkRow = Wrap(
        runSpacing: 10,
        spacing: 10,
        children: [Text(groupKey)],
      );
      groupValue.forEach((linkTitle, link) {
        linkRow.children.add(Tooltip(
          message: link,
          child: ElevatedButton(
            child: Text(linkTitle),
            onPressed: () async {
              if (Platform.isWindows) {
                final realUri = (await Dio().head(link)).realUri.toString();
                Process.run(potPlayerPath, [realUri]);
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return MyVideoPlayer(url: link);
                  },
                ));
              }
            },
          ),
        ));
      });
      linkColumn.children.add(linkRow);
      linkColumn.children.add(SizedBox(height: 10));
    });
    _tabsContent.add(SingleChildScrollView(
      child: linkColumn,
    ));
  });
  return _tabsContent;
}
