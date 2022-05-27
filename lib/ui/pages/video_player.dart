// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:tinycinema/logic/remember_time.dart';
// import 'package:tinycinema/ui/styles/dark.dart';
// import 'package:wakelock/wakelock.dart';
//
// var showBottomPanel = ValueNotifier(false);
// var showPauseBtn = ValueNotifier(true);
// var _isSeeking = ValueNotifier(false);
// var audioCount = ValueNotifier(1);
// var subtitleCount = ValueNotifier(1);
// RememberTime rememberTime = RememberTime();
// bool _videoStarted = false;
// double _sliderValue = 0;
//
//
//
// String get videoTime =>
//     vPlayerCtl.value.duration.toString().split('.').first.padLeft(8, "0") +
//     " / " +
//     vPlayerCtl.value.position.toString().split('.').first.padLeft(8, "0");
//
// class MyVideoPlayer extends StatefulWidget {
//   MyVideoPlayer({Key? key, required this.url}) : super(key: key);
//   final String url;
//
//   @override
//   _MyVideoPlayerState createState() => _MyVideoPlayerState();
// }
//
// class _MyVideoPlayerState extends State<MyVideoPlayer> {
//   double aspectRatio = 16 / 9;
//   var screenFNode = FocusNode();
//
//   void onSeek(Duration d) {
//     setState(() {
//       _sliderValue = d.inSeconds.toDouble();
//     });
//   }
//
//   void forward10() async {
//     final currentTime = vPlayerCtl.value.position;
//     final newDuration = currentTime + Duration(seconds: 10);
//     vPlayerCtl.seekTo(newDuration);
//     onSeek(newDuration);
//   }
//
//   void backward10() {
//     final currentTime = vPlayerCtl.value.position;
//     final newDuration = currentTime - Duration(seconds: 10);
//     vPlayerCtl.seekTo(newDuration);
//     onSeek(newDuration);
//   }
//
//   void loadVideo() async {
//     vPlayerCtl = VlcPlayerController.network(
//       widget.url,
//       autoPlay: true,
//       autoInitialize: true,
//     );
//   }
//
//   late final Duration rememberedDuration;
//   bool _isBuffering = true;
//
//   @override
//   void initState() {
//     super.initState();
//     showBottomPanel.value = false;
//     _videoStarted = false;
//     _isSeeking.value = false;
//     showPauseBtn.value = true;
//     audioCount.value = 1;
//     subtitleCount.value = 0;
//     _sliderValue = 0;
//
//     Wakelock.enable();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//     ]);
//     loadVideo();
//     rememberedDuration = rememberTime.getVideoRememberedTime(widget.url);
//
//     vPlayerCtl.addListener(() {
//       if (vPlayerCtl.value.isPlaying && _videoStarted == false) {
//         _videoStarted = true;
//         audioCount.value = vPlayerCtl.value.audioTracksCount - 1;
//         subtitleCount.value = vPlayerCtl.value.spuTracksCount - 1;
//         print("hhh" + subtitleCount.value.toString());
//
//         // if (subtitleCount.value == 1) {
//         //   vPlayerCtl.getSpuTracks().then((tracks) {
//         //     print("hhh");
//         //     print("hhh" + tracks.toString());
//         //     vPlayerCtl.setSpuTrack(tracks.keys.first);
//         //   });
//         // }
//         vPlayerCtl.seekTo(rememberedDuration);
//         onSeek(rememberedDuration);
//       }
//       if (vPlayerCtl.value.isPlaying && _videoStarted == true) {
//         setState(() {
//           _isBuffering = false;
//         });
//       }
//       if (vPlayerCtl.value.isBuffering) {
//         setState(() {
//           _isBuffering = true;
//         });
//       }
//     });
//
//     _isSeeking.addListener(() => setState(() {}));
//
//     showBottomPanel.addListener(() {
//       if (showBottomPanel.value == false) {
//         setState(() {
//           _isSeeking.value = false;
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() async {
//     super.dispose();
//     rememberTime.addOrUpdateVideo(widget.url, vPlayerCtl.value.position);
//     Wakelock.disable();
//     try {
//       await vPlayerCtl.stopRendererScanning();
//       await vPlayerCtl.dispose();
//     } catch (_) {}
//
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//   }
//
//   void showBottomPanelCtl() async {
//     if (showBottomPanel.value == false) {
//       showBottomPanel.value = true;
//     } else {
//       showBottomPanel.value = false;
//       _isSeeking.value = false;
//     }
//     onSeek(vPlayerCtl.value.position);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Shortcuts(
//       shortcuts: <LogicalKeySet, Intent>{
//         LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
//       },
//       child: Theme(
//         data: DarkTheme().themeData,
//         child: Scaffold(
//             body: WillPopScope(
//           onWillPop: () {
//             if (showBottomPanel.value) {
//               setState(() {
//                 // onSeek();
//                 showBottomPanel.value = false;
//               });
//               return Future.value(false);
//             }
//             return Future.value(true);
//           },
//           child: Focus(
//             focusNode: screenFNode,
//             autofocus: true,
//             onKey: (node, event) {
//               KeyEventResult result = KeyEventResult.handled;
//               if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
//                 forward10();
//               } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
//                 backward10();
//               } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
//                 showBottomPanelCtl();
//               } else {
//                 result = KeyEventResult.ignored;
//               }
//               return result;
//             },
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               color: Colors.black,
//               child: Stack(
//                 children: [
//                   Center(
//                     child: AndroidView(
//                       viewType: "mpvPlayer",
//                       layoutDirection: TextDirection.ltr,
//                       creationParams: creationParams,
//                       creationParamsCodec: const StandardMessageCodec(),
//                     ),
//                   ),
//                   Visibility(
//                     child: Positioned(
//                         child: Text(basename(File(vPlayerCtl.dataSource).path)),
//                         left: 10,
//                         top: 10),
//                     visible: showBottomPanel.value,
//                   ),
//                   Visibility(
//                     visible: _isBuffering,
//                     child: Center(
//                       child: const CircularProgressIndicator(),
//                     ),
//                   ),
//                   Visibility(
//                     visible: _isSeeking.value,
//                     child: Center(
//                       child: Text(
//                         Duration(
//                           seconds: _sliderValue.toInt(),
//                         ).toString().split('.').first.padLeft(8, "0"),
//                         style: TextStyle(fontSize: 30),
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     child: Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       color: Color.fromRGBO(0, 0, 0, 0),
//                     ),
//                     onTap: showBottomPanelCtl,
//                   ),
//                   GestureDetector(
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Container(
//                         width: 200,
//                         height: double.infinity,
//                         color: Color.fromRGBO(0, 0, 0, 0),
//                       ),
//                     ),
//                     onDoubleTap: forward10,
//                     onTap: showBottomPanelCtl,
//                   ),
//                   GestureDetector(
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Container(
//                         width: 200,
//                         height: double.infinity,
//                         color: Color.fromRGBO(0, 0, 0, 0),
//                       ),
//                     ),
//                     onDoubleTap: backward10,
//                     onTap: showBottomPanelCtl,
//                   ),
//                   BottomPanel(),
//                 ],
//               ),
//             ),
//           ),
//         )),
//       ),
//     );
//   }
// }
//
// class BottomPanel extends StatefulWidget {
//   BottomPanel({Key? key}) : super(key: key);
//
//   @override
//   BottomPanelState createState() => BottomPanelState();
// }
//
// class BottomPanelState extends State<BottomPanel> {
//   late FocusNode playBtnFNode, sliderFNode, audioFNode, subtitleFNode;
//
//   void onSeek() {
//     setState(() {
//       _sliderValue = vPlayerCtl.value.position.inSeconds.toDouble();
//     });
//   }
//
//   KeyEventResult panelNodeOnKey(node, event) {
//     KeyEventResult result = KeyEventResult.handled;
//     if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
//       node.previousFocus();
//     } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
//       node.nextFocus();
//     } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
//       sliderFNode.requestFocus();
//     } else {
//       result = KeyEventResult.ignored;
//     }
//     return result;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//
//     final Map<String, dynamic> creationParams = <String, dynamic>{
//       "url":
//     };
//
//     channel.setMethodCallHandler((call) {
//       print("my event dart: ${call.arguments}");
//       switch (call.method) {
//         case "media-title":
//           break;
//         case "time-pos": //long
//           break;
//         case "duration": //long
//           break;
//         default:
//           break;
//       }
//       return Future<Null>.value(null);
//     });
//
//     playBtnFNode = FocusNode(
//       onKey: panelNodeOnKey,
//     );
//     audioFNode = FocusNode(
//       onKey: panelNodeOnKey,
//     );
//     subtitleFNode = FocusNode(
//       onKey: panelNodeOnKey,
//     );
//     showBottomPanel.addListener(() {
//       if (showBottomPanel.value == true) {
//         playBtnFNode.requestFocus();
//       }
//     });
//
//     showPauseBtn.addListener(() => setState(() {}));
//     subtitleCount.addListener(() => setState(() {}));
//
//     sliderFNode = FocusNode(
//       onKey: (node, event) {
//         KeyEventResult result = KeyEventResult.handled;
//         if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
//           setState(() {
//             _sliderValue = _sliderValue + 30;
//             _isSeeking.value = true;
//           });
//         } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
//           setState(() {
//             _sliderValue = _sliderValue - 30;
//             _isSeeking.value = true;
//           });
//         } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
//           playBtnFNode.requestFocus();
//         } else if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
//             event.isKeyPressed(LogicalKeyboardKey.select)) {
//           _isSeeking.value = false;
//           vPlayerCtl.seekTo(Duration(seconds: _sliderValue.toInt()));
//           vPlayerCtl.play();
//         } else {
//           result = KeyEventResult.ignored;
//         }
//         return result;
//       },
//       canRequestFocus: true,
//     );
//   }
//
//   void getSubtitles(BuildContext context) async {
//     final subTracks = await vPlayerCtl.getSpuTracks();
//     final activeSubtitleIndex = await vPlayerCtl.getSpuTrack();
//     List<Widget> subButtons = [];
//     subTracks.forEach((i, v) {
//       subButtons.add(
//         ElevatedButton(
//           onPressed: activeSubtitleIndex == i
//               ? null
//               : () async {
//                   await vPlayerCtl.setSpuTrack(i);
//                   Navigator.pop(context, 'OK');
//                 },
//           child: Text(v),
//         ),
//       );
//     });
//     showDialog<String>(
//       context: context,
//       builder: (BuildContext context) => Shortcuts(
//         shortcuts: <LogicalKeySet, Intent>{
//           LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
//         },
//         child: AlertDialog(
//           title: const Text('انتخاب زیرنویس'),
//           content: Wrap(spacing: 10, runSpacing: 10, children: subButtons),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context, 'OK'),
//               child: const Text('باشه'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void getAudioTracks(BuildContext context) async {
//     final audioTracks = await vPlayerCtl.getAudioTracks();
//     List<Widget> audioButtons = [];
//     audioTracks.forEach((i, v) {
//       audioButtons.add(
//         ElevatedButton(
//           onPressed: vPlayerCtl.value.activeAudioTrack == i
//               ? null
//               : () async {
//                   await vPlayerCtl.setAudioTrack(i);
//                   Navigator.pop(context, 'OK');
//                 },
//           child: Text(v),
//         ),
//       );
//     });
//     showDialog<String>(
//       context: context,
//       builder: (BuildContext context) => Shortcuts(
//         shortcuts: <LogicalKeySet, Intent>{
//           LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
//         },
//         child: AlertDialog(
//           title: const Text('انتخاب صدا'),
//           content: Wrap(spacing: 10, runSpacing: 10, children: audioButtons),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context, 'OK'),
//               child: const Text('باشه'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     playBtnFNode.dispose();
//     sliderFNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: DarkTheme().themeData,
//       child: Visibility(
//         visible: showBottomPanel.value,
//         child: Positioned(
//           bottom: 0,
//           left: 0,
//           width: MediaQuery.of(context).size.width,
//           child: Container(
//             height: 110,
//             color: Colors.grey.withOpacity(.5),
//             child: Column(
//               children: [
//                 Directionality(
//                   textDirection: TextDirection.ltr,
//                   child: Slider(
//                     focusNode: sliderFNode,
//                     activeColor: Colors.deepPurple,
//                     inactiveColor: Colors.white,
//                     thumbColor: Colors.deepPurple,
//                     max: vPlayerCtl.value.duration.inSeconds.toDouble(),
//                     value: _sliderValue,
//                     onChanged: (value) {
//                       setState(() {
//                         _sliderValue = value;
//                         _isSeeking.value = true;
//                       });
//                     },
//                     onChangeEnd: (value) {
//                       vPlayerCtl.seekTo(Duration(seconds: value.toInt()));
//                       _isSeeking.value = false;
//                       // onSeek();
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(28, 0, 22, 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         videoTime,
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       Center(
//                           child: Material(
//                         color: Colors.transparent,
//                         child: Wrap(
//                           children: [
//                             Visibility(
//                               visible: subtitleCount.value > 1,
//                               child: IconButton(
//                                 focusNode: subtitleFNode,
//                                 icon: Icon(Icons.closed_caption),
//                                 onPressed: () => getSubtitles(context),
//                               ),
//                             ),
//                             Visibility(
//                               visible: audioCount.value > 1,
//                               child: IconButton(
//                                 focusNode: audioFNode,
//                                 icon: Icon(Icons.audiotrack),
//                                 onPressed: () => getAudioTracks(context),
//                               ),
//                             ),
//                             IconButton(
//                               focusNode: playBtnFNode,
//                               splashColor: Colors.red,
//                               highlightColor: Colors.blue,
//                               splashRadius: 22,
//                               icon: Icon(
//                                 showPauseBtn.value
//                                     ? Icons.pause
//                                     : Icons.play_arrow,
//                                 size: 35,
//                               ),
//                               onPressed: () {
//                                 if (showPauseBtn.value) {
//                                   vPlayerCtl.pause();
//                                   showBottomPanel.value = true;
//                                   showPauseBtn.value = false;
//                                 } else {
//                                   vPlayerCtl.play();
//                                   showBottomPanel.value = false;
//                                   showPauseBtn.value = true;
//                                 }
//                                 setState(() {});
//                               },
//                             ),
//                           ],
//                         ),
//                       )),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
