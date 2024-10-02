import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class AudioCubit extends Cubit<PlayerState> {
  AudioCubit() : super(PlayerState(false, ProcessingState.idle));

  void setState(PlayerState state) => emit(state);
}
