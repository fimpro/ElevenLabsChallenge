import 'package:flutter/material.dart';
import 'package:sightseeing_app/pages/map/map.dart';
import 'package:sightseeing_app/components/fake_nav.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            flex: 1,
            child: MapScreen(),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16.0), // Add margin here
                child: const FakeNavScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
