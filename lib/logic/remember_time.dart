import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RememberTime {
  static final RememberTime _myFavorite = RememberTime._internal();

  factory RememberTime() => _myFavorite;

  RememberTime._internal() {
    getTimingFile();
  }

  Future<File?> getTimingFile() async {
    try {
      var appTempDir = await getTemporaryDirectory();
      return File(appTempDir.path + "/remember_time.json").create();
    } catch (err) {
      return null;
    }
  }

  List<Map<String, dynamic>> rememberTimeList = [];
  File? rememberTimeFile;

  void addOrUpdateVideo(String videoUrl, Duration time) async {
    final index =
        rememberTimeList.indexWhere((element) => element["slug"] == videoUrl);
    if (index != -1) {
      rememberTimeList[index]["time"] = time;
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
    }
  }

  Duration? getVideoRememberedTime(String videoUrl) {
    for (var a in rememberTimeList) {
      if (a["slug"] == videoUrl) {
        return a["time"] as Duration;
      }
    }
    return null;
  }
}
