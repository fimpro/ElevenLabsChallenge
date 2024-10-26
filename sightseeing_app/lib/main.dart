import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sightseeing_app/pages/map/map.dart';
import 'package:sightseeing_app/pages/start_new.dart';
import 'package:sightseeing_app/services/demo_ui/demo_ui.dart';
import 'package:sightseeing_app/state/audio.dart';
import 'package:sightseeing_app/state/config.dart';
import 'package:sightseeing_app/state/poi.dart';
import 'package:sightseeing_app/state/location.dart';
import 'package:sightseeing_app/state/player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConfigCubit(),
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const StartScreen(),
            '/map': (context) => MultiBlocProvider(providers: [
                  BlocProvider(create: (_) => AudioCubit()),
                  BlocProvider(create: (_) => POICubit()),
                  BlocProvider(create: (_) => LocationCubit()),
                  BlocProvider(create: (_) => PlayerCubit()),
                ], child: const MapScreen()),
          }),
    );
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      webDemoUI?.dispose();
      webDemoUI = WebDemoUI();
    }
  }

  @override
  void dispose() {
    super.dispose();

    webDemoUI?.dispose();
  }
}
