import 'package:sightseeing_app/models/location.dart';

final List<CustomLocation> demoPath = [
  CustomLocation(latitude: 37.7749, longitude: -122.4194),
  CustomLocation(latitude: 34.0522, longitude: -118.2437),
  CustomLocation(latitude: 40.7128, longitude: -74.0060),
  CustomLocation(latitude: 40.7128, longitude: -74.0060),
];

class DemoPlayerState {
  final bool isPlaying;
  final int step;

  DemoPlayerState({required this.isPlaying, required this.step});
}
