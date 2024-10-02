import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_button/group_button.dart';
import 'package:sightseeing_app/components/button_group_select.dart';
import 'package:sightseeing_app/state/config.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final GroupButtonController _voiceController = GroupButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: const Text('SightApp'),
      //   toolbarHeight: 100,
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
                alignment: Alignment.center,
                child: Text('SightApp',
                    style: Theme.of(context).textTheme.headlineLarge)),
            Container(height: 70),
            BlocBuilder<ConfigCubit, ConfigState>(
              builder: (context, config) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Text("Your guide's voice",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 15),
                    ButtonGroupSelect<String>(
                      items: voices,
                      builder: (item, context) => Text(item),
                      selectedIndex: voices.indexOf(config.voice),
                      onSelected: (index, item) {
                        context.read<ConfigCubit>().setVoice(item);
                      },
                    ),
                    const SizedBox(height: 40),
                    Text("Your guide's mood",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 15),
                    ButtonGroupSelect<String>(
                        items: moods,
                        builder: (item, context) => Text(item),
                        selectedIndex: moods.indexOf(config.mood),
                        onSelected: (index, item) {
                          context.read<ConfigCubit>().setMood(item);
                        }),
                    const SizedBox(height: 50),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/map');
                        },
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(130, 50),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Enter'),
                            SizedBox(width: 8),
                            Icon(Icons.chevron_right, size: 24)
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
