import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/config.dart';

final voices = [
  "Anna",
  "Charlotte",
  "Eric",
  "Fin"
];
final moods = ["Energetic", "Bored", "Dramatic"];
final predefinedPreferences = ["Architecture", "History", "Art"];
final preferences = [...predefinedPreferences];
final languages = ["English", "Polish"];


class ConfigCubit extends Cubit<ConfigState> {
  ConfigCubit() : super(ConfigState(voice: voices[0], emotions: moods[0], language: languages[0]));

  void setVoice(String voice) => emit(state.copyWith(voice: voice));
  void setMood(String mood) => emit(state.copyWith(emotions: mood));
  void setPreferences(List<String> preferences) => emit(state.copyWith(preferences: preferences));
  void setLanguage(String language) => emit(state.copyWith(language: language));
  void addPreference(String preference) => emit(state.copyWith(preferences: [...state.preferences, preference]));
}
