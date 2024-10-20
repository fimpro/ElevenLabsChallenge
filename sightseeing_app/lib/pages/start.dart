import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sightseeing_app/components/button_group_select.dart';
import 'package:sightseeing_app/services/api.dart';
import 'package:sightseeing_app/state/config.dart';

import '../models/config.dart';
import '../services/location.dart';

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

    if(!mounted) return;

    var config = context.read<ConfigCubit>();

    if(!mounted) return;

    await tryApi(() => apiController.createToken(config.state), doThrow: true);

    Navigator.of(context).pushNamed('/map');
  }

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
                    TextFormField(
                      decoration: const InputDecoration(label: Text("Api URL"), border: OutlineInputBorder()),
                      initialValue: apiController.baseUrl,
                      onChanged: (value) => apiController.baseUrl = value,
                    ),
                    SizedBox(height: 25),
                    Text("Language",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    ButtonGroupSelect<String>(
                      items: languages,
                      builder: (item, context) => Text(item),
                      selectedIndex: languages.indexOf(config.language),
                      onSelected: (index, item) {
                        context.read<ConfigCubit>().setLanguage(item);
                      },
                    ),

                    SizedBox(height: 25),
                    Text("Your guide's voice",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    ButtonGroupSelect<String>(
                      items: voices,
                      builder: (item, context) => Text(item),
                      selectedIndex: voices.indexOf(config.voice),
                      onSelected: (index, item) {
                        context.read<ConfigCubit>().setVoice(item);
                      },
                    ),
                    const SizedBox(height: 25),
                    Text("Your guide's mood",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    ButtonGroupSelect<String>(
                        items: moods,
                        builder: (item, context) => Text(item),
                        selectedIndex: moods.indexOf(config.emotions),
                        onSelected: (index, item) {
                          context.read<ConfigCubit>().setMood(item);
                        }),
                    const SizedBox(height: 25),
                    Text("Your preferences",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    ButtonGroupSelect<String>(
                        items: preferences,
                        radio: false,
                        builder: (item, context) => Text(item),
                        selectedIndexes: config.preferences.map((x) => preferences.indexOf(x)).toList(),
                        onSelectedMultiple: (indexes) {
                          context.read<ConfigCubit>().setPreferences(indexes.map((x) => preferences[x]).toList());
                        }),
                    const SizedBox(height: 50),
                    ElevatedButton(
                        onPressed: () {
                          _startApp();
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
