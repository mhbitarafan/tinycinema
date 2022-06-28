import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tinycinema/logic/mpv.dart';
import 'package:tinycinema/logic/remember_time.dart';
import 'package:tinycinema/logic/websites/models.dart';
import 'package:tinycinema/ui/styles/dark.dart';
import 'package:tinycinema/utils.dart';
import 'package:wakelock/wakelock.dart';

part 'states.dart';

part 'bottom_panel.dart';

RememberTime rememberTime = RememberTime();
MPV mpv = MPV();
PlayerState playerState = PlayerState();

class _MpvPlayerPageState extends State<MpvPlayerPage> {
  var screenFNode = FocusNode();
  late String videoUrl;

  void setVideoUrl(String url) {
    setState(() {
      videoUrl = url;
    });
  }

  void initPlayer() async {
    mpv = MPV();
    playerState = PlayerState();
    videoUrl = widget.url;
    playerState.links_data = widget.links_data;
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
  }

  @override
  void dispose() async {
    super.dispose();
    // if (mpv.position != null) {
    //   rememberTime.addOrUpdateVideo(widget.url, mpv.position!);
    // }
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
          child: Scaffold(
            body: WillPopScope(
              onWillPop: () {
                if (playerState.bottomPanelVisible) {
                  playerState.hideBottomPanel();
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
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // PlatformViewLink(
                      //   viewType: "mpvPlayer",
                      //   surfaceFactory: (context, controller) {
                      //     return AndroidViewSurface(
                      //       controller: controller as AndroidViewController,
                      //       gestureRecognizers: const <
                      //           Factory<OneSequenceGestureRecognizer>>{},
                      //       hitTestBehavior: PlatformViewHitTestBehavior.opaque,
                      //     );
                      //   },
                      //   onCreatePlatformView: (params) {
                      //     return PlatformViewsService.initExpensiveAndroidView(
                      //       id: params.id,
                      //       viewType: "mpvPlayer",
                      //       layoutDirection: TextDirection.ltr,
                      //       creationParams: {"url": videoUrl},
                      //       creationParamsCodec: const StandardMessageCodec(),
                      //       onFocus: () {
                      //         params.onFocusChanged(true);
                      //       },
                      //     )
                      //       ..addOnPlatformViewCreatedListener(
                      //           params.onPlatformViewCreated)
                      //       ..create();
                      //   },
                      // ),
                      AndroidView(
                        viewType: "mpvPlayer",
                        layoutDirection: TextDirection.ltr,
                        creationParams: {"url": videoUrl},
                        creationParamsCodec: const StandardMessageCodec(),
                      ),
                      // url of video on top left
                      Consumer<PlayerState>(
                        builder: (context, a, b) => Visibility(
                          visible: playerState.bottomPanelVisible,
                          child: Positioned(
                              child: Text(basename(File(widget.url).path)),
                              left: 10,
                              top: 10),
                        ),
                      ),
                      Consumer<PlayerState>(
                        builder: (context, a, b) => Visibility(
                          visible: playerState.bottomPanelVisible,
                          child: Positioned(
                              child: Consumer<MPV>(
                                builder: (context, a, b) => Text(mpv.hwdec),
                              ),
                              right: 10,
                              top: 10),
                        ),
                      ),
                      Consumer<MPV>(
                        builder: (context, a, b) => Visibility(
                          visible: mpv.duration == null,
                          child: Center(
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      // show time after seeking
                      Consumer<PlayerState>(
                        builder: (context, a, b) => Visibility(
                          visible: playerState.isSeeking &&
                              playerState.bottomPanelVisible,
                          child: Center(
                            child: Text(
                              durationPrettify(
                                Duration(
                                  seconds: playerState.sliderValue.toInt(),
                                ),
                              ),
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ),
                      // toggle bottom panel if tap on every point of screen
                      Consumer<PlayerState>(
                        builder: (context, a, b) => GestureDetector(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Color.fromRGBO(0, 0, 0, 0),
                          ),
                          onTap: playerState.toggleBottomPanel,
                        ),
                      ),
                      // right action panel for forward10
                      Consumer<PlayerState>(
                        builder: (context, a, b) => GestureDetector(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 200,
                              height: double.infinity,
                              color: Colors.transparent,
                            ),
                          ),
                          onDoubleTap: mpv.forward10,
                          onTap: () {
                            playerState.toggleBottomPanel();
                          },
                        ),
                      ),
                      // left panel for backward10
                      GestureDetector(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200,
                            height: double.infinity,
                            color: Colors.transparent,
                          ),
                        ),
                        onDoubleTap: mpv.backward10,
                        onTap: playerState.toggleBottomPanel,
                      ),

                      BottomPanel(setVideoUrl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MpvPlayerPage extends StatefulWidget {
  MpvPlayerPage({Key? key, required this.url, this.links_data})
      : super(key: key);
  final String url;
  final Links? links_data;

  @override
  _MpvPlayerPageState createState() => _MpvPlayerPageState();
}
