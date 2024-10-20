import 'dart:async';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playingForward, playingReverse }

enum SelectedDirection { forward, reverse }

class GPSPlayer extends StatefulWidget {
  @override
  _GPSPlayerState createState() => _GPSPlayerState();
}

class _GPSPlayerState extends State<GPSPlayer> {
  double _progress = 0.0;
  SelectedDirection _selectedDirection = SelectedDirection.forward;
  PlayerState _playerState = PlayerState.stopped;
  double _stepDuration = 5.0;
  static const int dt = 100; // 100 ms
  late double dProgress;
  final int _totalSteps = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    dProgress = dt / 1000 / _stepDuration / _totalSteps;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: dt), (timer) {
      setState(() {
        if (_playerState == PlayerState.playingForward) {
          _progress += dProgress;
          if (_progress >= 1.0) {
            _progress = 1.0;
            _playerState = PlayerState.stopped;
          }
        } else if (_playerState == PlayerState.playingReverse) {
          _progress -= dProgress;
          if (_progress <= 0.0) {
            _progress = 0.0;
            _playerState = PlayerState.stopped;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomPaint(
            painter: ProgressPainter(_progress, _totalSteps),
            child: Container(
              height: 10,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.fast_rewind,
                  color: _selectedDirection == SelectedDirection.reverse
                      ? Colors.blue
                      : null),
              onPressed: () {
                setState(() {
                  _selectedDirection = SelectedDirection.reverse;
                  _playerState = PlayerState.playingReverse;
                });
              },
            ),
            IconButton(
                icon: Icon(_playerState == PlayerState.stopped
                    ? Icons.play_arrow
                    : Icons.pause),
                onPressed: () {
                  setState(() {
                    if (_playerState == PlayerState.stopped) {
                      _playerState =
                          _selectedDirection == SelectedDirection.forward
                              ? PlayerState.playingForward
                              : PlayerState.playingReverse;
                    } else {
                      _playerState = PlayerState.stopped;
                    }
                  });
                }),
            IconButton(
              icon: Icon(Icons.fast_forward,
                  color: _selectedDirection == SelectedDirection.forward
                      ? Colors.blue
                      : null),
              onPressed: () {
                setState(() {
                  _selectedDirection = SelectedDirection.forward;
                  _playerState = PlayerState.playingForward;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ProgressPainter extends CustomPainter {
  final double progress;
  final int totalSteps;

  ProgressPainter(this.progress, this.totalSteps);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0 // Slimmer progress line
      ..style = PaintingStyle.stroke;

    final trackPaint = Paint()
      ..color = Colors.blue[200]!
      ..strokeWidth = 2.0 // Slimmer track line
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), trackPaint);

    final progressWidth = size.width * progress;
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(progressWidth, size.height / 2), paint);

    final stepPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    final elapsedStepPaint = Paint()
      ..color = const Color.fromARGB(255, 22, 125, 209)
      ..strokeWidth = 3.0;

    final stepWidth = size.width / totalSteps;
    for (int i = 0; i <= totalSteps; i++) {
      final x = i * stepWidth;
      if (i < progress * totalSteps) {
        canvas.drawLine(Offset(x, size.height / 2 - 5),
            Offset(x, size.height / 2 + 5), elapsedStepPaint);
      } else {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), stepPaint);
      }
    }
    final circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(progressWidth, size.height / 2), 8.0, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
