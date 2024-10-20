import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sightseeing_app/pages/map/map.dart';
import 'package:sightseeing_app/pages/start.dart';
import 'package:sightseeing_app/state/audio.dart';
import 'package:sightseeing_app/state/config.dart';
import 'package:sightseeing_app/state/poi.dart';
import 'package:sightseeing_app/state/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            '/map': (context) => MultiBlocProvider(providers: [
                  BlocProvider(create: (_) => AudioCubit()),
                  BlocProvider(create: (_) => POICubit()),
                  BlocProvider(create: (_) => LocationCubit()),
                ], child: const MapScreen()),
          }),
    );
  }
}
