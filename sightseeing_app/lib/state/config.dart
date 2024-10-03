import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/config.dart';

final voices = [
  "Anna",
  "Charlotte",
  "Eric",
  "Fin"
];
final moods = ["Energetic", "Bored", "Dramatic"];
final preferences = ["Architecture", "History", "Art"];


class ConfigCubit extends Cubit<ConfigState> {
  ConfigCubit() : super(ConfigState(voice: voices[0], emotions: moods[0]));

  void setVoice(String voice) => emit(state.copyWith(voice: voice));
  void setMood(String mood) => emit(state.copyWith(emotions: mood));
  void setPreferences(List<String> preferences) => emit(state.copyWith(preferences: preferences));
}
