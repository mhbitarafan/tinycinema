import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:tinycinema/logic/remember_time.dart';
import 'package:wakelock/wakelock.dart';

var showBottomPanel = ValueNotifier(false);
var showPauseBtn = ValueNotifier(false);
late VlcPlayerController vPlayerCtl;
RememberTime rememberTime = RememberTime();
bool _disposed = false;
bool _videoStarted = false;
var _isSeeking = ValueNotifier(false);
double _sliderValue = 0;

String get videoTime =>
    vPlayerCtl.value.duration.toString().split('.').first.padLeft(8, "0") +
    " / " +
    vPlayerCtl.value.position.toString().split('.').first.padLeft(8, "0");

class MyVideoPlayer extends StatefulWidget {
  MyVideoPlayer({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  double aspectRatio = 16 / 9;
  var screenFNode = FocusNode();
  void onSeek(Duration d) {
    setState(() {
      _sliderValue = d.inSeconds.toDouble();
    });
  }

  void forward10() async {
    final currentTime = vPlayerCtl.value.position;
    final newDuration = currentTime + Duration(seconds: 10);
    vPlayerCtl.seekTo(newDuration);
    onSeek(newDuration);
  }

  void backward10() {
    final currentTime = vPlayerCtl.value.position;
    final newDuration = currentTime - Duration(seconds: 10);
    vPlayerCtl.seekTo(newDuration);
    onSeek(newDuration);
  }

  void _toggle() {
    if (vPlayerCtl.value.isPlaying) {
      vPlayerCtl.pause();
      setState(() {
        showPauseBtn.value = true;
        showBottomPanel.value = true;
      });
    } else {
      vPlayerCtl.play();
      setState(() {
        showPauseBtn.value = false;
        showBottomPanel.value = false;
      });
    }
  }

  void loadVideo() async {
    vPlayerCtl = VlcPlayerController.network(
      widget.url,
      autoPlay: true,
      autoInitialize: true,
    );
  }

  initRemeberTimer() async {
    while (true) {
      await Future.delayed(Duration(seconds: 10));
      rememberTime.addOrUpdateVideo(widget.url, vPlayerCtl.value.position);
      if (_disposed == true) {
        break;
      }
    }
    rememberTime.addOrUpdateVideo(widget.url, vPlayerCtl.value.position);
  }

  late final Duration rememberedDuration;
  bool _isBuffering = true;
  @override
  void initState() {
    super.initState();

    _disposed = false;
    showBottomPanel.value = false;
    _videoStarted = false;
    _isSeeking.value = false;
    showPauseBtn.value = true;
    _sliderValue = 0;

    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    loadVideo();
    rememberedDuration = rememberTime.getVideoRememberedTime(widget.url);

    vPlayerCtl.addListener(() {
      if (vPlayerCtl.value.isPlaying && _videoStarted == false) {
        _videoStarted = true;
        vPlayerCtl.seekTo(rememberedDuration);
        onSeek(rememberedDuration);
      }
      if (vPlayerCtl.value.isPlaying && _videoStarted == true) {
        setState(() {
          _isBuffering = false;
        });
      }
      if (vPlayerCtl.value.isBuffering) {
        setState(() {
          _isBuffering = true;
        });
      }
    });

    _isSeeking.addListener(() => setState(() {}));

    showBottomPanel.addListener(() {
      if (showBottomPanel.value == false) {
        setState(() {
          _isSeeking.value = false;
        });
      }
    });

    initRemeberTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    _disposed = true;
    Wakelock.disable();
    try {
      await vPlayerCtl.stopRendererScanning();
      await vPlayerCtl.dispose();
    } catch (_) {}

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void showBottomPanelCtl() async {
    if (showBottomPanel.value == false) {
      showBottomPanel.value = true;
    } else {
      showBottomPanel.value = false;
      _isSeeking.value = false;
    }
    onSeek(vPlayerCtl.value.position);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Theme(
        data: ThemeData.dark(),
        child: Scaffold(
            body: WillPopScope(
          onWillPop: () {
            if (showBottomPanel.value) {
              setState(() {
                // onSeek();
                showBottomPanel.value = false;
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
                forward10();
              } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                backward10();
              } else if (event.isKeyPressed(LogicalKeyboardKey.select) ||
                  event.isKeyPressed(LogicalKeyboardKey.enter)) {
                _toggle();
              } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                showBottomPanelCtl();
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
                  Center(
                    child: VlcPlayer(
                      controller: vPlayerCtl,
                      aspectRatio: aspectRatio,
                      placeholder: Center(
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _isBuffering,
                    child: Center(
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                  Visibility(
                    visible: _isSeeking.value,
                    child: Center(
                      child: Text(
                        Duration(
                          seconds: _sliderValue.toInt(),
                        ).toString().split('.').first.padLeft(8, "0"),
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Color.fromRGBO(0, 0, 0, 0),
                    ),
                    onTap: showBottomPanelCtl,
                  ),
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
                    onTap: showBottomPanelCtl,
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
                    onTap: showBottomPanelCtl,
                  ),
                  BottomPanel(),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}

class BottomPanel extends StatefulWidget {
  BottomPanel({Key? key}) : super(key: key);
  @override
  BottomPanelState createState() => BottomPanelState();
}

class BottomPanelState extends State<BottomPanel> {
  void onSeek() {
    setState(() {
      _sliderValue = vPlayerCtl.value.position.inSeconds.toDouble();
    });
  }

  late FocusNode playBtnFNode, sliderFNode;

  @override
  void initState() {
    super.initState();
    playBtnFNode = FocusNode();
    sliderFNode = FocusNode(
        onKey: (node, event) {
          KeyEventResult result = KeyEventResult.handled;
          if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            setState(() {
              _sliderValue = _sliderValue + 30;
              _isSeeking.value = true;
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
            setState(() {
              _sliderValue = _sliderValue - 30;
              _isSeeking.value = true;
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.select)) {
            _isSeeking.value = false;
            vPlayerCtl.seekTo(Duration(seconds: _sliderValue.toInt()));
            vPlayerCtl.play();
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            playBtnFNode.requestFocus();
          } else {
            result = KeyEventResult.ignored;
          }
          return result;
        },
        canRequestFocus: true);

    showBottomPanel.addListener(() {
      if (showBottomPanel.value == true) {
        playBtnFNode.requestFocus();
      }
    });

    showPauseBtn.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    playBtnFNode.dispose();
    sliderFNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Visibility(
        visible: showBottomPanel.value,
        child: Positioned(
          bottom: 10,
          left: 0,
          width: MediaQuery.of(context).size.width,
          child: Container(
            height: 100,
            color: Colors.grey.withOpacity(.3),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Slider(
                    focusNode: sliderFNode,
                    activeColor: Colors.deepPurple,
                    inactiveColor: Colors.white,
                    thumbColor: Colors.deepPurple,
                    max: vPlayerCtl.value.duration.inSeconds.toDouble(),
                    value: _sliderValue,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                        _isSeeking.value = true;
                      });
                    },
                    onChangeEnd: (value) {
                      vPlayerCtl.seekTo(Duration(seconds: value.toInt()));
                      _isSeeking.value = false;
                      // onSeek();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        videoTime,
                        style: TextStyle(fontSize: 20),
                      ),
                      Center(
                          child: IconButton(
                        focusNode: playBtnFNode,
                        splashColor: Colors.red,
                        highlightColor: Colors.blue,
                        splashRadius: 20,
                        icon: Icon(
                          showPauseBtn.value ? Icons.pause : Icons.play_arrow,
                          size: 30,
                        ),
                        onPressed: () {
                          if (showPauseBtn.value) {
                            vPlayerCtl.pause();
                            showBottomPanel.value = true;
                            showPauseBtn.value = false;
                          } else {
                            vPlayerCtl.play();
                            showBottomPanel.value = false;
                            showPauseBtn.value = true;
                          }
                          setState(() {});
                        },
                      )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
