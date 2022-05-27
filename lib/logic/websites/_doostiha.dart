part of 'websites.dart';

String searchMetadataOpt(Element el, String metaTitle,
    {String end = "|", String sep = ":"}) {
  try {
    var paragraphs = el.querySelectorAll("p");
    for (var p in paragraphs) {
      var i = p.text;
      var re = RegExp(metaTitle + ".*?" + sep);
      final _metaTitle = re.firstMatch(i)?.group(0) ?? "";
      if (_metaTitle.isEmpty || i.indexOf(_metaTitle) < 0) continue;
      var tmp = i.substring(i.indexOf(_metaTitle) + _metaTitle.length);
      return tmp
          .substring(0, end == "end" ? null : tmp.indexOf(end) - 1)
          .trim();
    }
    return "";
  } catch (e) {
    return "";
  }
}

String searchMetadata(Document el, String metaTitle,
    {String end = "|", String sep = ":"}) {
  try {
    var paragraphs = el.querySelectorAll("p");
    for (var p in paragraphs) {
      var i = p.text;
      var re = RegExp(metaTitle + ".*?" + sep);
      final _metaTitle = re.firstMatch(i)?.group(0) ?? "";
      if (_metaTitle.isEmpty || i.indexOf(_metaTitle) < 0) continue;
      var tmp = i.substring(i.indexOf(_metaTitle) + _metaTitle.length);
      return tmp
          .substring(0, end == "end" ? null : tmp.indexOf(end) - 1)
          .trim();
    }
    return "";
  } catch (e) {
    return "";
  }
}

class Doostiha extends Website {
  Doostiha() : super("https://www.doostihaa.com", "article.postsd", "doostiha");
  @override
  String _findTitle(Element post) {
    return cleanTitle(post.querySelector('h2 > a')?.innerHtml ?? "");
  }

  @override
  String? _findSlug(Element post) {
    return post.querySelector('a')?.attributes['href'];
  }

  @override
  String _findImage(Element post) {
    return post.querySelector('img')?.attributes['src'] ?? noImage;
  }

  @override
  String _findSummary(Document document) {
    final paragraphs =
        document.querySelector("div.textkian0")?.querySelectorAll('p');
    var attributes3 = paragraphs?[5].text ?? '';
    String summary = "";
    if (attributes3.contains("خلاصه داستان")) {
      attributes3 = '';
    }
    if (paragraphs != null) {
      for (var p in paragraphs) {
        if (p.querySelector('span') != null &&
            p.querySelector('span')!.text.contains("خلاصه داستان")) {
          summary = p.text.replaceAll('\n', ' ').replaceAll(RegExp(' +'), ' ');
          break;
        }
      }
    }
    return summary;
  }

  @override
  List<String> _findMetadata(Document document) {
    var genre = searchMetadata(document, "ژانر");
    if (genre.isEmpty) {
      genre = searchMetadata(document, "ژانـر");
    }
    final country = searchMetadata(document, "محصول", sep: " ")
        .replaceFirst("کشور", "")
        .trim();
    final imdbRating = searchMetadata(document, "امتیاز", end: "end");
    final duration = searchMetadata(document, "مدت");
    final quality = searchMetadata(document, "کیفیت", end: "end");
    return [
      [
        "ژانر: $genre",
        "کشور: $country",
        "امتیاز: $imdbRating",
        "مدت: $duration",
        "کیفیت: $quality"
      ].join(" | ")
    ];
  }

  @override
  List<String> _findMetadataInCard(Element postEl) {
    var genre = searchMetadataOpt(postEl, "ژانر");
    if (genre.isEmpty) {
      genre = searchMetadataOpt(postEl, "ژانـر");
    }
    final country = searchMetadataOpt(postEl, "محصول", sep: " ")
        .replaceFirst("کشور", "")
        .trim();
    final imdbRating = searchMetadataOpt(postEl, "امتیاز", end: "end");
    return [
      [genre, country, imdbRating].join(" | ")
    ];
  }

  @override
  String _findSummaryInCard(Element postEl) {
    final paragraphs =
        postEl.querySelector("div.textkian0")?.querySelectorAll('p');
    String summary = "";
    if (paragraphs != null) {
      for (var p in paragraphs) {
        summary = p.text.contains("خلاصه داستان")
            ? p.text.replaceAll("خلاصه داستان:", "").trim()
            : "";
      }
    }
    return summary;
  }

  @override
  _findLinks(Document document) {
    final linksElements =
        document.querySelector('div.textkian0')?.querySelectorAll('a');
    final title = document
            .querySelector('h1 > a')
            ?.innerHtml
            .replaceFirst("دانلود", "")
            .trim() ??
        "";
    if (linksElements == null) return {"": {}};
    if (title.startsWith("سریال") || title.startsWith("فصل")) {
      return _findSerialLinks(linksElements);
    } else {
      return _findMovieLinks(linksElements);
    }
  }

  _findSerialLinks(List<Element> linksElements) {
    Map<String, dynamic> links = {};
    var seasonTitle = "";
    var episodeTitle = "";
    for (var linkEl in linksElements) {
      final href = linkEl.attributes["href"]?.replaceFirst("?ref=3m8", "");
      if (href == null) continue;
      final foundSeasonTitle = linkEl.parent?.parent?.previousElementSibling
              ?.querySelector("span")
              ?.text
              .trim() ??
          "";
      if (foundSeasonTitle.startsWith("(")) {
        seasonTitle = foundSeasonTitle;
      }
      var linkTitle = linkEl.text.replaceFirst("دانلود", "").trim();
      final ext = href.substring(href.length - 3);
      if (!["mkv", "mp4"].contains(ext)) continue;
      final filename = href.split("/").last;
      if (linkTitle == "") {
        linkTitle = ["720", "1080", "480"]
            .firstWhere((element) => filename.contains(element));
      }
      if (links[seasonTitle] == null) {
        links[seasonTitle] = {};
      }

      if (linkTitle.startsWith("قسمت")) {
        episodeTitle =
            RegExp(r"قسمت .*?\s").firstMatch(linkTitle)?.group(0) ?? "";
        linkTitle = linkTitle
            .replaceFirst(episodeTitle, "")
            .replaceFirst("نسخه", "")
            .trim();
      } else {
        linkTitle = linkTitle.replaceFirst("نسخه", "").trim();
      }

      if (links[seasonTitle][episodeTitle] == null) {
        links[seasonTitle][episodeTitle] = {};
      }
      links[seasonTitle][episodeTitle][linkTitle] = href;
    }
    return links;
  }

  _findMovieLinks(List<Element> linksElements) {
    Map<String, dynamic> links = {};
    var rowTitle = "";
    for (var linkEl in linksElements) {
      final href = linkEl.attributes["href"]?.replaceFirst("?ref=3m8", "");
      if (href == null) continue;
      var linkTitle = linkEl.text.replaceFirst("دانلود", "").trim();
      final ext = href.substring(href.length - 3);
      if (!["mkv", "mp4"].contains(ext)) continue;
      final filename = href.split("/").last;
      if (linkTitle == "") {
        linkTitle = ["720", "1080", "480"]
            .firstWhere((element) => filename.contains(element));
      }
      if (linkTitle.startsWith("قسمت")) {
        rowTitle = RegExp(r"قسمت .*?\s").firstMatch(linkTitle)?.group(0) ?? "";
        linkTitle = linkTitle.replaceFirst(rowTitle, "").trim();
      }
      final groupTitle =
          filename.contains(".Dubbed") ? "دوبله فارسی" : "زیرنویس فارسی";
      if (links[groupTitle] == null) {
        links[groupTitle] = {};
      }
      if (links[groupTitle][rowTitle] == null) {
        links[groupTitle][rowTitle] = {};
      }
      links[groupTitle][rowTitle][linkTitle] = href;
    }
    return links;
  }

  Future<List<Post>> search(String q) async {
    final document = await _downloadAndParseDocument("/?s=$q");
    return parseDocument(document);
  }
}
