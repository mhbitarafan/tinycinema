import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:tinycinema/logic/remember_time.dart';

class MyVideoPlayer extends StatefulWidget {
  MyVideoPlayer({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VlcPlayerController _videoPlayerController;
  bool _showStopBtn = false;
  bool _showOverlay = false;
  bool _keyPressedWhileOverlay = false;
  double aspectRatio = 16 / 9;
  void _pause() {
    _showStopBtn = true;
    setState(() {});
    _videoPlayerController.pause();
  }

  void _play() {
    _showStopBtn = false;
    setState(() {});
    Future.delayed(Duration(seconds: 2));
    setState(() {});
    _videoPlayerController.play();
    // _videoPlayerController.
  }

  void _toggle() {
    if (_showStopBtn == true) {
      _play();
    } else {
      _pause();
    }
  }

  void overlayManager({required bool show}) {
    setState(() {
      _showOverlay = show;
    });
    while (true) {
      _keyPressedWhileOverlay = false;
      Future.delayed(Duration(seconds: 5));
      if (_keyPressedWhileOverlay) {
        continue;
      } else {
        setState(() {
          _showOverlay = false;
        });
      }
    }
  }

  void forward10() async {
    final currentTime = _videoPlayerController.value.position;
    _videoPlayerController.seekTo(currentTime + Duration(seconds: 10));
  }

  void backward10() {
    final currentTime = _videoPlayerController.value.position;
    _videoPlayerController.seekTo(currentTime - Duration(seconds: 10));
  }

  String get videoTime =>
      _videoPlayerController.value.duration
          .toString()
          .split('.')
          .first
          .padLeft(8, "0") +
      " / " +
      _videoPlayerController.value.position
          .toString()
          .split('.')
          .first
          .padLeft(8, "0");

  void initVideo() async {
    _videoPlayerController = VlcPlayerController.network(
      widget.url,
      autoPlay: true,
      autoInitialize: true,
      options: VlcPlayerOptions(),
    );
    await _videoPlayerController.initialize();
    print(_videoPlayerController.value.aspectRatio);
    print(_videoPlayerController.value.size.aspectRatio);
    // setState(() {
    //   aspectRatio = _videoPlayerController.value.aspectRatio;
    // });
  }

  RememberTime rememberTime = RememberTime();
  bool rememberTimeDisposed = false;
  initRemeberTimer() async {
    while (true) {
      if (!rememberTimeDisposed) {
        print("hello " + rememberTime.rememberTimeList.toString());
        await Future.delayed(Duration(seconds: 10));
        rememberTime.addOrUpdateVideo(
            widget.url, _videoPlayerController.value.position);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    initVideo();
    if (rememberTime.didRemember(widget.url)) {
      final duration = rememberTime.getVideoRememberedTime(widget.url);
      print("hello" + duration.toString());
      _videoPlayerController.seekTo(duration);
    }
    initRemeberTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    rememberTimeDisposed = true;
    try {
      await _videoPlayerController.stopRendererScanning();
      await _videoPlayerController.dispose();
    } catch (_) {}
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
          body: Focus(
        autofocus: true,
        onKey: (node, event) {
          KeyEventResult result = KeyEventResult.handled;
          _keyPressedWhileOverlay = true;
          if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            forward10();
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
            backward10();
          } else if (event.isKeyPressed(LogicalKeyboardKey.space) ||
              event.isKeyPressed(LogicalKeyboardKey.select)) {
            _toggle();
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            overlayManager(show: true);
          } else {
            result = KeyEventResult.ignored;
          }
          return result;
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: VlcPlayer(
                  controller: _videoPlayerController,
                  aspectRatio: aspectRatio,
                  placeholder: Center(child: CircularProgressIndicator()),
                ),
              ),
              Visibility(
                visible: _showStopBtn,
                child: Center(
                  child: Icon(
                    Icons.pause_rounded,
                    size: 48,
                  ),
                ),
              ),
              GestureDetector(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Color.fromRGBO(0, 0, 0, 0),
                  ),
                  onTap: _toggle),
              GestureDetector(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 200,
                    height: double.infinity,
                    color: Color.fromRGBO(0, 0, 0, 0),
                  ),
                ),
                onDoubleTap: forward10,
                onTap: _toggle,
              ),
              GestureDetector(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 200,
                    height: double.infinity,
                    color: Color.fromRGBO(0, 0, 0, 0),
                  ),
                ),
                onDoubleTap: backward10,
                onTap: _toggle,
              ),
              Visibility(
                visible: _showStopBtn,
                child: Positioned(
                  child: Text(
                    videoTime,
                  ),
                  right: 15,
                  bottom: 10,
                ),
              ),
              Visibility(
                child: Center(child: CircularProgressIndicator()),
                visible: _videoPlayerController.value.isBuffering,
              ),
              Visibility(
                child: Center(child: Text("showover")),
                visible: _showOverlay,
              )
            ],
          ),
        ),
      )),
    );
  }
}

// class VideoOverlay extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     throw UnimplementedError();
//   }
// }

// class VideoOverlayState extends State<VideoOverlay> {
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }