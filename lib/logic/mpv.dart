import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tinycinema/utils.dart';

class MPV extends ChangeNotifier {
  Duration? duration;
  bool paused = true;
  int subtitle_id = 0;
  int audio_id = 0;
  String hwdec = "";

  String get durationFormatted {
    if (duration == null || position == null) return "";
    return durationPrettify(duration!) + " / " + durationPrettify(position!);
  }

  Duration? position;

  MethodChannel methodChannel = MethodChannel('mpv_method_channel');

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
        case "hwdec":
          hwdec = call.arguments as String;
          notifyListeners();
          break;
      }
      return Future.value("");
    });
  }

  void seek(Duration position) {
    methodChannel.invokeMethod("seek", position.inSeconds);
  }

  void playUrl(String url) {
    methodChannel.invokeMethod("playUrl", url);
  }

  void forward10() {
    methodChannel.invokeMethod("forward10");
  }

  void backward10() {
    methodChannel.invokeMethod("backward10");
  }

  void cyclePause() {
    methodChannel.invokeMethod("cyclePause");
  }

  void pause() {
    methodChannel.invokeMethod("pause");
  }

  void play() {
    methodChannel.invokeMethod("play");
  }

  void cycleAudio() async {
    pause();
    methodChannel.invokeMethod("cycleAudio").then((value) {
      play();
    });
  }

  void cycleSub() async {
    pause();
    methodChannel.invokeMethod("cycleSub").then((value) {
      play();
    });
  }

  void cycleHwdec() {
    methodChannel.invokeMethod("cycleHwdec");
  }

  void cycleSpeed() {
    methodChannel.invokeMethod("cycleSpeed");
  }
}
