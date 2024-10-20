import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

const defaultLocation = LocationMarkerPosition(
  latitude: 51.509364,
  longitude: -0.128928,
  accuracy: 1.0,
);

class LocationCubit extends Cubit<LocationMarkerPosition> {
  StreamSubscription<Position>? _positionSubscription;

  LocationCubit() : super(defaultLocation) {
    if (kIsWeb) {
      emit(defaultLocation);
    } else {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 50,
        ),
      ).listen((Position position) {
        final location = LocationMarkerPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        );
        emit(location);
      });
    }
  }

  void setLocation(double latitude, double longitude) {
    final customPosition = LocationMarkerPosition(
      latitude: latitude,
      longitude: longitude,
      accuracy: 0.0,
    );
    emit(customPosition);
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
