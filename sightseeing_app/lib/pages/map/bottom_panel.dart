import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sightseeing_app/services/api.dart';
import 'package:sightseeing_app/services/audio.dart';
import 'package:sightseeing_app/state/poi.dart';

import '../../components/my_card.dart';
import '../../components/sliding_panel.dart';

const double height = 100;

class BottomPanelBody extends StatelessWidget {
  const BottomPanelBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<POICubit, POIResponse>(
      builder: (context, state) => Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BottomPanelCollapsed(isPanelOpen: true),
            const SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: state.isEmpty
                  ? const Text('Keep walking!')
                  : const Text(
                      'Taki sobie no jest haha lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet'),
            )
          ],
        ),
      ),
    );
  }
}

class BottomPanelCollapsed extends StatelessWidget {
  final bool isPanelOpen;

  const BottomPanelCollapsed({super.key, this.isPanelOpen = false});

  @override
  Widget build(BuildContext context) {
    return MyCard(
        elevation: 0,
        padding: EdgeInsets.zero,
        height: height,
        child: BlocBuilder<POICubit, POIResponse>(
          builder: (context, state) => Column(
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.grey.withOpacity(0.9),
                      ),
                      width: 50,
                      height: 3)),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.all(25.0).copyWith(right: 8, top: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      state.isEmpty
                          ? Align(
                              child: Text('Looking for nearby attractions...',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Dworzec PKP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.volume_up, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Taki sobie no jest...',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)
                              ],
                            ),
                      if (!state.isEmpty) ...[
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              if (audioPlayer.playing) {
                                audioPlayer.pause();
                              } else {
                                audioPlayer.play();
                              }
                            },
                            icon: Icon(audioPlayer.playing
                                ? Icons.pause
                                : Icons.play_arrow)),
                        IconButton(
                            onPressed: () {
                              audioPlayer.stop();
                              context
                                  .read<POICubit>()
                                  .setPOI(POIResponse.empty());
                            },
                            icon: const Icon(Icons.close))
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class BottomPanelWrapper extends StatelessWidget {
  final Widget body;

  const BottomPanelWrapper({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
        margin: const EdgeInsets.all(10).copyWith(bottom: 16, top: 0),
        minHeight: height,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10.0,
            color: Color.fromRGBO(0, 0, 0, 0.3),
          )
        ],
        panelBuilder: () => const BottomPanelBody(),
        collapsed: const BottomPanelCollapsed(),
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        body: body);
  }
}
