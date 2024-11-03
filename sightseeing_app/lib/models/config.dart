class ConfigState {
  final String voiceId;
  final bool isCustomVoice;
  final String emotions;
  final List<String> preferences;
  final String language;

  ConfigState(
      {required this.voiceId,
      required this.isCustomVoice,
      required this.emotions,
      required this.language,
      this.preferences = const []});

  ConfigState copyWith(
      {String? voiceId,
      bool? isCustomVoice,
      String? emotions,
      List<String>? preferences,
      String? language}) {
    return ConfigState(
      voiceId: voiceId ?? this.voiceId,
      isCustomVoice: isCustomVoice ?? this.isCustomVoice,
      emotions: emotions ?? this.emotions,
      preferences: preferences ?? this.preferences,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voice_id': voiceId,
      'emotions': emotions,
      'preferences': preferences,
      'language': language,
    };
  }
}
