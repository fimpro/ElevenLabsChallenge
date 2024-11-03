import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/config.dart';

final voiceNames = ["Alice", "Charlotte", "Eric", "Fin"];
final voiceIds = ["Xb7hH8MSUJpSbSDYk0k2", "pFZP5JQG7iQjIQuC4Bku", "ZJ6YRAIdR3FwMeEx6NIc", "zZ78uuLgyOfL4C3MyVaj"];

String getVoiceName(String voiceId) {
  if (voiceIds.contains(voiceId)) {
    return voiceNames[voiceIds.indexOf(voiceId)];
  } else {
    return "Custom Voice";
  }
}

final moods = ["Energetic", "Bored", "Dramatic"];
final predefinedPreferences = ["Architecture", "History", "Art", "Nature", "Food & Drink", "Local Culture", "Hidden Gems"];
final preferences = [...predefinedPreferences];
final languages = ["English", "Polish", "German", "Czech"];


class ConfigCubit extends Cubit<ConfigState> {
  ConfigCubit() : super(ConfigState(voiceId: voiceIds[0], isCustomVoice: false, emotions: moods[0], language: languages[0]));

  void setVoiceId(String voiceId) => emit(state.copyWith(voiceId: voiceId));
  void setIsCustomVoice(bool isCustomVoice) => emit(state.copyWith(isCustomVoice: isCustomVoice));
  void setMood(String mood) => emit(state.copyWith(emotions: mood));
  void setPreferences(List<String> preferences) => emit(state.copyWith(preferences: preferences));
  void setLanguage(String language) => emit(state.copyWith(language: language));
  void addPreference(String preference) => emit(state.copyWith(preferences: [...state.preferences, preference]));
}
