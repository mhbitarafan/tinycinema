import 'package:dio/dio.dart';
import 'package:dio_brotli_transformer/dio_brotli_transformer.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:tinycinema/logic/websites/utils.dart';
import 'models.dart';
part 'interface.dart';
part '_digimovie.dart';
part '_doostiha.dart';
part '_uptv.dart';

const noImage = 'https://via.placeholder.com/200';

abstract class Website implements PostParser, SinglePageParser, LinksParser {
  final String _baseUrl;
  final String _pagePath;
  final String _postSelector;
  final String key;
  late final Map<String, String> categories;
  final _httpClient = Dio();
  Website(this._baseUrl, this._postSelector, this.key,
      [this._pagePath = "/page/"]) {
    _httpClient.transformer = DioBrotliTransformer();
    _httpClient.options.baseUrl = _baseUrl;
  }

  Future<Document> _downloadAndParseDocument(String _path) async {
    final res = await _httpClient.get(_path);
    var rawHtml = res.data;
    return parse(rawHtml);
  }

  Future<List<Post>> parseDocument(Document document) async {
    List<Post> postList = [];
    final allPosts = document.querySelectorAll(_postSelector);
    for (var postEl in allPosts) {
      var post = Post(
        _findTitle(postEl),
        _findSlug(postEl),
        _findImage(postEl),
        _findSummaryInCard(postEl),
        _findMetadataInCard(postEl),
      );
      postList.add(post);
    }
    return postList;
  }

  Future<List<Post>> parsePage(String _path, int page) async {
    final document =
        await _downloadAndParseDocument(_path + _pagePath + page.toString());
    return parseDocument(document);
  }

  Future<SinglePageModel> parseSinglePage(String _path) async {
    final document = await _downloadAndParseDocument(_path);
    final summary = _findSummary(document);
    final meta = _findMetadata(document);
    final links = _findLinks(document);
    return SinglePageModel(document, summary, meta, links);
  }
}
