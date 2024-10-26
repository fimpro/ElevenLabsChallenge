import 'dart:js_interop_unsafe';

import 'package:web/web.dart';
import 'dart:js_interop';
import 'package:event/event.dart' as event;

class WebDemoUI {
  late JSFunction _onMessageJS;
  event.Event onPlay = event.Event();
  event.Event<event.Value<int>> onSeek = event.Event();

  WebDemoUI() {
    _onMessageJS = _onMessage.toJS;
    window.addEventListener("message", _onMessageJS);
  }

  void dispose() {
    window.removeEventListener("message", _onMessageJS);
  }

  void setControlsVisible(bool isVisible) {
    _sendMessage("setControlsVisible", isVisible);
  }

  void setPlayState(bool isPlaying) {
    _sendMessage("setIsPlaying", isPlaying);
  }

  void setCurrentIndex(int index) {
    _sendMessage("setIndex", index);
  }

  void _onMessage(JSObject message) {
    var data = message["data"] as JSObject;
    var type = data["type"].dartify() as String;
    print("flutter got message $type");

    if (type == "play") {
      onPlay.broadcast();
    } else if (type == "seek") {
      var value = message["index"].dartify() as int?;
      onSeek.broadcast(event.Value(value));
    }
  }

  void _sendMessage(String event, Object data) {
    var message = {
      "type": event,
      "data": data,
    };
    window.parentCrossOrigin?.postMessage(message.jsify(), "*".toJS);
  }
}

WebDemoUI? webDemoUI;
