import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class AudioState {
  final PlayerState playerState;
  final bool startedPlaying;

  AudioState(this.playerState, this.startedPlaying);

  AudioState copyWith({PlayerState? playerState, bool? startedPlaying}) {
    return AudioState(
      playerState ?? this.playerState,
      startedPlaying ?? this.startedPlaying,
    );
  }
}

class AudioCubit extends Cubit<AudioState> {
  AudioCubit() : super(AudioState(PlayerState(false, ProcessingState.idle), false));

  void setPlayerState(PlayerState playerState) => emit(state.copyWith(playerState: playerState));
  void setStartedPlaying(bool startedPlaying) => emit(state.copyWith(startedPlaying: startedPlaying));
}
