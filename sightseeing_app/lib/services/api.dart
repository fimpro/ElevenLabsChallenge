import 'package:fluttertoast/fluttertoast.dart';

class POIResponse {
  final String name;
  final String description;
  final String audioUrl;

  POIResponse({required this.name, required this.description, required this.audioUrl});

  factory POIResponse.empty() => POIResponse(name: "", description: "", audioUrl: "");

  factory POIResponse.fromJson(Map<String, dynamic> json) => POIResponse(
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      audioUrl: json['audio_url'] ?? "",
    );

  bool get isEmpty => name.isEmpty;
}

class ApiController {
  String? sessionId;

  Future<void> login() async {
    sessionId = "test";
  }

  Future<POIResponse> getNewPOIs(double lat, double lng) async {
    return POIResponse(name: "Test", description: "lol", audioUrl: "asdf");
  }
}

var apiController = ApiController();

Future<T?> tryApi<T>(Future<T> Function() apiCall) async {
  try {
    return await apiCall();
  } catch (e) {
    print(e);

    Fluttertoast.showToast(
      msg: "API Error: ${e.toString()}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  return null;
}