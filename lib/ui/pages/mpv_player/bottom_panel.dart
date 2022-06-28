part of 'mpv_player.dart';

class BottomPanel extends StatefulWidget {
  BottomPanel(
    this.setVideoUrl, {
    Key? key,
  }) : super(key: key);

  final void Function(String) setVideoUrl;
  @override
  BottomPanelState createState() => BottomPanelState();
}

class BottomPanelState extends State<BottomPanel> {
  late FocusNode playBtnFNode,
      sliderFNode,
      audioFNode,
      subtitleFNode,
      speedFNode,
      nextFNode,
      prevFNode,
      hwdecFNode;

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
    speedFNode = FocusNode(
      onKey: panelNodeOnKey,
    );
    nextFNode = FocusNode(
      onKey: panelNodeOnKey,
    );
    prevFNode = FocusNode(
      onKey: panelNodeOnKey,
    );
    hwdecFNode = FocusNode(
      onKey: panelNodeOnKey,
    );
    sliderFNode = FocusNode(
      onKey: (node, event) {
        KeyEventResult result = KeyEventResult.handled;
        if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          playerState.sliderPlus(30);
          playerState.isSeeking = true;
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          playerState.sliderMinus(30);
          playerState.isSeeking = true;
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          playBtnFNode.requestFocus();
          playerState.setIsSeeking(false);
        } else if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.select)) {
          playerState.setIsSeeking(false);
          mpv.seek(Duration(seconds: playerState.sliderValue.toInt()));
        } else {
          result = KeyEventResult.ignored;
        }
        return result;
      },
      canRequestFocus: true,
    );
    playerState.addListener(() {
      if (playerState.bottomPanelVisible && !sliderFNode.hasFocus) {
        playBtnFNode.requestFocus();
      }
    });
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
      data: DarkTheme().themeData,
      child: Consumer<PlayerState>(
        builder: (context, a, b) => Visibility(
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
                    child: Consumer<MPV>(
                      builder: (context, a, child) => Slider(
                        focusNode: sliderFNode,
                        activeColor: Colors.deepPurple,
                        inactiveColor: Colors.white,
                        thumbColor: Colors.deepPurple,
                        max: mpv.duration?.inSeconds.toDouble() ?? 100,
                        value: playerState.sliderValue,
                        onChanged: (newValue) {
                          playerState.sliderValue = newValue;
                          playerState.isSeeking = true;
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
                            child: Wrap(
                              children: [
                                IconButton(
                                  focusNode: speedFNode,
                                  icon: Icon(Icons.speed),
                                  onPressed: mpv.cycleSpeed,
                                  splashRadius: 15,
                                ),
                                IconButton(
                                  focusNode: hwdecFNode,
                                  icon: Icon(Icons.hardware_rounded),
                                  onPressed: mpv.cycleHwdec,
                                  splashRadius: 15,
                                ),
                                Row(
                                  children: [
                                    Consumer<MPV>(
                                        builder: (context, a, b) =>
                                            Text(mpv.subtitle_id.toString())),
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
                                    Consumer<MPV>(
                                        builder: (context, a, b) =>
                                            Text(mpv.audio_id.toString())),
                                    IconButton(
                                      focusNode: audioFNode,
                                      icon: Icon(Icons.audiotrack),
                                      onPressed: mpv.cycleAudio,
                                      splashRadius: 15,
                                    ),
                                  ],
                                ),
                                if (playerState.links_data != null &&
                                    playerState.links_data!.hasNextLink)
                                  IconButton(
                                    focusNode: nextFNode,
                                    splashRadius: 15,
                                    icon: Consumer<MPV>(
                                      builder: (context, a, b) =>
                                          Icon(Icons.navigate_before),
                                    ),
                                    onPressed: () {
                                      mpv.playUrl(playerState.links_data!
                                          .nextLink()!
                                          .href);
                                    },
                                  ),
                                if (playerState.links_data != null &&
                                    playerState.links_data!.hasPrevLink)
                                  IconButton(
                                    focusNode: prevFNode,
                                    splashRadius: 15,
                                    icon: Consumer<MPV>(
                                      builder: (context, a, b) =>
                                          Icon(Icons.navigate_next),
                                    ),
                                    onPressed: () {
                                      widget.setVideoUrl(playerState.links_data!
                                          .prevLink()!
                                          .href);
                                    },
                                  ),
                                IconButton(
                                  focusNode: playBtnFNode,
                                  splashRadius: 15,
                                  icon: Consumer<MPV>(
                                    builder: (context, a, b) => Icon(
                                      !mpv.paused
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                  ),
                                  onPressed: () {
                                    playerState.cyclePause();
                                    log.info(mpv.paused);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
