import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
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
  final double lon;
  final bool prevent;

  UpdateRequest({required this.lat, required this.lon, required this.prevent});

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'prevent': prevent,
    };
  }
}

class UpdateResponse {
  final bool ok;
  final bool newFile;
  final String? id;

  UpdateResponse({required this.ok, required this.newFile, this.id});

  factory UpdateResponse.fromJson(Map<String, dynamic> json) {
    return UpdateResponse(
      ok: json['ok'] as bool,
      newFile: json['new_file'] as bool,
      id: json['id'] as String?,
    );
  }
}

class ExistsRequest {
  final String? id;

  ExistsRequest(this.id);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class ExistsResponse {
  final bool audioReady;
  final POI? info;

  ExistsResponse({required this.audioReady, required this.info});

  factory ExistsResponse.fromJson(Map<String, dynamic> json) {
    return ExistsResponse(
      audioReady: json['audio_ready'] ?? false,
      info: json.containsKey('info') ? POI.fromJson(json['info']) : null,
    );
  }
}

class ApiController {
  String baseUrl;

  String? token;
  Timer? _interval;
  String? lastAudioId;
  bool hasNewAudio = false;

  ApiController(this.baseUrl);

  Future<void> createToken(ConfigState config) async {
    var data = await post("/create_token", config.toJson(), CreateTokenResponse.fromJson);

    if (!data.ok) {
      throw Exception("Failed to create token");
    }

    token = data.token;
    lastAudioId = null;
    hasNewAudio = false;
  }

  Future<UpdateResponse> updateLocation(UpdateRequest request) async {
    var data = await post("/update", request.toJson(), UpdateResponse.fromJson);

    if (!data.ok) {
      throw Exception("Failed to update");
    }

    if (data.newFile) {
      lastAudioId = data.id;
      hasNewAudio = true;
      print('id $lastAudioId');
    }

    return data;
  }

  Future<ExistsResponse> fetchInfo() async {
    var request = ExistsRequest(lastAudioId);
    var data = await post("/info", request.toJson(), ExistsResponse.fromJson);

    return data;
  }

  Future<T> post<T>(String path, Map<String, dynamic> body, T Function(Map<String, dynamic>) fromJson) async {
    print('post $path: $body');
    var response = await http.post(Uri.parse("$baseUrl$path"),
        body: jsonEncode(body),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
    );
    print('$path response: ${response.body}');
    var json = jsonDecode(utf8.decode(response.bodyBytes));
    var data = fromJson(json);

    return data;
  }

  void start(int intervalMs, void Function(ExistsResponse data) onResponse) {
    _interval =
        Timer.periodic(Duration(milliseconds: intervalMs), (timer) async {
      if (token == null || lastAudioId == null) return;

      var response = await fetchInfo();
      onResponse(response);
    });
  }

  void stop() {
    token = null;
    _interval?.cancel();
  }

  void closeCurrentPOI() {
    lastAudioId = null;
    hasNewAudio = false;
  }

  String lastAudioUrl() {
    return "$baseUrl/audio/$lastAudioId.mp3";
  }
}

String getApiUrl() {
  print('kDebugMode: $kDebugMode, kIsWeb: $kIsWeb');

  if (kDebugMode) {
    return kIsWeb ? "http://localhost:8000" : "http://10.0.2.2:8000";
  }

  return "https://11labs-hackathon.13372137.xyz";
}

var apiController = ApiController(getApiUrl());

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
