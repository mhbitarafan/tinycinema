import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinycinema/controller/website_ctl.dart';
import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/types.dart';
import 'package:tinycinema/ui/pages/video_card.dart';

// for wrapping whole widget in a provider
class ListPage extends StatelessWidget {
  const ListPage({
    Key? key,
    required this.websiteType,
    required this.pageKey,
    required this.imageHeight,
    required this.imageWidth,
    required this.categories,
  }) : super(key: key);

  final WebsiteType websiteType;
  final String pageKey;
  final double imageHeight;
  final double imageWidth;
  final Map<String, String> categories;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WebsiteCtl(
          websitesMapping[websiteType]!, categories.values.toList()[0]),
      child: ListPageChildren(
          pageKey: pageKey,
          categories: categories,
          imageHeight: imageHeight,
          imageWidth: imageWidth,
          website: websiteType),
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
  final WebsiteType website;
  final Map<String, String> categories;
  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPageChildren> {
  late final categories;
  late final Website website;
  late int catFocusIndex;
  List<Widget> categoryButtons = [];
  late ScrollController _scrollCtl;
  ScrollController _categoryController = ScrollController();

  void getNext() async {
    context.read<WebsiteCtl>().getPage();
  }

  @override
  void initState() {
    _scrollCtl = ScrollController();
    categories = widget.categories;
    website = websitesMapping[widget.website]!;
    catFocusIndex = categories.length;
    categoryBuilder();
    if (Provider.of<WebsiteCtl>(context, listen: false).postList.length == 0) {
      getNext();
    }
    _scrollCtl.addListener(() {
      double maxScroll = _scrollCtl.position.maxScrollExtent;
      double currentScroll = _scrollCtl.position.pixels;
      double delta = 400.0;
      ;
      if (maxScroll - currentScroll <= delta &&
          Provider.of<WebsiteCtl>(context, listen: false).canLoadMore) {
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
    if (websiteCtl.error) {
      return Container(
        padding: EdgeInsets.all(12),
        child: Text("خطا لطفا اتصال اینترنت خود را بررسی نمایید."),
      );
    } else {
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
                      // key: PageStorageKey(widget.pageKey),
                      controller: _scrollCtl,
                      itemCount: websiteCtl.postList.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          mainAxisSpacing: 3,
                          crossAxisSpacing: 3,
                          maxCrossAxisExtent: widget.imageWidth,
                          mainAxisExtent: widget.imageHeight + 80),
                      itemBuilder: (BuildContext context, int index) {
                        return VideoCard(
                          title: websiteCtl.postList[index].title,
                          image: websiteCtl.postList[index].image,
                          imageHeight: widget.imageHeight,
                          summary: websiteCtl.postList[index].summary,
                          meta: websiteCtl.postList[index].meta,
                          slug: websiteCtl.postList[index].slug!,
                          websiteType: widget.website,
                        );
                      },
                    ),
                  ),
          ],
        ),
      );
    }
  }
}
