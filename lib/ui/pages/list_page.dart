import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinycinema/controller/website_ctl.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/ui/pages/single_page.dart';
import 'package:tinycinema/ui/pages/video_card.dart';

// for wrapping whole widget in a provider
class ListPage extends StatelessWidget {
  const ListPage(
      {Key? key,
      required this.website,
      required this.pageKey,
      required this.imageHeight,
      required this.imageWidth,
      required this.categories})
      : super(key: key);

  final Website website;
  final String pageKey;
  final double imageHeight;
  final double imageWidth;
  final Map<String, String> categories;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WebsiteCtl(website, categories.values.toList()[0]),
      child: ListPageChildren(
          pageKey: pageKey,
          categories: categories,
          imageHeight: imageHeight,
          imageWidth: imageWidth,
          website: website),
    );
  }
}

class ListPageChildren extends StatefulWidget {
  const ListPageChildren(
      {Key? key,
      required this.pageKey,
      required this.imageHeight,
      required this.imageWidth,
      required this.website,
      required this.categories})
      : super(key: key);
  final String pageKey;
  final double imageHeight;
  final double imageWidth;
  final Website website;
  final Map<String, String> categories;
  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPageChildren> {
  late final categories;
  late final Website website;
  late int catFocusIndex;
  List<Widget> categoryButtons = [];
  ScrollController _scrollCtl = ScrollController();
  ScrollController _categoryController = ScrollController();

  void getNext() async {
    context.read<WebsiteCtl>().getPage();
  }

  @override
  void initState() {
    categories = widget.categories;
    website = widget.website;
    catFocusIndex = categories.length;
    categoryBuilder();
    if (context.read<WebsiteCtl>().postList.length == 0) {
      getNext();
    }
    _scrollCtl.addListener(() {
      double maxScroll = _scrollCtl.position.maxScrollExtent;
      double currentScroll = _scrollCtl.position.pixels;
      double delta = 400.0;
      if (maxScroll - currentScroll <= delta &&
          context.read<WebsiteCtl>().canLoadMore) {
        getNext();
      }
    });
    super.initState();
  }

  void categoryBuilder() {
    categories.forEach((name, _path) {
      categoryButtons.add(ElevatedButton(
        onPressed: () async {
          await context.read<WebsiteCtl>().navigate(_path);
        },
        child: Text(name),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final websiteCtl = context.watch<WebsiteCtl>();

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Focus(
              canRequestFocus: false,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                controller: _categoryController,
                reverse: true,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 10,
                  );
                },
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return categoryButtons[index];
                },
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          websiteCtl.postList.length == 0
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: GridView.builder(
                    key: PageStorageKey(widget.pageKey),
                    controller: _scrollCtl,
                    itemCount: websiteCtl.postList.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        maxCrossAxisExtent: widget.imageWidth,
                        mainAxisExtent: widget.imageHeight + 80),
                    itemBuilder: (BuildContext context, int index) {
                      return VideoCard(
                        title: websiteCtl.postList[index].title,
                        image: websiteCtl.postList[index].image,
                        imageHeight: widget.imageHeight,
                        summary: websiteCtl.postList[index].summary,
                        meta: websiteCtl.postList[index].meta,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return SinglePage(
                                title: websiteCtl.postList[index].title,
                                image: websiteCtl.postList[index].image,
                                slug: websiteCtl.postList[index].slug!,
                                website: widget.website,
                              );
                            },
                          ));
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
