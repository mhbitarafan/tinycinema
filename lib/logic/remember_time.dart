import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RememberTime {
  static final RememberTime _myFavorite = RememberTime._internal();
  factory RememberTime() => _myFavorite;
  RememberTime._internal() {
    getTimingFile();
  }
  Future<File> getTimingFile() async {
    var appTempDir = await getTemporaryDirectory();
    print(appTempDir);
    return File(appTempDir.path + "/remember_time.json").create();
  }

  List<Map<String, dynamic>> rememberTimeList = [];
  File? rememberTimeFile;

  void addOrUpdateVideo(String videoUrl, Duration time) async {
    if (didRemember(videoUrl)) {
      final index =
          rememberTimeList.indexWhere((element) => element["slug"] == videoUrl);
      rememberTimeList[index] = {"slug": videoUrl, "time": time};
      rememberTimeFile?.writeAsString(json.encode(rememberTimeList));
    } else {
      rememberTimeList.add({"slug": videoUrl, "time": time});
      rememberTimeFile?.writeAsString(json.encode(rememberTimeList));
    }
  }

  Future<void> getTimeList() async {
    rememberTimeFile = await getTimingFile();
    if (rememberTimeFile != null) {
      rememberTimeList = json.decode(rememberTimeFile!.readAsStringSync());
      print(rememberTimeList);
    }
  }

  bool didRemember(String videoUrl) {
    for (var a in rememberTimeList) {
      if (a["slug"] == videoUrl) {
        return true;
      }
    }
    return false;
  }

  Duration getVideoRememberedTime(String videoUrl) {
    for (var a in rememberTimeList) {
      if (a["slug"] == videoUrl) {
        return a["time"] as Duration;
      }
    }
    return Duration();
  }
}
