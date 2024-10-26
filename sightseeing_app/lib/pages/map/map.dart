import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
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
  late final StreamSubscription<LocationMarkerPosition>
      _positionStreamSubscription;
  late final StreamController<LocationMarkerPosition>
      _mapPositionStreamController;
  late final StreamSubscription<PlayerState> _playerStateStream;

  @override
  void initState() {
    super.initState();

    _alignPositionOnUpdate = AlignOnUpdate.always;
    _alignDirectionOnUpdate = AlignOnUpdate.always;
    _alignPositionStreamController = StreamController<double?>();
    _alignDirectionStreamController = StreamController<double?>();
    _mapPositionStreamController = StreamController<LocationMarkerPosition>();

    audioPlayer.stop();

    Geolocator.getCurrentPosition().then((position) {
      postUpdate(LocationMarkerPosition(latitude: position.latitude, longitude: position.longitude, accuracy: 1.0));
    });

    _positionStreamSubscription =
        context.read<LocationCubit>().stream.listen((position) async {
      _mapPositionStreamController.add(position);
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

    _mapPositionStreamController.add(context.read<LocationCubit>().state);

    _alignPositionStreamController.add(17);
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    _mapPositionStreamController.close();
    _positionStreamSubscription.cancel();
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
                    initialCenter: LatLng(
                        defaultLocation.latitude, defaultLocation.longitude),
                    initialZoom: 9.2,
                    onTap: (tapPosition, point) {
                      if (!kIsWeb) return;
                      setState(() {
                        context.read<LocationCubit>().setLocation(
                              point.latitude,
                              point.longitude,
                            );
                      });
                    },
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
                      tileProvider: CancellableNetworkTileProvider(),
                      urlTemplate:
                          'https://api.maptiler.com/maps/bright-v2/{z}/{x}/{y}.png?key=fl9YfQ3ia2xgpDnqSFEp',
                      tileSize: 512,
                      zoomOffset: -((512 / 256) - 1),
                      userAgentPackageName: 'com.sightseeingapp.app',
                    ),
                    CurrentLocationLayer(
                      alignPositionStream:
                          _alignPositionStreamController.stream,
                      alignPositionOnUpdate: _alignPositionOnUpdate,
                      alignDirectionStream:
                          _alignDirectionStreamController.stream,
                      alignDirectionOnUpdate: _alignDirectionOnUpdate,
                      positionStream: _mapPositionStreamController.stream,
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
                    SizedBox.expand(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 118.0, left: 5),
                        child: RichAttributionWidget(
                          alignment: AttributionAlignment.bottomLeft,
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () => launchUrl(Uri.parse(
                                  'https://openstreetmap.org/copyright')),
                            ),
                            TextSourceAttribution(
                              'MapTiler',
                              onTap: () => launchUrl(Uri.parse(
                                  'https://www.maptiler.com/copyright/')),
                            ),
                          ],
                          showFlutterMapAttribution: false,
                        ),
                      ),
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
