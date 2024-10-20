import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:latlong2/latlong.dart';
import 'package:sightseeing_app/pages/map/bottom_panel.dart';
import 'package:sightseeing_app/pages/map/top_panel.dart';
import 'package:sightseeing_app/services/api.dart';
import 'package:sightseeing_app/services/audio.dart';
import 'package:sightseeing_app/state/audio.dart';
import 'package:sightseeing_app/state/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sightseeing_app/state/location.dart';
import '../../models/poi.dart';
import '../../state/poi.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final AnimatedMapController _animatedController =
      AnimatedMapController(vsync: this);
  late AlignOnUpdate _alignPositionOnUpdate;
  late AlignOnUpdate _alignDirectionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;
  late final StreamController<double?> _alignDirectionStreamController;
  late final StreamSubscription<LocationMarkerPosition> _positionStream;
  late final StreamSubscription<PlayerState> _playerStateStream;

  @override
  void initState() {
    super.initState();

    _alignPositionOnUpdate = AlignOnUpdate.always;
    _alignDirectionOnUpdate = AlignOnUpdate.always;
    _alignPositionStreamController = StreamController<double?>();
    _alignDirectionStreamController = StreamController<double?>();

    audioPlayer.stop();
    _positionStream =
        context.read<LocationCubit>().stream.listen((position) async {
      await postUpdate(position);
    });

    _playerStateStream = audioPlayer.playerStateStream.listen((event) {
      if (!mounted) return;

      if (event.processingState == ProcessingState.completed) {
        apiController.closeCurrentPOI();
        context.read<AudioCubit>().setStartedPlaying(false);
      }

      context.read<AudioCubit>().setPlayerState(event);
    });

    apiController.start(2000, (data) async {
      if (!mounted) return;

      if (data.info != null) {
        print('setting data');
        context.read<POICubit>().setPOI(data.info!);
      }

      var audioState = context.read<AudioCubit>();

      print(
          'audioready: ${data.audioReady}, startedPlaying: ${audioState.state.startedPlaying}');
      if (data.audioReady && !audioState.state.startedPlaying) {
        var audioUrl = apiController.lastAudioUrl();

        // final tempDir = await getTemporaryDirectory();
        // final filePath = '${tempDir.path}/${apiController.lastAudioId}.mp3';
        // await Dio().download(audioUrl, filePath);

        print('playing $audioUrl');
        audioPlayer.setUrl(audioUrl, preload: true);
        audioPlayer.play();

        audioState.setStartedPlaying(true);
      }
    });

    myLocation();
  }

  Future<void> postUpdate(LocationMarkerPosition position) async {
    var response = await tryApi(() => apiController.updateLocation(
        UpdateRequest(
            lat: position.latitude,
            lon: position.longitude,
            prevent: apiController.hasNewAudio)));

    if (response == null) {
      print('relogging in');
      await tryApi(
          () => apiController.createToken(context.read<ConfigCubit>().state));
    }
  }

  Future<void> myLocation() async {
    setState(() {
      _alignPositionOnUpdate = AlignOnUpdate.always;
      _alignDirectionOnUpdate = AlignOnUpdate.always;
    });

    _alignPositionStreamController.add(17);
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    _positionStream.cancel();
    _playerStateStream.cancel();
    apiController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomPanelWrapper(
        body: Stack(
          children: [
            BlocBuilder<POICubit, POI>(
              builder: (context, poi) {
                print('poi: ${poi.name} ${poi.hasLocation} ${poi.location}');
                return FlutterMap(
                  mapController: _animatedController.mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(51.509364, -0.128928),
                    initialZoom: 9.2,
                    onPositionChanged: (camera, hasGesture) {
                      if (!hasGesture) return;

                      setState(() {
                        if (_alignPositionOnUpdate != AlignOnUpdate.never) {
                          _alignPositionOnUpdate = AlignOnUpdate.never;
                        }

                        if (_alignDirectionOnUpdate != AlignOnUpdate.never) {
                          _alignDirectionOnUpdate = AlignOnUpdate.never;
                        }
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    CurrentLocationLayer(
                      alignPositionStream:
                          _alignPositionStreamController.stream,
                      alignPositionOnUpdate: _alignPositionOnUpdate,
                      alignDirectionStream:
                          _alignDirectionStreamController.stream,
                      alignDirectionOnUpdate: _alignDirectionOnUpdate,
                      positionStream: context.read<LocationCubit>().stream,
                    ),
                    MarkerLayer(
                      markers: [
                        if (!poi.isEmpty && poi.hasLocation)
                          Marker(
                              point: LatLng(poi.latitude, poi.longitude),
                              width: 100,
                              height: 100,
                              child: const Center(
                                  child: Icon(Icons.location_pin,
                                      color: Colors.red, size: 40)),
                              rotate: true),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(Uri.parse(
                              'https://openstreetmap.org/copyright')), // (external)
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SafeArea(
              child: Stack(
                children: [
                  const TopPanel(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 140, right: 10),
                      child: FloatingActionButton(
                          onPressed: () {
                            myLocation();
                          },
                          child: const Icon(Icons.my_location)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
