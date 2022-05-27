part of 'websites.dart';

class Digimovie extends Website {
  Digimovie()
      : super("https://digimovie.one", ".main_site > .item_def_loop",
            "digimovie");
  @override
  String _findTitle(Element post) {
    return cleanTitle(post.querySelector('.title_h > h2 > a')?.innerHtml ?? "");
  }

  @override
  String? _findSlug(Element post) {
    return post.querySelector('.title_h a')?.attributes['href'];
  }

  @override
  String _findImage(Element post) {
    return post.querySelector('img')?.attributes['src'] ?? noImage;
  }

  @override
  String _findSummary(Document document) {
    final summary = document
        .querySelector(".plot_text")
        ?.text
        .replaceAll(multiSpaceRegex, " ")
        .trim();
    return summary ?? "";
  }

  @override
  List<String> _findMetadata(Document document) {
    final metadata = document.querySelectorAll(".single_meta_data li");
    return [
      metadata
          .map((e) => e.text.replaceAll(multiSpaceRegex, " ").trim())
          .join("\n")
    ];
  }

  @override
  List<String> _findMetadataInCard(Element postEl) {
    var genre = postEl
            .querySelector(
                "div.meta_loop > div.meta_item > ul > li:nth-child(3) > .res_item")
            ?.innerHtml
            .trim() ??
        "";
    final country = postEl
            .querySelector(
                "div.meta_loop > div.meta_item > ul > li:nth-child(5) > .res_item")
            ?.innerHtml
            .trim() ??
        "";
    final rateBox = postEl.querySelector(".rate_num");
    final imdbRating = (rateBox?.querySelector("strong")?.innerHtml ?? "") +
        (rateBox?.querySelector("span")?.innerHtml ?? "");
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
    final linksElements = document.querySelectorAll('.dllink_holder');
    final title = document.querySelector('title')?.text.trim() ?? "";
    if (title.startsWith("دانلود سریال")) {
      return _findSerialLinks(document);
    } else {
      return _findMovieLinks(linksElements);
    }
  }

  _findSerialLinks(Document document) {
    final List<Element> linksElements =
        document.querySelectorAll('.item_row_series');
    Map<String, dynamic> links = {};
    var seasonTitle = "";
    var episodeTitle = "";
    for (var linkEl in linksElements) {
      seasonTitle = (linkEl.querySelector(".title_row h3")?.text ?? "") +
          " | " +
          (linkEl.querySelector(".head_left_side h3")?.text ?? "");
      links[seasonTitle] = {};
      final downloadItems = linkEl.querySelectorAll(".part_item");
      for (var item in downloadItems) {
        var linkTitle = "تماشا";
        episodeTitle = item.querySelector("a")?.attributes["title"] ?? "";
        final href = item.querySelector("a")?.attributes["href"];
        if (href == null) continue;
        final ext = href.substring(href.length - 3);
        if (!["mkv", "mp4"].contains(ext)) continue;
        if (links[seasonTitle][episodeTitle] == null) {
          links[seasonTitle][episodeTitle] = {};
        }
        links[seasonTitle][episodeTitle][linkTitle] = href;
      }
    }
    return links;
  }

  _findMovieLinks(List<Element> linksElements) {
    Map<String, dynamic> links = {};

    var rowTitle = "";
    for (var linkEl in linksElements) {
      final groupTitle = linkEl.querySelector(".right_title")?.text ?? "دانلود";
      links[groupTitle] = {};
      final downloadItems = linkEl.querySelectorAll(".itemdl");
      for (var item in downloadItems) {
        var linkTitle = "تماشا";
        rowTitle = item.querySelector("h3")?.text ?? "";
        final href = item.querySelector(".btn_dl")?.attributes["href"];
        if (href == null) continue;
        final ext = href.substring(href.length - 3);
        if (!["mkv", "mp4"].contains(ext)) continue;
        if (links[groupTitle][rowTitle] == null) {
          links[groupTitle][rowTitle] = {};
        }
        links[groupTitle][rowTitle][linkTitle] = href;
      }
    }
    return links;
  }

  Future<List<Post>> search(String q) async {
    try {
      final document = await _downloadAndParseDocument("/?s=$q");
      return parseDocument(document);
    } catch (e) {
      List<Post> empty = [];
      return empty;
    }
  }
}
