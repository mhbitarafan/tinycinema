import 'package:flutter/cupertino.dart';
import 'package:tinycinema/logic/websites/models.dart';
import 'package:tinycinema/logic/websites/websites.dart';

class WebsiteCtl extends ChangeNotifier {
  Website _website;
  String currentRoute;
  var canLoadMore = true;
  var currentPage = 1;
  bool _disposed = false;
  bool error = false;
  List<Post> postList = [];

  WebsiteCtl(this._website, this.currentRoute);

  Future<void> getPage() async {
    canLoadMore = false;
    try {
      error = false;
      var _newList = await _website.parseHtmlPage(currentRoute, currentPage);
      postList.addAll(_newList);
      currentPage++;
      canLoadMore = true;
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      error = true;
    }
  }

  Future<void> navigate(String route) async {
    reset();
    currentRoute = route;
    await getPage();
  }

  void reset() {
    canLoadMore = true;
    currentPage = 1;
    postList = [];
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
