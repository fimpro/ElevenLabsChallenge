class VoiceConfig {
  String age;
  String gender;
  String tone;
  String pitch;
  String mood;
  String speed;

  int selectedVoiceIndex = 0; 

  VoiceConfig({
    required this.age,
    required this.gender,
    required this.tone,
    required this.pitch,
    required this.mood,
    required this.speed,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'tone': tone,
      'pitch': pitch,
      'mood': mood,
      'speed': speed,
    };
  }
}