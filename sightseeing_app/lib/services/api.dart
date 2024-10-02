import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';

import '../models/config.dart';
import '../models/poi.dart';

class CreateTokenResponse {
  final String token;
  final bool ok;

  CreateTokenResponse({required this.token, required this.ok});

  factory CreateTokenResponse.fromJson(Map<String, dynamic> json) {
    return CreateTokenResponse(
      token: json['token'] as String,
      ok: json['ok'] as bool,
    );
  }
}

class UpdateRequest {
  final double lat;
  final double lng;
  final bool prevent;

  UpdateRequest({required this.lat, required this.lng, required this.prevent});

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'prevent': prevent,
    };
  }
}


class UpdateResponse {
  final bool ok;
  final bool newFile;
  final int? id;

  UpdateResponse({required this.ok, required this.newFile, this.id});

  factory UpdateResponse.fromJson(Map<String, dynamic> json) {
    return UpdateResponse(
      ok: json['ok'] as bool,
      newFile: json['new_file'] as bool,
      id: json['id'] as int?,
    );
  }
}

class ExistsResponse {
  final bool audioReady;
  final POI? info;

  ExistsResponse({required this.audioReady, required this.info});

  factory ExistsResponse.fromJson(Map<String, dynamic> json) {
    return ExistsResponse(
      audioReady: json['audio_ready'],
      info: json.containsKey('info') ? POI.fromJson(json['info']) : null,
    );
  }
}

class ApiController {
  final String baseUrl;

  String? token;
  Timer? _interval;
  int? lastAudioId;
  bool hasNewAudio = false;

  ApiController(this.baseUrl);

  Future<void> login(ConfigState config) async {
    var body = jsonEncode(config.toJson());
    var response = await http.post(Uri.parse("$baseUrl/create_token"),
        body: body, headers: {"Content-Type": "application/json"});
    var json = jsonDecode(response.body);
    var data = CreateTokenResponse.fromJson(json);

    if (!data.ok) {
      throw Exception("Failed to create token");
    }

    token = data.token;
  }

  Future<UpdateResponse> update(UpdateRequest request) async {
    var body = jsonEncode(request.toJson());
    var response = await http.post(Uri.parse("$baseUrl/update"),
        body: body,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        });
    var json = jsonDecode(response.body);
    var data = UpdateResponse.fromJson(json);

    if (!data.ok) {
      throw Exception("Failed to update");
    }

    if (data.newFile) {
      lastAudioId = data.id;
      hasNewAudio = true;
    }

    return data;
  }

  Future<ExistsResponse> pollExists() async {
    var response = await http.get(Uri.parse("$baseUrl/info"), headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    });

    var json = jsonDecode(response.body);
    var data = ExistsResponse.fromJson(json);

    return data;
  }

  void start(double intervalMs, void Function(ExistsResponse data) onResponse) {
    _interval = Timer.periodic(
        Duration(milliseconds: round(intervalMs / 1000) as int),
        (timer) async {
          if (token == null) return;

          var response = await pollExists();
          onResponse(response);
        });
  }

  void stop() {
    token = null;
    _interval?.cancel();
  }

  String lastAudioUrl() {
    return "$baseUrl/audio/$lastAudioId";
  }
}

var apiController = ApiController("http://localhost:5000");

Future<T?> tryApi<T>(Future<T> Function() apiCall,
    {bool doThrow = false}) async {
  try {
    return await apiCall();
  } catch (e) {
    print(e);

    Fluttertoast.showToast(
      msg: "API Error: ${e.toString()}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );

    if (doThrow) rethrow;
  }

  return null;
}
