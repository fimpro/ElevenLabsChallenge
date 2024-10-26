import 'package:event/event.dart' as event;

class WebDemoUI {
  event.Event onPlay = event.Event();
  event.Event onPause = event.Event();
  event.Event<event.Value<int>> onSeek = event.Event();

  void dispose() {}
  void setControlsVisible(bool isVisible) {}
  void setPlayState(bool isPlaying) {}
  void setCurrentIndex(int index) {}
}

WebDemoUI? webDemoUI;