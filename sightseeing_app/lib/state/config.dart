import 'package:flutter_bloc/flutter_bloc.dart';

final voices = [
  "Robert Makłowicz",
  "Krystyna Czubówna",
  "Krzysztof Ibisz",
  "Wojciech Cejrowski"
];
final moods = ["Energetic", "Bored", "Dramatic"];


class ConfigState {
  final String voice;
  final String mood;

  ConfigState({required this.voice, required this.mood});

  ConfigState.fromJson(Map<String, dynamic> json)
      : voice = json['voice'],
        mood = json['mood'];

  ConfigState copyWith({String? voice, String? mood}) {
    return ConfigState(
      voice: voice ?? this.voice,
      mood: mood ?? this.mood,
    );
  }
}

class ConfigCubit extends Cubit<ConfigState> {
  ConfigCubit() : super(ConfigState(voice: voices[0], mood: moods[0]));

  void setVoice(String voice) => emit(state.copyWith(voice: voice));
  void setMood(String mood) => emit(state.copyWith(mood: mood));
}
