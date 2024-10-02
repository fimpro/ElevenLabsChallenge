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
  late final StreamSubscription<Position> _positionStream;
  late final StreamSubscription<PlayerState> _playerStateStream;

  @override
  void initState() {
    super.initState();

    _alignPositionOnUpdate = AlignOnUpdate.always;
    _alignDirectionOnUpdate = AlignOnUpdate.always;
    _alignPositionStreamController = StreamController<double?>();
    _alignDirectionStreamController = StreamController<double?>();

    _positionStream = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 50))
        .listen((position) async {
      var response = await tryApi(() => apiController.update(UpdateRequest(
          lat: position.latitude,
          lng: position.longitude,
          prevent: apiController.hasNewAudio)));

      if(response == null) {
        print('relogging in');
        await tryApi(() => apiController.login(context.read<ConfigCubit>().state));
      }
    });

    _playerStateStream = audioPlayer.playerStateStream.listen((event) {
      if(!mounted) return;

      if(event.processingState == ProcessingState.completed) {
        apiController.hasNewAudio = false;
      }

      context.read<AudioCubit>().setState(event);
    });

    apiController.start(2000, (data) {
      if (!mounted) return;

      if (data.info != null) {
        context.read<POICubit>().setPOI(data.info!);
      }

      if (data.audioReady) {
        audioPlayer.setUrl(apiController.lastAudioUrl());
        audioPlayer.play();
      }
    });

    myLocation();
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    _positionStream.cancel();
    _playerStateStream.cancel();
    apiController.stop();
    super.dispose();
  }

  Future<void> myLocation() async {
    setState(() {
      _alignPositionOnUpdate = AlignOnUpdate.always;
      _alignDirectionOnUpdate = AlignOnUpdate.always;
    });

    _alignPositionStreamController.add(18);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomPanelWrapper(
        body: Stack(
          children: [
            FlutterMap(
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                CurrentLocationLayer(
                  alignPositionStream: _alignPositionStreamController.stream,
                  alignPositionOnUpdate: _alignPositionOnUpdate,
                  alignDirectionStream: _alignDirectionStreamController.stream,
                  alignDirectionOnUpdate: _alignDirectionOnUpdate,
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
