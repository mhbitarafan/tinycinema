part of 'websites.dart';

class Uptv extends Website {
  Uptv() : super("https://www.uptvs.com", "article", WebsiteType.uptv);

  @override
  String _findTitle(Element post) {
    return post
            .querySelector('div.post-layout-header')
            ?.text
            .replaceFirst('دانلود', '')
            .trim() ??
        "";
  }

  @override
  String? _findSlug(Element post) {
    return post.querySelector('.post-layout-header a')?.attributes['href'];
  }

  @override
  String _findImage(Element post) {
    return post.querySelector('img')?.attributes['src'] ?? noImage;
  }

  @override
  String _findSummary(Document document) {
    return document.querySelector(".show-read-more")?.text.trim() ?? "";
  }

  @override
  List<String> _findMetadata(Document document) {
    final metaList = document
        .querySelector(".post-single-meta > div > div.col-md.col-lg")
        ?.text
        .split("|");

    final genre = metaList?[0].trim() ?? "";
    final country = metaList?[3].trim() ?? "";
    final duration = metaList?[4].trim() ?? "";
    final imdbRating = document
            .querySelector(
                "div > div.col-md-auto.col-auto.xs-p-0.ml-lg-30.ml-md-15")
            ?.text
            .trim() ??
        "N/A";
    return [
      [
        "ژانر: $genre",
        "کشور: $country",
        "مدت: $duration",
        "امتیاز: $imdbRating"
      ].join(" | ")
    ];
  }

  @override
  _findLinks(Document document) {
    final title = document.querySelector('h1')?.text.trim() ?? "";
    if (title.startsWith("سریال")) {
      return _findSerialLinks(document);
    } else {
      return _findMovieLinks(document);
    }
  }

  List<Link>? _findSerialLinks(Document document) {
    List<Link> links = [];
    var seasonTitlesElements = document
        .querySelectorAll("div.new-tab-holder.position-relative > div > a");
    var seasonBoxes = document.querySelectorAll(".new-tab-content");

    for (int i = 0; i < seasonTitlesElements.length; i++) {
      final seasonTitle = seasonTitlesElements[i].text.trim();
      var episodeBoxes =
          seasonBoxes[i].querySelectorAll(".post-content-download-item > div");
      for (var episodeBox in episodeBoxes) {
        final episodeTitle = episodeBox
                .querySelector("div:first-child")
                ?.text
                .trim()
                .replaceAll(RegExp(r'\s+'), ' ') ??
            "";
        List<Element> linkElements = episodeBox.querySelectorAll("div > a");
        for (var linkEl in linkElements) {
          final href = linkEl.attributes["href"]?.replaceFirst("?ref=7xk", "");
          var linkTitle = linkEl
                  .querySelector("span:first-child")
                  ?.text
                  .replaceFirst("دانلود", "")
                  .trim() ??
              "";
          if (href == null) continue;
          final ext = href.substring(href.length - 3);
          if (!["mkv", "mp4"].contains(ext)) continue;
          final filename = href.split("/").last;
          if (linkTitle == "") {
            linkTitle = ["720", "1080", "480"]
                .firstWhere((element) => filename.contains(element));
          }
          links.add(Link(
              href: href,
              row: episodeTitle,
              group: seasonTitle,
              quality: linkTitle));
        }
      }
    }
    return links;
  }

  List<Link>? _findMovieLinks(Document document) {
    final linkBoxesEl =
        document.querySelectorAll('.post-content-download-box > div');
    List<Link> links = [];
    for (var linkBoxEl in linkBoxesEl) {
      var groupTitle = linkBoxEl.querySelector(".badge")?.text.trim() ?? "";
      List<Element> linkElements =
          linkBoxEl.querySelectorAll("div:last-child > a");
      for (var linkEl in linkElements) {
        final href = linkEl.attributes["href"]?.replaceFirst("?ref=7xk", "");
        var linkTitle = linkEl
                .querySelector("span:first-child")
                ?.text
                .replaceFirst("دانلود", "")
                .trim() ??
            "";
        if (href == null) continue;
        final ext = href.substring(href.length - 3);
        if (!["mkv", "mp4"].contains(ext)) continue;
        final filename = href.split("/").last;
        if (linkTitle == "") {
          linkTitle = ["720", "1080", "480"]
              .firstWhere((element) => filename.contains(element));
        }
        links.add(
            Link(href: href, row: "", group: groupTitle, quality: linkTitle));
      }
    }
    return links;
  }

  @override
  List<String> _findMetadataInCard(Element postEl) {
    late final genre, releaseDate, country, imdbRating;
    genre = postEl
            .querySelector(
                "div.w-100.post-layout-meta.small-12.pt-lg-half.pt-md-half.pt-10.pb-lg-15.pb-md-15.text-gray.border-bottom > span:nth-child(1) > a")
            ?.innerHtml
            .trim() ??
        "";
    final metaElements = postEl.querySelectorAll(
        ".clearfix.d-lg-block.d-md-block.d-none.mt-md-20 > div");
    releaseDate =
        metaElements[0].querySelector(".text-gray-2")?.text.trim() ?? "";
    country = metaElements[1].querySelector(".text-gray-2")?.text.trim() ?? "";

    try {
      imdbRating =
          metaElements[2].querySelector(".text-gray-2")?.text.trim() ?? "N/A";
    } catch (e) {
      imdbRating = "N/A";
    }
    List<String> meta = [
      [genre, releaseDate, country, imdbRating].join(" | ")
    ];
    return meta;
  }

  @override
  String _findSummaryInCard(Element postEl) {
    final summary = postEl
            .querySelector(
                "div.alert.d-lg-block.d-md-none.d-none.mb-20.alert-dark")
            ?.innerHtml
            .trim() ??
        "";
    return summary;
  }

  Future<List<Post>> search(String q) async {
    final document = await _downloadAndParseDocument("/?s=$q");
    return parseDocument(document);
  }

  @override
  String _findTrailer(Document document) {
    return document.querySelector("source")?.attributes["src"] ?? "";
  }
}
