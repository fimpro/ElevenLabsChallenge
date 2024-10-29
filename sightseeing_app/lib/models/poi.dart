class POI {
  final String? name;
  final String? description;
  final String? audioUrl;
  final List<String?> imagesUrls;
  final List<double?> location;

  POI(
      {required this.name,
      required this.description,
      required this.audioUrl,
      required this.imagesUrls,
      required this.location});

  factory POI.empty() => POI(
      name: "",
      description: "",
      audioUrl: "",
      imagesUrls: [],
      location: [0, 0]);

  bool get isEmpty => name?.isEmpty ?? true;
  bool get hasLocation =>
      location.length == 2 && location[0] != null && location[1] != null;
  double get latitude => location[0]!;
  double get longitude => location[1]!;

  factory POI.fromJson(Map<String, dynamic> json) {
    return POI(
      name: json['name'],
      description: json['description'],
      imagesUrls: (json['imagesUrls'] as List<dynamic>).cast(),
      audioUrl: json['audioUrl'],
      location: (json['location'] as List<dynamic>).cast(),
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
