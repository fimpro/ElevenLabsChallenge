import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sightseeing_app/pages/map/map.dart';
import 'package:sightseeing_app/pages/start.dart';
import 'package:sightseeing_app/services/api.dart';
import 'package:sightseeing_app/services/location.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sightseeing_app/state/config.dart';
import 'package:sightseeing_app/state/poi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void initState() {
    checkLocation();
    tryApi(() => apiController.login());
  }

  Future<void> checkLocation() async {
    try {
      await checkLocationPermission();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Location permission disabled",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConfigCubit(),
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const StartScreen(),
            '/map': (context) => BlocProvider(
                create: (_) => POICubit(), child: const MapScreen()),
          }),
    );
  }
}
