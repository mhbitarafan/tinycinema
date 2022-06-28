part of 'websites.dart';

class Digimovie extends Website {
  Digimovie()
      : super("https://digimovie.sbs", ".main_site > .item_def_loop",
            WebsiteType.digimoviez);

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
    final rateBox = document.querySelector(".num_holder");
    final imdbRating = (rateBox?.querySelector("strong")?.innerHtml ?? "") +
        "/10 " +
        (rateBox
                ?.querySelector("span")
                ?.innerHtml
                .replaceFirst("Votes", "رای") ??
            "");
    var formatted_metadata = "";
    for (var i = 1; i < metadata.length; i++) {
      formatted_metadata +=
          metadata[i].text.replaceAll(multiSpaceRegex, " ").trim();
      if (i % 2 == 0 && i != metadata.length - 1) {
        formatted_metadata += "\n";
      } else {
        formatted_metadata += " | ";
      }
    }
    return [formatted_metadata, imdbRating];
  }

  @override
  List<String> _findMetadataInCard(Element postEl) {
    var genre = postEl
            .querySelector(
                "div.meta_loop > div.meta_item > ul > li:nth-child(3) > .res_item")
            ?.text
            .trim() ??
        "";
    final country = postEl
            .querySelector(
                "div.meta_loop > div.meta_item > ul > li:nth-child(5) > .res_item")
            ?.text
            .trim() ??
        "";
    final rateBox = postEl.querySelector(".rate_num");
    final imdbRating = (rateBox?.querySelector("strong")?.innerHtml ?? "") +
        "/10 " +
        (rateBox
                ?.querySelector("span")
                ?.innerHtml
                .replaceFirst("Votes", "رای") ??
            "");
    return [
      [genre, country, imdbRating].join(" | ")
    ];
  }

  @override
  String _findSummaryInCard(Element postEl) {
    return postEl
            .querySelector(".plot_text")
            ?.text
            .replaceAll(multiSpaceRegex, " ")
            .trim() ??
        "";
  }

  @override
  _findLinks(Document document) {
    if (document.querySelector(".side_right > .guest_line_comments") != null) {
      return null;
    }
    final linksElements = document.querySelectorAll('.dllink_holder');
    final title = document.querySelector('title')?.text.trim() ?? "";
    if (title.startsWith("دانلود سریال")) {
      return _findSerialLinks(document);
    } else {
      return _findMovieLinks(linksElements);
    }
  }

  List<Link>? _findSerialLinks(Document document) {
    final List<Element> linksElements =
        document.querySelectorAll('.item_row_series');
    List<Link> links = [];
    var seasonTitle = "";
    var episodeTitle = "";
    for (var linkEl in linksElements) {
      seasonTitle = (linkEl.querySelector(".title_row h3")?.text ?? "") +
          " | " +
          (linkEl.querySelector(".head_left_side h3")?.text ?? "");
      final downloadItems = linkEl.querySelectorAll(".part_item");
      for (var item in downloadItems) {
        var linkTitle =
            cleanTitle(item.querySelector("a")?.attributes["title"] ?? "");
        final href = item.querySelector("a")?.attributes["href"];
        if (href == null) continue;
        final ext = href.substring(href.length - 3);
        if (!["mkv", "mp4"].contains(ext)) continue;
        links.add(Link(
            href: href,
            row: episodeTitle,
            group: seasonTitle,
            quality: linkTitle));
      }
    }
    return links;
  }

  List<Link>? _findMovieLinks(List<Element> linksElements) {
    List<Link> links = [];
    var rowTitle = "";
    for (var linkEl in linksElements) {
      final groupTitle = linkEl.querySelector(".right_title")?.text ?? "دانلود";
      final downloadItems = linkEl.querySelectorAll(".itemdl");
      for (var item in downloadItems) {
        var linkTitle = cleanTitle(item.querySelector("h3")?.text ?? "");
        final href = item.querySelector(".btn_dl")?.attributes["href"];
        if (href == null) continue;
        final ext = href.substring(href.length - 3);
        if (!["mkv", "mp4"].contains(ext)) continue;
        links.add(Link(
            href: href, row: rowTitle, group: groupTitle, quality: linkTitle));
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

  String _findTrailer(Document document) {
    return document
            .querySelector("[data-trailerlink]")
            ?.attributes["data-trailerlink"] ??
        "";
  }
}
