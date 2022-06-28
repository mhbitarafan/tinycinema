part of 'mpv_player.dart';

String videoUrl = "";

class PlayerState extends ChangeNotifier {
  bool bottomPanelVisible = false;
  bool isSeeking = false;
  int audioCount = 1;
  int subtitleCount = 1;
  bool videoStarted = false;
  double sliderValue = 0;
  bool isBuffering = false;
  Links? links_data;

  void setIsSeeking(bool v) {
    isSeeking = v;
    notifyListeners();
  }

  void hideBottomPanel() {
    bottomPanelVisible = false;
    isSeeking = false;
    notifyListeners();
  }

  void showBottomPanel() {
    bottomPanelVisible = true;
    sliderValue = mpv.position?.inSeconds.toDouble() ?? 0;
    notifyListeners();
  }

  void toggleBottomPanel() {
    bottomPanelVisible = !bottomPanelVisible;
    if (!bottomPanelVisible) {
      isSeeking = false;
    }
    sliderValue = mpv.position?.inSeconds.toDouble() ?? 0;
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
    if (mpv.paused) bottomPanelVisible = false;
    notifyListeners();
  }

  @override
  String toString() {
    return "sliderValue:$sliderValue, bottomPanelVisible:$bottomPanelVisible, "
        "videoStarted:$videoStarted isSeeking:$isSeeking";
  }
}
