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
    await _checkLocation();
    if (!mounted) return;

    var config = context.read<ConfigCubit>();
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
            body: "Hello",
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
            title: "Who will be your guide?",
            bodyWidget: Column(
              children: [
                const Text("Choose your guide's voice."),
                const SizedBox(height: 30),
                ButtonGroupSelect<String>(
                  items: voices,
                  builder: (item, context) => Text(item),
                  selectedIndex: voices.indexOf(config.voice),
                  onSelected: (index, item) {
                    context.read<ConfigCubit>().setVoice(item);
                  },
                ),
              ],
            ),
            image: const Center(
              child: Icon(Icons.record_voice_over, size: 50.0),
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
                    items: preferences,
                    radio: false,
                    builder: (item, context) => Text(item),
                    selectedIndexes: config.preferences.map((x) => preferences.indexOf(x)).toList(),
                    onSelectedMultiple: (indexes) {
                      context.read<ConfigCubit>().setPreferences(indexes.map((x) => preferences[x]).toList());
                    }),
              ],
            ),
            image: const Center(
              child: Icon(Icons.attractions, size: 50.0),
            ),
          ),

        ],
      ),
    );
  }
}
