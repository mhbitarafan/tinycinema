import 'package:tinycinema/ui/pages/list_page.dart';
import 'package:tinycinema/controller/website_ctl.dart';
import 'package:tinycinema/logic/websites/websites.dart';

const double imageHeight = 280;
const double imageWidth = 200;
const pageKey = "digi_movies";

class DoostihaCtl extends WebsiteCtl {
  DoostihaCtl() : super(Digimovie(), "/");
}

const categories = {
  "فیلم": "/category/دانلود-فیلم",
  "سریال": "/category/سریال",
  "انیمیشن": "/category/انیمیشن",
  "سریال انیمیشن": "/category/سریال-انیمیشنی",
};

Website website = Digimovie();

class DigimoviePage extends ListPage {
  DigimoviePage()
      : super(
            categories: categories,
            imageHeight: imageHeight,
            imageWidth: imageWidth,
            website: website,
            pageKey: pageKey);
}
