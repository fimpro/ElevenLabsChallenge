import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sightseeing_app/components/my_card.dart';
import 'package:sightseeing_app/state/config.dart';
import 'package:sightseeing_app/state/location.dart';
import 'package:sightseeing_app/models/location.dart';

import '../../models/config.dart';

class TopPanel extends StatelessWidget {
  const TopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigCubit, ConfigState>(
      builder: (context, config) => Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: MyCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 80,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_outlined)),
                    const SizedBox(width: 16),
                    BlocBuilder<LocationCubit, CustomLocation>(
                      builder: (context, location) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !kIsWeb
                              ? FutureBuilder(
                                  future: placemarkFromCoordinates(
                                      location.latitude, location.longitude),
                                  builder: (context, snapshot) {
                                    var text = 'Exploring...';

                                    var placemark = snapshot.data?.firstOrNull;

                                    if (placemark != null) {
                                      text = 'Exploring ${placemark.locality}';
                                    }

                                    return Text(
                                      text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    );
                                  },
                                )
                              : Text(
                                  'Exploring London',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                          const SizedBox(height: 4),
                          Text('${getVoiceName(config.voiceId)} • ${config.emotions}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                )),
          )),
    );
  }
}
