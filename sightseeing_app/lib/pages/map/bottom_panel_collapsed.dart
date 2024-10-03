
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sightseeing_app/components/my_card.dart';

import '../../models/poi.dart';
import '../../state/poi.dart';
import 'bottom_panel.dart';

class BottomPanelCollapsed extends StatefulWidget {
  const BottomPanelCollapsed({super.key});

  @override
  State<BottomPanelCollapsed> createState() => _BottomPanelCollapsedState();
}

class _BottomPanelCollapsedState extends State<BottomPanelCollapsed> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyCard(
        elevation: 0,
        padding: EdgeInsets.zero,
        height: height,
        child: BlocBuilder<POICubit, POI>(
          builder: (context, state) => Column(
            children: [
              const ScrollableIndicator(),
              Padding(
                padding: const EdgeInsets.all(25.0).copyWith(right: 8, top: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    state.isEmpty
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Looking for nearby attractions...',
                            style:
                            Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Keep walking!',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    )
                        : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.62,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    state.name ?? 'None',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ),
                                // const SizedBox(width: 5),
                                // const Icon(Icons.volume_up, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                                ellipsis(
                                    state.description ?? 'No description',
                                    40),
                                style:
                                Theme.of(context).textTheme.bodySmall)
                          ]),
                    ),
                    if (!state.isEmpty) ...[
                      const AudioIcon(),
                      const CloseIcon()
                    ]
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

String ellipsis(String s, int maxChars) {
  if (s.length <= maxChars) return s;
  var truncated = s.substring(0, maxChars - 3);
  return '$truncated...';
}
