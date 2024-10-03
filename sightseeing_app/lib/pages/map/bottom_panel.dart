import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sightseeing_app/models/poi.dart';
import 'package:sightseeing_app/services/api.dart';
import 'package:sightseeing_app/services/audio.dart';
import 'package:sightseeing_app/state/audio.dart';
import 'package:sightseeing_app/state/poi.dart';

import '../../components/sliding_panel.dart';
import 'bottom_panel_collapsed.dart';

const double height = 100;

class BottomPanelBody extends StatelessWidget {
  const BottomPanelBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<POICubit, POI>(
      builder: (context, state) => Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            const ScrollableIndicator(),
            Padding(
              padding: const EdgeInsets.all(25.0).copyWith(top: 14, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          state.isEmpty
                              ? 'Looking for nearby attractions...'
                              : state.name ?? 'None',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (!state.isEmpty) ...[
                        const AudioIcon(),
                        const CloseIcon(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (!state.isEmpty) ...[
                    Text(state.description ?? 'No description')
                  ] else
                    const Text('Keep walking!')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ScrollableIndicator extends StatelessWidget {
  const ScrollableIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.grey.withOpacity(0.9),
            ),
            width: 50,
            height: 3));
  }
}

class AudioIcon extends StatelessWidget {
  const AudioIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, PlayerState>(
      builder: (context, audioState) => IconButton(
          onPressed: () {
            if (audioState.processingState != ProcessingState.ready) {
              Fluttertoast.showToast(msg: 'Audio is loading...');
              return;
            }

            if (audioPlayer.playing) {
              audioPlayer.pause();
            } else {
              audioPlayer.play();
            }
          },
          icon: audioState.processingState == ProcessingState.ready
              ? Icon(audioState.playing ? Icons.pause : Icons.play_arrow)
              : const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ))),
    );
  }
}

class CloseIcon extends StatelessWidget {
  const CloseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          audioPlayer.stop();
          context.read<POICubit>().setPOI(POI.empty());
          apiController.closeCurrentPOI();
        },
        icon: const Icon(Icons.close));
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

