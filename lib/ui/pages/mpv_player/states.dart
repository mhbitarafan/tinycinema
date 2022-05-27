part of 'mpv_player.dart';

class PlayerState extends ChangeNotifier {
  bool bottomPanelVisible = false;
  bool isSeeking = false;
  int audioCount = 1;
  int subtitleCount = 1;
  bool videoStarted = false;
  double sliderValue = 0;
  bool isBuffering = false;

  void hideBottomPanel() {
    bottomPanelVisible = false;
    notifyListeners();
  }

  void showBottomPanel() {
    bottomPanelVisible = true;
    notifyListeners();
  }

  void toggleBottomPanel() {
    bottomPanelVisible = !bottomPanelVisible;
    notifyListeners();
  }

  void onSeek(Duration duration) {
    sliderValue = duration.inSeconds.toDouble();
    notifyListeners();
  }

  void sliderPlus(double value) {
    sliderValue += value;
    notifyListeners();
  }

  void sliderMinus(double value) {
    sliderValue -= value;
    notifyListeners();
  }

  void cyclePause() {
    mpv.cyclePause();
    if(mpv.paused) bottomPanelVisible = false;
    notifyListeners();
  }

  @override
  String toString() {
    return "sliderValue:$sliderValue, bottomPanelVisible:$bottomPanelVisible, "
        "videoStarted:$videoStarted isSeeking:$isSeeking";
  }
}
