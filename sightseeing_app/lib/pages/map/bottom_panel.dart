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

class BottomPanelBody extends StatefulWidget {
  final ScrollController? scrollController;

  const BottomPanelBody({super.key, this.scrollController});

  @override
  _BottomPanelBodyState createState() => _BottomPanelBodyState();
}

class _BottomPanelBodyState extends State<BottomPanelBody> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<POICubit, POI>(
      builder: (context, state) => Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Column(
            children: [
              const ScrollableIndicator(),
              Padding(
                padding: const EdgeInsets.all(25.0).copyWith(top: 14),
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
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.imagesUrls.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 250,
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      controller: _pageController,
                                      itemCount: state.imagesUrls.length,
                                      itemBuilder: (context, index) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.network(
                                            '${apiController.baseUrl}/${state.imagesUrls[index]!}',
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                          ),
                                        );
                                      },
                                    ),
                                    if (_pageController.hasClients &&
                                        _pageController.page != 0)
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_left,
                                              size: 48, color: Colors.white),
                                          onPressed: () {
                                            _pageController.previousPage(
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                      ),
                                    if (_pageController.hasClients &&
                                        _pageController.page !=
                                            state.imagesUrls.length - 1)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_right,
                                              size: 48, color: Colors.white),
                                          onPressed: () {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                            ],
                            Text(state.description ?? 'No description'),
                          ])
                    ] else
                      const Text('Keep walking!')
                  ],
                ),
              ),
            ],
          ),
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
    return BlocBuilder<AudioCubit, AudioState>(
        builder: (context, audioState) => IconButton(
              onPressed: () {
                if (audioPlayer.processingState == ProcessingState.completed) {
                  audioPlayer.seek(const Duration());
                  audioPlayer.play();
                  return;
                }

                if (audioState.playerState.processingState !=
                    ProcessingState.ready) {
                  Fluttertoast.showToast(msg: 'Audio is loading...');
                  return;
                }

                if (audioPlayer.playing) {
                  audioPlayer.pause();
                } else {
                  audioPlayer.play();
                }
              },
              icon: _buildIcon(audioState),
            ));
  }

  Widget _buildIcon(AudioState audioState) {
    if (audioState.playerState.processingState == ProcessingState.ready) {
      return Icon(
          audioState.playerState.playing ? Icons.pause : Icons.play_arrow);
    }

    if (audioState.playerState.processingState == ProcessingState.completed) {
      return const Icon(Icons.replay);
    }

    return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ));
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
          context.read<AudioCubit>().setStartedPlaying(false);
          apiController.closeCurrentPOI();
        },
        icon: const Icon(Icons.close));
  }
}

class BottomPanelWrapper extends StatelessWidget {
  final Widget body;
  final ScrollController scrollController = ScrollController();

  BottomPanelWrapper({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
        margin: const EdgeInsets.all(10).copyWith(bottom: 16, top: 0),
        minHeight: height,
        maxHeight: 550,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10.0,
            color: Color.fromRGBO(0, 0, 0, 0.3),
          )
        ],
        panelBuilder: () => BottomPanelBody(scrollController: scrollController),
        collapsed: const BottomPanelCollapsed(),
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        body: body);
  }
}
