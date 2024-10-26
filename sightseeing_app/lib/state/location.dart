import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sightseeing_app/models/location.dart';

class LocationCubit extends Cubit<CustomLocation> {
  StreamSubscription<Position>? _positionSubscription;

  LocationCubit() : super(defaultLocation) {
    if (!kIsWeb) {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 50,
        ),
      ).listen((Position position) {
        final location = CustomLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        emit(location);
      });
    }
  }

  void setLocation(double latitude, double longitude) {
    if (state.latitude != latitude || state.longitude != longitude) {
      final customPosition = CustomLocation(
        latitude: latitude,
        longitude: longitude,
      );

      emit(customPosition);
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
