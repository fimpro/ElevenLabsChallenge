import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sightseeing_app/state/location.dart';

class FakeNavScreen extends StatefulWidget {
  const FakeNavScreen({super.key});

  @override
  State<FakeNavScreen> createState() => _FakeNavScreenState();
}

class _FakeNavScreenState extends State<FakeNavScreen>
    with TickerProviderStateMixin {
  late final AnimatedMapController _animatedController =
      AnimatedMapController(vsync: this);
  late AlignOnUpdate _alignPositionOnUpdate;
  late AlignOnUpdate _alignDirectionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;
  late final StreamController<double?> _alignDirectionStreamController;
  @override
  void initState() {
    super.initState();

    _alignPositionOnUpdate = AlignOnUpdate.always;
    _alignDirectionOnUpdate = AlignOnUpdate.always;
    _alignPositionStreamController = StreamController<double?>();
    _alignDirectionStreamController = StreamController<double?>();
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    _alignDirectionStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<LocationCubit, LocationMarkerPosition?>(
            builder: (context, state) {
              return FlutterMap(
                mapController: _animatedController.mapController,
                options: MapOptions(
                  initialCenter: const LatLng(51.509364, -0.128928),
                  initialZoom: 9.2,
                  onTap: (tapPosition, point) {
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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  CurrentLocationLayer(
                    alignPositionStream: _alignPositionStreamController.stream,
                    alignPositionOnUpdate: _alignPositionOnUpdate,
                    alignDirectionStream:
                        _alignDirectionStreamController.stream,
                    alignDirectionOnUpdate: _alignDirectionOnUpdate,
                    positionStream: context.read<LocationCubit>().stream,
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
