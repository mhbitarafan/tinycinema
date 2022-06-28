import 'package:html/dom.dart';
import 'package:tinycinema/types.dart';

class SinglePageModel {
  final String summary;
  final List<String> meta;
  final String trailer;
  Links? links;
  final Document document;
  SinglePageModel(
      this.document, this.summary, this.meta, this.trailer, this.links);
}

class Post {
  final String title;
  final String? slug;
  final String image;
  String? summary;
  List<String>? meta;
  final WebsiteType websiteType;
  String get websiteKey => websiteTypeStringMapping[websiteType]!;
  Post(
    this.title,
    this.slug,
    this.image,
    this.websiteType, {
    this.summary,
    this.meta,
  });
  Post.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        slug = json['slug'],
        image = json['image'],
        websiteType = websiteTypeStringMapping.keys.firstWhere(
            (k) => websiteTypeStringMapping[k] == json['websiteKey']);

  Map<String, dynamic> toJson() => {
        'title': title,
        'slug': slug,
        'image': image,
        'websiteKey': websiteKey,
      };
}

class Link {
  Link(
      {required this.href,
      required this.row,
      required this.group,
      required this.quality});
  final String href;
  final String row;
  final String group;
  final String quality;
}

class Links {
  Links(this.links);
  final List<Link>? links;
  List<String>? get groups => links?.map((e) => e.group).toSet().toList();
  List<String>? get rows => links?.map((e) => e.row).toSet().toList();
  int currentIndex = 0;

  Link? nextLink() {
    if (currentIndex >= links!.length - 1) return null;
    final nextLinks = links!.sublist(currentIndex + 1);
    for (var i = 0; i < nextLinks.length; i++) {
      final link = nextLinks[i];
      if (link.quality == links![currentIndex].quality) {
        currentIndex = i;
        return link;
      }
    }
    return null;
  }

  Link? prevLink() {
    if (currentIndex <= 0) return null;
    final nextLinks = links!.sublist(0, currentIndex).reversed.toList();
    late Link link;
    for (var i = 0; i < nextLinks.length; i++) {
      link = nextLinks[i];
      if (link.quality == links![currentIndex].quality) {
        currentIndex = i;
        return link;
      }
    }
    return null;
  }

  bool get hasPrevLink {
    if (currentIndex <= 0) return false;
    final nextLinks = links!.sublist(0, currentIndex).reversed.toList();
    late Link link;
    for (var i = 0; i < nextLinks.length; i++) {
      link = nextLinks[i];
      if (link.quality == links![currentIndex].quality) {
        return true;
      }
    }
    return false;
  }

  bool get hasNextLink {
    if (currentIndex >= links!.length - 1) return false;
    final nextLinks = links!.sublist(currentIndex + 1);
    for (var i = 0; i < nextLinks.length; i++) {
      final link = nextLinks[i];
      if (link.quality == links![currentIndex].quality) {
        return true;
      }
    }
    return false;
  }

  List<Link>? linksOfGroup(String groupName) {
    List<Link> groupLinks = [];
    bool foundFirstTime = false;
    for (var link in links!) {
      if (foundFirstTime == true && link.group != groupName) {
        break;
      }
      if (link.group == groupName) {
        foundFirstTime == true;
        groupLinks.add(link);
      }
    }
    return groupLinks;
  }

  List<Link>? linksOfRow(String rowName) {
    List<Link> rowLinks = [];
    bool foundFirstTime = false;
    for (var link in links!) {
      if (foundFirstTime == true && link.row != rowName) {
        break;
      }
      if (link.row == rowName) {
        foundFirstTime == true;
        rowLinks.add(link);
      }
    }
    return rowLinks;
  }
}

class LinksRow {
  final String rowTitle;
  final List<Link> links;
  LinksRow(this.rowTitle, this.links);
}

typedef LinksCol = List<LinksRow>;

class LinksTab {
  final String tabTitle;
  final List<LinksCol> linksCol;
  LinksTab(this.tabTitle, this.linksCol);
}
