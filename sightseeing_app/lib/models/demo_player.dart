import 'package:sightseeing_app/models/location.dart';

final int secondsPerStep = 10;

final List<CustomLocation> demoPath = [
  CustomLocation(latitude: 51.50337, longitude: -0.14899),
  CustomLocation(latitude: 51.50257, longitude: -0.15069),
  CustomLocation(latitude: 51.50265, longitude: -0.14932),
  CustomLocation(latitude: 51.50244, longitude: -0.14355),
  CustomLocation(latitude: 51.50288, longitude: -0.14210),
  CustomLocation(latitude: 51.50248, longitude: -0.14133),
  CustomLocation(latitude: 51.50229, longitude: -0.13997),
  CustomLocation(latitude: 51.50181, longitude: -0.13978),
  CustomLocation(latitude: 51.50150, longitude: -0.13993),
  CustomLocation(latitude: 51.50052, longitude: -0.13901),
  CustomLocation(latitude: 51.50075, longitude: -0.13603),
  CustomLocation(latitude: 51.50132, longitude: -0.13063),
  CustomLocation(latitude: 51.50111, longitude: -0.12763),
  CustomLocation(latitude: 51.50090, longitude: -0.12638),
  CustomLocation(latitude: 51.50084, longitude: -0.12400),
  CustomLocation(latitude: 51.50491, longitude: -0.12300),
  CustomLocation(latitude: 51.50649, longitude: -0.12226),
  CustomLocation(latitude: 51.50746, longitude: -0.12701),
  CustomLocation(latitude: 51.50787, longitude: -0.12723),
  CustomLocation(latitude: 51.50854, longitude: -0.12751),
  CustomLocation(latitude: 51.50845, longitude: -0.12821),
];

class DemoPlayerState {
  final bool isPlaying;
  final int step;

  DemoPlayerState({required this.isPlaying, required this.step});
}
