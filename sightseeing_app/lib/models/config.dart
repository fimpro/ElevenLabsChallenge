class ConfigState {
  final String voice;
  final String emotions;
  final List<String> preferences;
  final String language;

  ConfigState({required this.voice, required this.emotions, required this.language, this.preferences = const []});

  ConfigState copyWith({String? voice, String? emotions, List<String>? preferences, String? language}) {
    return ConfigState(
      voice: voice ?? this.voice,
      emotions: emotions ?? this.emotions,
      preferences: preferences ?? this.preferences,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voice': voice,
      'emotions': emotions,
      'preferences': preferences,
      'language': language,
    };
  }
}
