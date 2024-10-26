import 'package:flutter/material.dart';
import 'package:sightseeing_app/pages/map/map.dart';
import 'package:sightseeing_app/components/gps_player.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Expanded(child: MapScreen()),
      // GPSPlayer(),
    ]);
  }
}
