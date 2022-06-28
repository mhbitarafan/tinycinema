import 'package:tinycinema/logic/websites/websites.dart';

enum WebsiteType { digimoviez, uptv, doostiha }

final Map<WebsiteType, Website> websitesMapping = {
  WebsiteType.digimoviez: Digimovie(),
  WebsiteType.doostiha: Doostiha(),
  WebsiteType.uptv: Uptv(),
};

final Map<WebsiteType, String> websiteTypeStringMapping = {
  WebsiteType.digimoviez: "digimoviez",
  WebsiteType.doostiha: "doostiha",
  WebsiteType.uptv: "uptv",
};
