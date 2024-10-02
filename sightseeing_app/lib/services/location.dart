import 'package:geolocator/geolocator.dart';

Future<void> checkLocationPermission() async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
}

Future<Position> getPosition() async {
  var serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  await checkLocationPermission();

  return await Geolocator.getCurrentPosition();
}

Future<Position> getLastKnownPosition() async {
  var serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  await checkLocationPermission();

  return await Geolocator.getLastKnownPosition() ?? await Geolocator.getCurrentPosition();
}