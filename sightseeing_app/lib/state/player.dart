import 'package:sightseeing_app/models/demo_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:sightseeing_app/services/demo_ui/demo_ui.dart';

class PlayerCubit extends Cubit<DemoPlayerState> {
  Timer? _timer;

  PlayerCubit() : super(DemoPlayerState(isPlaying: false, step: 0)) {
    _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      if (state.isPlaying) {
        if (state.step >= demoPath.length - 1) {
          webDemoUI?.setCurrentIndex(0);
          webDemoUI?.setPlayState(false);
          emit(DemoPlayerState(isPlaying: false, step: 0));
        } else {
          webDemoUI?.setCurrentIndex(state.step + 1);
          emit(DemoPlayerState(isPlaying: true, step: state.step + 1));
        }
      }
    });

    webDemoUI?.onPlay.subscribe((args) => togglePlay());
    webDemoUI?.onSeek.subscribe((args) => setLocation(args.value));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void togglePlay() {
    if (state.isPlaying) {
      webDemoUI?.setPlayState(false);
      emit(DemoPlayerState(isPlaying: false, step: state.step));
    } else {
      webDemoUI?.setPlayState(true);
      emit(DemoPlayerState(isPlaying: true, step: state.step));
    }
  }

  void setLocation(int step) {
    webDemoUI?.setCurrentIndex(state.step);
    emit(DemoPlayerState(isPlaying: state.isPlaying, step: step));
  }
}
