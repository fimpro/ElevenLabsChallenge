
class POI {
  final String? name;
  final String? description;
  final String? audioUrl;
  final List<double?> location;

  POI({required this.name, required this.description, required this.audioUrl, required this.location});

  factory POI.empty() => POI(name: "", description: "", audioUrl: "", location: [0, 0]);

  bool get isEmpty => name?.isEmpty ?? true;
  double get latitude => location[0]!;
  double get longitude => location[1]!;

  factory POI.fromJson(Map<String, dynamic> json) {
    return POI(
      name: json['name'],
      description: json['description'],
      audioUrl: json['audioUrl'],
      location: [json['latitude'], json['longitude']]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'audioUrl': audioUrl,
      'latitude': location[0],
      'longitude': location[1]
    };
  }
}