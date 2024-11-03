import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../components/button_group_select.dart';
import '../models/config.dart';
import '../services/api.dart';
import '../services/location.dart';
import '../state/config.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController _addPreferenceController =
      TextEditingController();

  Future<void> _checkLocation() async {
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

  Future<void> _startApp() async {
    var config = context.read<ConfigCubit>();
    if (!mounted) return;

    if (config.state.isCustomVoice){
      Navigator.of(context).pushNamed('/custom-voice');
      return;
    }

    await _checkLocation();
    if (!mounted) return;

    await tryApi(() => apiController.createToken(config.state), doThrow: true);
    if (!mounted) return;

    Navigator.of(context).pushNamed('/map');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigCubit, ConfigState>(
      builder: (context, config) => IntroductionScreen(
        next: const Text("Next"),
        done: const Text("Let's go!"),
        back: const Text("Back"),
        showBackButton: true,
        onDone: () {
          _startApp();
        },
        pages: [
          PageViewModel(
            title: "Welcome to SightVoiceApp!",
            body: "Let's make this visit a memorable one",
            image: const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Image(image: AssetImage('assets/art.png')),
            ),
          ),
          PageViewModel(
            title: "Select your language",
            bodyWidget: Column(
              children: [
                ButtonGroupSelect<String>(
                  items: languages,
                  builder: (item, context) => Text(item),
                  selectedIndex: languages.indexOf(config.language),
                  onSelected: (index, item) {
                    context.read<ConfigCubit>().setLanguage(item);
                  },
                ),
              ],
            ),
            image: const Center(
              child: Icon(Icons.language, size: 50.0),
            ),
          ),
          PageViewModel(
            title: "How are you feeling today?",
            bodyWidget: Column(
              children: [
                const Text("Choose your guide's voice tone."),
                const SizedBox(height: 30),
                ButtonGroupSelect<String>(
                    items: moods,
                    builder: (item, context) => Text(item),
                    selectedIndex: moods.indexOf(config.emotions),
                    onSelected: (index, item) {
                      context.read<ConfigCubit>().setMood(item);
                    }),
              ],
            ),
            image: const Center(
              child: Icon(Icons.mood, size: 50.0),
            ),
          ),
          PageViewModel(
            title: "What do you like the most?",
            bodyWidget: Column(
              children: [
                const Text('Choose your interests.'),
                const SizedBox(height: 30),
                ButtonGroupSelect<String>(
                    key: Key(preferences.length.toString()),
                    items: preferences,
                    radio: false,
                    builder: (item, context) => Text(item),
                    selectedIndexes: config.preferences
                        .map((x) => preferences.indexOf(x))
                        .toList(),
                    onSelectedMultiple: (indexes) {
                      context.read<ConfigCubit>().setPreferences(
                          indexes.map((x) => preferences[x]).toList());
                      for (var i = preferences.length - 1; i >= 0; i--) {
                        if (!indexes.contains(i) &&
                            !predefinedPreferences.contains(preferences[i])) {
                          preferences.removeAt(i);
                        }
                      }
                    }),
                const SizedBox(height: 20),
                OutlinedButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                                padding: const EdgeInsets.symmetric(
                                        vertical: 30, horizontal: 30)
                                    .copyWith(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            30),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Add your interest',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 20),
                                    TextField(
                                      autofocus: true,
                                      controller: _addPreferenceController,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'e.g. I would love to visit local markets',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FilledButton(
                                            onPressed: () {
                                              preferences.add(
                                                  _addPreferenceController
                                                      .text);
                                              context
                                                  .read<ConfigCubit>()
                                                  .addPreference(
                                                      _addPreferenceController
                                                          .text);
                                              _addPreferenceController.text =
                                                  '';
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Add')),
                                      ],
                                    )
                                  ],
                                ),
                              ));
                    },
                    child: Icon(Icons.add)),
              ],
            ),
            image: const Center(
              child: Icon(Icons.attractions, size: 50.0),
            ),
          ),
          PageViewModel(
            title: "Who will be your guide?",
            bodyWidget: Column(
              children: [
                context.watch<ConfigCubit>().state.isCustomVoice
                    ? FilledButton(
                        onPressed: () {},
                        child: Text("Design your custom guide's voice"),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          setState(() {
                            context.read<ConfigCubit>().setIsCustomVoice(true);
                          });
                        },
                        child: Text("Design your custom guide's voice"),
                      ),
                const SizedBox(height: 10),
                !context.watch<ConfigCubit>().state.isCustomVoice
                    ? FilledButton(
                        onPressed: () {},
                        child: Text("Choose from predefined voices"),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          setState(() {
                            context.read<ConfigCubit>().setIsCustomVoice(false);
                          });
                        },
                        child: Text("Choose from predefined voices"),
                      ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: config.isCustomVoice
                      ? null
                      : Column(
                          key: const ValueKey('readyVoice'),
                          children: [
                            const Text("Choose your guide's voice."),
                            const SizedBox(height: 10),
                            ButtonGroupSelect<String>(
                              items: voiceNames,
                              builder: (item, context) => Text(item),
                              selectedIndex: voiceIds.indexOf(config.voiceId),
                              onSelected: (index, item) {
                                context.read<ConfigCubit>().setVoiceId(voiceIds[index]);
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
            image: const Center(
              child: Icon(Icons.record_voice_over, size: 50.0),
            ),
          ),
        ],
      ),
    );
  }
}
