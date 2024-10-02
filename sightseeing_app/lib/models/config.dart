class ConfigState {
  final String voice;
  final String mood;
  final List<String> preferences;

  ConfigState({required this.voice, required this.mood, this.preferences = const []});

  ConfigState copyWith({String? voice, String? mood, List<String>? preferences}) {
    return ConfigState(
      voice: voice ?? this.voice,
      mood: mood ?? this.mood,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voice': voice,
      'mood': mood,
      'preferences': preferences,
    };
  }
}
