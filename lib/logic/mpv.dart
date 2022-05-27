import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tinycinema/utils.dart';

// "http://dl7.freeserver.top/www2/film/1401/02/Everything.Everywhere.All.at.Once.2022.720p.10bit.WEB-DL.6CH.x265.SoftSub.DigiMoviez.mkv",
class MPV extends ChangeNotifier {
  String url = "";
  Duration? duration;
  bool paused = true;
  int subtitle_id = 0;
  int audio_id = 0;

  String get durationFormatted {
    if (duration == null || position == null) return "";
    return durationPrettify(duration!) + " / " + durationPrettify(position!);
  }

  Duration? position;

  MethodChannel methodChannel = MethodChannel('mpv_method_channel');

  Map<String, dynamic> get creationParams => {"url": url};

  MPV() {
    methodChannel.setMethodCallHandler((call) {
      log.info("${call.method} runtype ${call.arguments}");
      switch (call.method) {
        case "duration":
          duration = Duration(seconds: call.arguments as int);
          notifyListeners();
          break;
        case "time-pos":
          position = Duration(seconds: call.arguments as int);
          notifyListeners();
          break;
        case "pause":
          paused = call.arguments as bool;
          log.info("paused | $paused");
          notifyListeners();
          break;
        case "aid":
          audio_id = call.arguments as int;
          notifyListeners();
          break;
        case "sid":
          subtitle_id = call.arguments as int;
          notifyListeners();
          break;
      }
      return Future.value("");
    });
  }

  void seek(Duration position) {
    methodChannel.invokeMethod("seek", position.inSeconds);
  }

  void forward10() {
    methodChannel.invokeMethod("forward10");
  }

  void backward10() {
    methodChannel.invokeMethod("backward10");
  }

  Future<void> load(String url) async {
    this.url = (await Dio().head(url,
            options: Options(
              followRedirects: true,
            )))
        .realUri
        .toString()
        .replaceFirst("https", "http");
  }

  void cyclePause() {
    methodChannel.invokeMethod("cyclePause");
  }

  void cycleAudio() {
    methodChannel.invokeMethod("cycleAudio");
  }

  void cycleSub() {
    methodChannel.invokeMethod("cycleSub");
  }
}
