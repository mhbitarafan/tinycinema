import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tinycinema/logic/mpv.dart';
import 'package:tinycinema/logic/remember_time.dart';
import 'package:tinycinema/ui/styles/dark.dart';
import 'package:tinycinema/utils.dart';
import 'package:wakelock/wakelock.dart';

part 'states.dart';

part 'bottom_panel.dart';

RememberTime rememberTime = RememberTime();
MPV mpv = MPV();
PlayerState playerState = PlayerState();

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  var screenFNode = FocusNode();
  late final Duration rememberedDuration;

  void initPlayer() async {
    mpv = MPV();
    playerState = PlayerState();
    await mpv.load(widget.url);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    try {
      Wakelock.enable();
    } catch (e) {
      log.severe("couldnt enable wakelock. $e");
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    initPlayer();
    rememberedDuration = rememberTime.getVideoRememberedTime(widget.url);
  }

  @override
  void dispose() async {
    super.dispose();
    if (mpv.position != null) {
      rememberTime.addOrUpdateVideo(widget.url, mpv.position!);
    }
    try {
      Wakelock.disable();
    } catch (e) {
      log.severe("couldnt disable wakelock. $e");
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Theme(
        data: DarkTheme().themeData,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => playerState),
            ChangeNotifierProvider(create: (context) => mpv),
          ],
          child: Consumer2<PlayerState, MPV>(
            builder: (context, s1, s2, _) => Scaffold(
                body: WillPopScope(
              onWillPop: () {
                if (playerState.bottomPanelVisible) {
                  setState(() {
                    // onSeek();
                    playerState.hideBottomPanel();
                  });
                  return Future.value(false);
                }
                return Future.value(true);
              },
              child: Focus(
                focusNode: screenFNode,
                autofocus: true,
                onKey: (node, event) {
                  KeyEventResult result = KeyEventResult.handled;
                  if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                    mpv.forward10();
                  } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                    mpv.backward10();
                  } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                    playerState.showBottomPanel();
                  } else {
                    result = KeyEventResult.ignored;
                  }
                  return result;
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: Stack(
                    children: [
                      Visibility(
                        visible: mpv.url.isNotEmpty,
                        child: Center(
                          child: AndroidView(
                            viewType: "mpvPlayer",
                            layoutDirection: TextDirection.ltr,
                            creationParams: mpv.creationParams,
                            creationParamsCodec: const StandardMessageCodec(),
                          ),
                        ),
                      ),
                      // url of video on top left
                      Visibility(
                        child: Positioned(
                            child: Text(basename(File(mpv.url).path)),
                            left: 10,
                            top: 10),
                        visible: playerState.bottomPanelVisible,
                      ),
                      Visibility(
                        visible:
                            playerState.isBuffering || playerState.videoStarted || mpv.duration == null,
                        child: Center(
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                      Visibility(
                        visible: playerState.isSeeking,
                        child: Center(
                          child: Text(
                            Duration(
                              seconds: playerState.sliderValue.toInt(),
                            ).toString().split('.').first.padLeft(8, "0"),
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      // toggle bottom panel if tap on every point of screen
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Color.fromRGBO(0, 0, 0, 0),
                        ),
                        onTap: playerState.toggleBottomPanel,
                      ),
                      // right action panel for forward10
                      GestureDetector(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 200,
                            height: double.infinity,
                            color: Color.fromRGBO(0, 0, 0, 0),
                          ),
                        ),
                        onDoubleTap: mpv.forward10,
                        onTap: playerState.toggleBottomPanel,
                      ),
                      // left panel for backward10
                      GestureDetector(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200,
                            height: double.infinity,
                            color: Color.fromRGBO(0, 0, 0, 0),
                          ),
                        ),
                        onDoubleTap: mpv.backward10,
                        onTap: playerState.toggleBottomPanel,
                      ),

                      BottomPanel(),
                    ],
                  ),
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class MyVideoPlayer extends StatefulWidget {
  MyVideoPlayer({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}
