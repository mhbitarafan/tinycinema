import 'package:tinycinema/types.dart';
import 'package:tinycinema/ui/pages/list_page.dart';
import 'package:tinycinema/logic/websites/websites.dart';

const double imageHeight = 280;
const double imageWidth = 200;
const pageKey = "doostiha_movies";

const categories = {
  "فیلم": "/category/multimedia/foreign/films",
  "سریال": "/category/multimedia/foreign/series",
  "انیمیشن": "/category/multimedia/animation-cartoon",
  "مستند": "/category/multimedia/documentary",
};

Website website = Doostiha();

class DoostihaPage extends ListPage {
  DoostihaPage()
      : super(
            categories: categories,
            imageHeight: imageHeight,
            imageWidth: imageWidth,
            websiteType: WebsiteType.doostiha,
            pageKey: pageKey);
}
