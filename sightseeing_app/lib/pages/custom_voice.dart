import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sightseeing_app/components/button_group_select.dart';
import 'package:sightseeing_app/models/config.dart';
import 'package:sightseeing_app/services/api.dart';
import 'package:sightseeing_app/services/location.dart';
import 'package:sightseeing_app/state/config.dart';
import 'dart:math';
import 'package:sightseeing_app/state/voice_config.dart';

class CustomVoicePage extends StatefulWidget {
  @override
  _CustomVoicePageState createState() => _CustomVoicePageState();
}

class _CustomVoicePageState extends State<CustomVoicePage> {
  final List<String> ages = ["Teenage", "Adult", "Middle-Aged", "Old"];
  final List<String> genders = ["Male", "Female", "Gender Neutral"];
  final List<String> tones = ["Gruff", "Soft", "Warm", "Raspy"];
  final List<String> pitches = ["High", "Normal", "Low", "Squeaky"];
  final List<String> moods = ["Happy", "Sad", "Excited", "Calm"];
  final List<String> speeds = ["Slow", "Normal", "Fast"];

  bool isLoading = false;
  bool isGenerated = false;

  late VoiceConfig voiceConfig;
  int playedVoiceIndex = -1;
  bool isPlaying = false;

  List<String> voiceIds = [];
  List<String> voicePreviewsIds = [];

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    selectRandomVoiceConfig();
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  void selectRandomVoiceConfig() {
    final random = Random();
    voiceConfig = VoiceConfig(
      age: ages[random.nextInt(ages.length)],
      gender: genders[random.nextInt(genders.length)],
      tone: tones[random.nextInt(tones.length)],
      pitch: pitches[random.nextInt(pitches.length)],
      mood: moods[random.nextInt(moods.length)],
      speed: speeds[random.nextInt(speeds.length)],
    );
  }

  Widget buildButtonGroup(String title, List<String> items, String selectedItem,
      Function(int, String) onSelected) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: ButtonGroupSelect<String>(
            items: items,
            selectedIndex: items
                .indexOf(selectedItem), // Get the index of the selected item
            builder: (item, context) => Text(item),
            onSelected: onSelected,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

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

  Widget buildGeneratedVoices() {
    return Column(
      key: ValueKey(3),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("We have generated 3 voices for you",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: buildVoiceIcon("Voice 1", 0)),
            SizedBox(width: 10),
            Expanded(child: buildVoiceIcon("Voice 2", 1)),
            SizedBox(width: 10),
            Expanded(child: buildVoiceIcon("Voice 3", 2)),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BlocBuilder<ConfigCubit, ConfigState>(
              builder: (context, config) {
              return Expanded(
                child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide.none, // Remove the black border
                ),
                onPressed: () {
                  var config = context.read<ConfigCubit>();
                  apiController.createVoice(voiceIds[voiceConfig.selectedVoiceIndex]).then((voiceId) async {
                  if (mounted) {
                    print("Voice ID: $voiceId");
                    config.setVoiceId(voiceId);

                    audioPlayer.stop();

                    await _checkLocation();
                    if (!mounted) return;

                    await tryApi(() => apiController.createToken(config.state), doThrow: true);
                    if (!mounted) return;

                    Navigator.of(context).pushNamed('/map');
                  }
                  });
                },
                child: Text("Accept Voice", style: TextStyle(color: Colors.green)),
                ),
              );
              },
            ),
            SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide.none, // Remove the black border
                ),
                onPressed: () {
                  setState(() {
                    isGenerated = false;
                  });
                },
                child: Text("Try Again", style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildVoiceIcon(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (playedVoiceIndex == index) {
            if (isPlaying) {
              audioPlayer.stop();
            } else {
              audioPlayer.play();
            }
            isPlaying = !isPlaying;
          } else {
            audioPlayer.setUrl("${apiController.baseUrl}/audio/${voicePreviewsIds[index]}.mp3");
            audioPlayer.play();
          }
          playedVoiceIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: (playedVoiceIndex == index && isPlaying)
              ? Colors.white54
              : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Column(
            children: [
            Icon(
              Icons.volume_up,
              size: 80,
              color: Colors.blueGrey,
            ),
            Text(label),
            SizedBox(height: 10),
            SizedBox(
              width: 100,
              child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                shadowColor: Colors.black,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
                side: BorderSide.none,
              ),
              onPressed: () {
                setState(() {
                voiceConfig.selectedVoiceIndex = index;
                });
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: voiceConfig.selectedVoiceIndex == index
                  ? Text("selected",
                    style: TextStyle(color: Colors.green, fontSize: 12), softWrap: false)
                  : Text("select", style: TextStyle(fontSize: 12), softWrap: false),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Design Your Own Voice"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: isLoading
                  ? Center(
                      key: ValueKey(1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 5.0,
                            ),
                          ),
                          SizedBox(height: 60),
                          Text("We are generating voice for you",
                              style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    )
                  : isGenerated
                      ? buildGeneratedVoices()
                      : SingleChildScrollView(
                          key: ValueKey(2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildButtonGroup(
                                  "Select Age", ages, voiceConfig.age,
                                  (index, item) {
                                setState(() {
                                  voiceConfig.age = item;
                                });
                              }),
                              buildButtonGroup(
                                  "Select Gender", genders, voiceConfig.gender,
                                  (index, item) {
                                setState(() {
                                  voiceConfig.gender = item;
                                });
                              }),
                              buildButtonGroup(
                                  "Select Tone", tones, voiceConfig.tone,
                                  (index, item) {
                                setState(() {
                                  voiceConfig.tone = item;
                                });
                              }),
                              buildButtonGroup(
                                  "Select Pitch", pitches, voiceConfig.pitch,
                                  (index, item) {
                                setState(() {
                                  voiceConfig.pitch = item;
                                });
                              }),
                              buildButtonGroup(
                                  "Select Mood", moods, voiceConfig.mood,
                                  (index, item) {
                                setState(() {
                                  voiceConfig.mood = item;
                                });
                              }),
                              buildButtonGroup(
                                  "Select Speed", speeds, voiceConfig.speed,
                                  (index, item) {
                                setState(() {
                                  voiceConfig.speed = item;
                                });
                              }),
                              SizedBox(
                                  height: 80), // Add some space for the button
                            ],
                          ),
                        ),
            ),
          ),
          if (!isGenerated & !isLoading) ...[
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    // Simulate a delay for generating voice
                    apiController.createPreviews(voiceConfig).then((value) {
                      Future.doWhile(() async {
                        var data =
                            await apiController.getCustomVoicePreviews();
                        if (data.done) {
                          setState(() {
                            isLoading = false;
                            isGenerated = true;
                            voiceIds = data.previews.map((e) => e.voice_id).toList();
                            voicePreviewsIds = data.previews.map((e) => e.id).toList();
                          });
                          return false;
                        }
                        await Future.delayed(Duration(milliseconds: 800));
                        return true;
                      });
                    });
                  },
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    "Let's generate your voice",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
