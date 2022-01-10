import 'package:html/dom.dart';

class SinglePageModel {
  final String summary;
  final List<String> meta;
  Map<String, dynamic> links;
  final Document document;
  SinglePageModel(this.document, this.summary, this.meta, this.links);
}

class Post {
  final String title;
  final String? slug;
  final String image;
  String? summary;
  List<String>? meta;
  Post(this.title, this.slug, this.image, [this.summary, this.meta]);
  Post.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        slug = json['slug'],
        image = json['image'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'slug': slug,
        'image': image,
      };
}

class Link {
  final String name;
  final String url;
  Link(this.name, this.url);
}
