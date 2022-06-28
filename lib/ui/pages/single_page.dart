import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/logic/favorites.dart';
import 'package:tinycinema/logic/websites/models.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/types.dart';
import 'package:tinycinema/ui/pages/mpv_player/mpv_player.dart';
import 'package:url_launcher/url_launcher.dart';

class SinglePageArgs {
  final String title;
  final String slug;
  final String image;
  final WebsiteType websiteType;

  SinglePageArgs(this.title, this.image, this.slug, this.websiteType);
}

class SinglePage extends StatefulWidget {
  const SinglePage({
    Key? key,
  }) : super(key: key);

  @override
  SinglePageState createState() => SinglePageState();
}

class SinglePageState extends State<SinglePage> with TickerProviderStateMixin {
  late SinglePageModel _singlePage;
  late TabController _tabController;
  late Post post;
  bool _loading = true;
  late SinglePageArgs args;
  late Website website;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    args = ModalRoute.of(context)!.settings.arguments as SinglePageArgs;
    website = websitesMapping[args.websiteType]!;
    post = Post(args.title, args.slug, args.image, args.websiteType);
    website.parseSinglePage(args.slug).then((value) {
      _singlePage = value;
      _tabController = TabController(
          length: _singlePage.links?.groups?.length ?? 0, vsync: this);
      _loading = false;
      setState(() {});
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
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
                              InkWell(
                                onTap: () {
                                  launchUrl(Uri.parse(args.slug));
                                },
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: 250),
                                  child: Image.network(args.image),
                                ),
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
                                    Row(
                                      children: [
                                        myFavorite.isFavorite(post)
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  myFavorite
                                                      .removeFavorite(post);
                                                  setState(() {});
                                                },
                                                child: Text("حذف از لیست"),
                                              )
                                            : ElevatedButton(
                                                autofocus: true,
                                                onPressed: () {
                                                  myFavorite.addFavorite(post);
                                                  setState(() {});
                                                },
                                                child: Text("افزودن به لیست"),
                                              ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        _singlePage.trailer.isNotEmpty
                                            ? ElevatedButton(
                                                child: Text("تریلر"),
                                                onPressed: () async {
                                                  if (Platform.isWindows) {
                                                    Process.run(mpvPlayerPath,
                                                        [_singlePage.trailer]);
                                                  } else {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return MpvPlayerPage(
                                                              url: _singlePage
                                                                  .trailer);
                                                        },
                                                      ),
                                                    );
                                                  }
                                                },
                                                onLongPress: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: _singlePage
                                                              .trailer));
                                                },
                                              )
                                            : Container(),
                                      ],
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

List<Widget> createTabs(Links? link_data) {
  List<Widget> _tabs = [];
  if (link_data == null) return _tabs;
  for (var group_title in link_data.groups!) {
    _tabs.add(Tab(
      text: group_title,
    ));
  }
  return _tabs;
}

List<Widget> createTabsContent(Links? link_data, BuildContext context) {
  if (link_data == null) return [Text("پولی")];
  List<Widget> _tabsContent = [];
  for (var group in link_data.groups!) {
    final groupLinks = link_data.linksOfGroup(group)!;
    final linksColumn = createTabContent(Links(groupLinks), context);
    _tabsContent.add(SingleChildScrollView(
      child: linksColumn,
    ));
  }
  return _tabsContent;
}

Widget createTabContent(Links links_data, BuildContext context) {
  final linksColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [],
  );
  for (var row in links_data.rows!) {
    final linkRow = Wrap(
      runSpacing: 10,
      spacing: 10,
      children: [Text(row)],
    );
    for (var row_link in links_data.linksOfRow(row)!) {
      linkRow.children.add(Tooltip(
        message: row_link.href,
        child: ElevatedButton(
          child: Text(row_link.quality),
          onPressed: () async {
            if (Platform.isWindows) {
              Process.run(mpvPlayerPath, [row_link.href]);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return MpvPlayerPage(
                        url: row_link.href, links_data: links_data);
                  },
                ),
              );
            }
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: row_link.href));
          },
        ),
      ));
    }
    linksColumn.children.add(linkRow);
    linksColumn.children.add(SizedBox(height: 10));
  }
  return linksColumn;
}
