import 'package:tinycinema/ui/pages/list_page.dart';
import 'package:tinycinema/controller/website_ctl.dart';
import 'package:tinycinema/logic/websites/websites.dart';

const double imageHeight = 280;
const double imageWidth = 200;
const pageKey = "doostiha_movies";

class DoostihaCtl extends WebsiteCtl {
  DoostihaCtl() : super(Doostiha(), "/category/multimedia/khareji/film");
}

const categories = {
  "فیلم": "/category/multimedia/khareji/film",
  "سریال": "/category/multimedia/khareji/series",
  "انیمیشن": "/category/multimedia/khareji/animations",
  "مستند": "/category/multimedia/khareji/documentary",
};


Website website = Doostiha();

class DoostihaPage extends ListPage {
  DoostihaPage()
      : super(
            categories: categories,
            imageHeight: imageHeight,
            imageWidth: imageWidth,
            website: website,
            pageKey: pageKey);
}