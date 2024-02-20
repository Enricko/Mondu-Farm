import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:just_audio/just_audio.dart';

class AudioChatWidget extends StatefulWidget {
  const AudioChatWidget({super.key, required this.data});
  final Map<dynamic, dynamic> data;

  @override
  State<AudioChatWidget> createState() => _AudioChatWidgetState();
}

class _AudioChatWidgetState extends State<AudioChatWidget> {
  late AudioPlayer _audioPlayer;
  PlayerState? _playerState;
  bool _isPlaying = false;
  double _sliderValue = 0.0;
  Duration _position = Duration();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.data['pesan']);
      await _audioPlayer.setVolume(1.0);
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _sliderValue = 0.0;
        });
      });

      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
          if (position.inMilliseconds <= widget.data['durasi']) {
            _sliderValue = position.inMilliseconds.toDouble();
          }
        });
      });
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  Future<void> _togglePlayer() async {
    if (_audioPlayer.playerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    setState(() {});
  }

  Future<void> _seekTo(double milliseconds) async {
    await _audioPlayer.seek(Duration(milliseconds: milliseconds.toInt()));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? duration.inHours.toString() + ":" : ""}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Warna.ungu,
      shape: RoundedRectangleBorder(
        borderRadius: widget.data['pesan_dari'] == "user"
            ? BorderRadius.only(
                bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(20))
            : BorderRadius.only(
                bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(7.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  onPressed: _togglePlayer,
                  icon: Icon(_audioPlayer.playerState.playing ? Icons.pause : Icons.play_arrow,color: Colors.black,),
                ),
                Container(
                  child: Row(
                    children: [
                      Slider(
                        value: _sliderValue,
                        onChanged: (newValue) {
                          setState(() {
                            if (newValue <= widget.data['durasi']) {
                              _sliderValue = newValue;
                            } else {
                              _sliderValue = widget.data['durasi'];
                            }
                          });
                        },
                        onChangeEnd: (newValue) {
                          _seekTo(newValue);
                        },
                        min: 0.0,
                        max: widget.data['durasi'] / 1,
                      ),
                      Column(
                        children: [
                          // Text("${_formatDuration(_position)}"),
                          // Text("${_formatDuration(Duration(milliseconds: widget.data['durasi']))}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text("${DateFormat("hh:mm").format(DateTime.parse(widget.data['tanggal']))}"),
          ],
        ),
      ),
    );
  }
}
