part of 'mpv_player.dart';

class BottomPanel extends StatefulWidget {
  BottomPanel({Key? key}) : super(key: key);

  @override
  BottomPanelState createState() => BottomPanelState();
}

class BottomPanelState extends State<BottomPanel> {
  late FocusNode playBtnFNode, sliderFNode, audioFNode, subtitleFNode;

  KeyEventResult panelNodeOnKey(node, event) {
    KeyEventResult result = KeyEventResult.handled;
    if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      node.previousFocus();
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      node.nextFocus();
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      sliderFNode.requestFocus();
    } else {
      result = KeyEventResult.ignored;
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    playBtnFNode = FocusNode(
      onKey: panelNodeOnKey,
    );
    audioFNode = FocusNode(
      onKey: panelNodeOnKey,
    );
    subtitleFNode = FocusNode(
      onKey: panelNodeOnKey,
    );

    sliderFNode = FocusNode(
      onKey: (node, event) {
        KeyEventResult result = KeyEventResult.handled;
        if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          setState(() {
            playerState.sliderPlus(30);
            playerState.isSeeking = true;
          });
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          setState(() {
            playerState.sliderMinus(30);
            playerState.isSeeking = true;
          });
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          playBtnFNode.requestFocus();
        } else if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.select)) {
          playerState.isSeeking = false;
          mpv.seek(Duration(seconds: playerState.sliderValue.toInt()));
        } else {
          result = KeyEventResult.ignored;
        }
        return result;
      },
      canRequestFocus: true,
    );
  }

  // void getSubtitles(BuildContext context) async {
  //   final subTracks = await vPlayerCtl.getSpuTracks();
  //   final activeSubtitleIndex = await vPlayerCtl.getSpuTrack();
  //   List<Widget> subButtons = [];
  //   subTracks.forEach((i, v) {
  //     subButtons.add(
  //       ElevatedButton(
  //         onPressed: activeSubtitleIndex == i
  //             ? null
  //             : () async {
  //                 await vPlayerCtl.setSpuTrack(i);
  //                 Navigator.pop(context, 'OK');
  //               },
  //         child: Text(v),
  //       ),
  //     );
  //   }
  //   );
  //   showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) => Shortcuts(
  //       shortcuts: <LogicalKeySet, Intent>{
  //         LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
  //       },
  //       child: AlertDialog(
  //         title: const Text('انتخاب زیرنویس'),
  //         content: Wrap(spacing: 10, runSpacing: 10, children: subButtons),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, 'OK'),
  //             child: const Text('باشه'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void getAudioTracks(BuildContext context) async {
  //   final audioTracks = await vPlayerCtl.getAudioTracks();
  //   List<Widget> audioButtons = [];
  //   audioTracks.forEach((i, v) {
  //     audioButtons.add(
  //       ElevatedButton(
  //         onPressed: vPlayerCtl.value.activeAudioTrack == i
  //             ? null
  //             : () async {
  //                 await vPlayerCtl.setAudioTrack(i);
  //                 Navigator.pop(context, 'OK');
  //               },
  //         child: Text(v),
  //       ),
  //     );
  //   });
  //   showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) => Shortcuts(
  //       shortcuts: <LogicalKeySet, Intent>{
  //         LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
  //       },
  //       child: AlertDialog(
  //         title: const Text('انتخاب صدا'),
  //         content: Wrap(spacing: 10, runSpacing: 10, children: audioButtons),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, 'OK'),
  //             child: const Text('باشه'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    playBtnFNode.dispose();
    sliderFNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    playBtnFNode.requestFocus();
    return Theme(
      data: DarkTheme().themeData,
      child: Visibility(
        visible: playerState.bottomPanelVisible,
        // visible: showBottomPanel.value,
        child: Positioned(
          bottom: 0,
          left: 0,
          width: MediaQuery.of(context).size.width,
          child: Container(
            height: 110,
            color: Colors.grey.withOpacity(.5),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Consumer<PlayerState>(
                    builder: (context, playerState, child) => Slider(
                      focusNode: sliderFNode,
                      activeColor: Colors.deepPurple,
                      inactiveColor: Colors.white,
                      thumbColor: Colors.deepPurple,
                      max: mpv.duration?.inSeconds.toDouble() ?? 100,
                      value: playerState.sliderValue,
                      onChanged: (newValue) {
                        setState(() {
                          playerState.sliderValue = newValue;
                          playerState.isSeeking = true;
                        });
                      },
                      onChangeEnd: (value) {
                        mpv.seek(Duration(seconds: value.toInt()));
                        playerState.isSeeking = false;
                        // onSeek();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 22, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Consumer<MPV>(
                        builder: (context, _, child) {
                          if (!playerState.isSeeking) {
                            playerState.sliderValue =
                                mpv.position?.inSeconds.toDouble() ?? 0;
                          }
                          return Text(
                            mpv.durationFormatted,
                            style: TextStyle(fontSize: 20),
                          );
                        },
                      ),
                      Center(
                          child: Material(
                        color: Colors.transparent,
                        child: Consumer2<PlayerState, MPV>(
                          builder: (context, s1, s2, child) => Wrap(
                            children: [
                              Row(
                                children: [
                                  Text(mpv.subtitle_id.toString()),
                                  IconButton(
                                    focusNode: subtitleFNode,
                                    icon: Icon(Icons.closed_caption),
                                    onPressed: mpv.cycleSub,
                                    splashRadius: 15,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(mpv.audio_id.toString()),
                                  IconButton(
                                    focusNode: audioFNode,
                                    icon: Icon(Icons.audiotrack),
                                    onPressed: mpv.cycleAudio,
                                  ),
                                ],
                              ),
                              IconButton(
                                focusNode: playBtnFNode,
                                splashColor: Colors.red,
                                highlightColor: Colors.blue,
                                splashRadius: 22,
                                icon: Icon(
                                  !mpv.paused ? Icons.pause : Icons.play_arrow,
                                  size: 35,
                                ),
                                onPressed: () {
                                  playerState.cyclePause();
                                  log.info(mpv.paused);
                                },
                              ),
                            ],
                          ),
                        ),
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
