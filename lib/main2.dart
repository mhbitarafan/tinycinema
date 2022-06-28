import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

void main(List<String> args) {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MethodChannel channel = MethodChannel('mpv_method_channel');

    final Map<String, dynamic> creationParams = <String, dynamic>{
      "url":
          "http://dl7.freeserver.top/www2/film/1401/02/Everything.Everywhere.All.at.Once.2022.720p.10bit.WEB-DL.6CH.x265.SoftSub.DigiMoviez.mkv",
    };

    channel.setMethodCallHandler((call) {
      print("my event dart: ${call.arguments}");
      switch (call.method) {
        case "media-title":
          break;
        case "time-pos": //long
          break;
        case "duration": //long
          break;
        default:
          break;
      }
      return Future<Null>.value(null);
    });

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              AndroidView(
                viewType: "mpvPlayer",
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
              ),
              GestureDetector(
                onTap: () {
                  channel.invokeMethod("cyclePause");
                },
                child: Container(
                  color: Colors.amber.withOpacity(.4),
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
              Positioned(
                left: 0,
                height: double.infinity,
                width: 200,
                child: GestureDetector(
                  onTap: () {
                    channel.invokeMethod("forward10");
                  },
                  child: Container(
                    color: Colors.red,
                  ),
                ),
              ),
              // Positioned(
              //   left: 0,
              //   child: GestureDetector(
              //     onTap: () {
              //       print("backward10");
              //
              //       channel.invokeMethod("backward10");
              //     },
              //     child: Container(
              //       color: Colors.red.withOpacity(.2),
              //       height: double.infinity,
              //       width: 200,
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }
}
