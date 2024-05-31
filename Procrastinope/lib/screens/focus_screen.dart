import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FocusScreen extends StatefulWidget {
  @override
  _FocusScreenState createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isPaused = false;
  final int numAudioFiles = 10;
  final String baseUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-';
  final Random _random = Random();
  Duration _selectedDuration = const Duration(minutes: 10);
  late Timer _timer;
  int _elapsedSeconds = 0;

  void _toggleMusic() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _timer.cancel();
      } else {
        final int randomNum = _random.nextInt(numAudioFiles) + 1;
        final String url = '$baseUrl$randomNum.mp3';
        await _audioPlayer.play(UrlSource(url));

        _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
          if (_elapsedSeconds >= _selectedDuration.inSeconds) {
            timer.cancel();
            _audioPlayer.stop();
            setState(() {
              _isPlaying = false;
              _elapsedSeconds = 0;
            });
          } else {
            setState(() {
              _elapsedSeconds++;
            });
          }
        });
      }
      setState(() {
        _isPlaying = !_isPlaying;
        _isPaused = !_isPlaying;
      });
    } catch (e) {
      print('Audio Error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Session'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Duration:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            DropdownButton<Duration>(
              value: _selectedDuration,
              items: const [
                DropdownMenuItem(
                  value: Duration(minutes: 5),
                  child: Text('5 Minutes'),
                ),
                DropdownMenuItem(
                  value: Duration(minutes: 10),
                  child: Text('10 Minutes'),
                ),
                DropdownMenuItem(
                  value: Duration(minutes: 15),
                  child: Text('15 Minutes'),
                ),
                DropdownMenuItem(
                  value: Duration(minutes: 30),
                  child: Text('30 Minutes'),
                ),
                DropdownMenuItem(
                  value: Duration(minutes: 60),
                  child: Text('1 Hour'),
                ),
                DropdownMenuItem(
                  value: Duration(minutes: 90),
                  child: Text('1 Hour 30 Minutes'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDuration = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPaused ? null : () => _toggleMusic(),
              child: Text(_isPlaying ? 'Pause Music' : 'Play Music'),
            ),
            SizedBox(height: 20),
            Text(
              'Time Elapsed: ${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
