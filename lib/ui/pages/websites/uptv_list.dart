import 'package:tinycinema/logic/websites/websites.dart';
import 'package:tinycinema/types.dart';
import 'package:tinycinema/ui/pages/list_page.dart';

const double imageHeight = 290;
const double imageWidth = 207;
const pageKey = "uptv_movies";

const categories = {
  "فیلم": "/category/movie",
  "سریال": "/category/سریال-خارجی",
  "انیمیشن": "/category/animation",
  "برترین فیلم ها":
      "/category/250-%d9%81%db%8c%d9%84%d9%85-%d8%a8%d8%b1%d8%aa%d8%b1-imdb",
};

Website website = Uptv();

class UptvPage extends ListPage {
  UptvPage()
      : super(
            categories: categories,
            imageHeight: imageHeight,
            imageWidth: imageWidth,
            websiteType: WebsiteType.uptv,
            pageKey: pageKey);
}
