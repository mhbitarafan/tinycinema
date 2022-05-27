part of 'websites.dart';

abstract class PostParser {
  String _findTitle(Element postEl);
  String _findImage(Element postEl);
  String? _findSlug(Element postEl);
  List<String> _findMetadataInCard(Element postEl);
  String _findSummaryInCard(Element postEl);
}

abstract class SinglePageParser {
  List<String> _findMetadata(Document document);
  String _findSummary(Document document);
}

abstract class LinksParser {
  Map<String, dynamic> _findLinks(Document document);
}
