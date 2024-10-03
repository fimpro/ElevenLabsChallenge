class ConfigState {
  final String voice;
  final String emotions;
  final List<String> preferences;

  ConfigState({required this.voice, required this.emotions, this.preferences = const []});

  ConfigState copyWith({String? voice, String? emotions, List<String>? preferences}) {
    return ConfigState(
      voice: voice ?? this.voice,
      emotions: emotions ?? this.emotions,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voice': voice,
      'emotions': emotions,
      'preferences': preferences,
    };
  }
}
