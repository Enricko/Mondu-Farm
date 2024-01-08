import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../color.dart';

class AudioChatWidget extends StatefulWidget {
  const AudioChatWidget({super.key, required this.data, required this.maxDurasi});
  final Map<dynamic, dynamic> data;
  final double maxDurasi;

  @override
  State<AudioChatWidget> createState() => _AudioChatWidgetState();
}

typedef _Fn = void Function();

const theSource = AudioSource.microphone;
const int tSAMPLERATE = 8000;

/// Sample rate used for Streams
const int tSTREAMSAMPLERATE = 44000; // 44100 does not work for recorder on iOS

///
const int tBLOCKSIZE = 4096;

///
enum Media {
  ///
  file,

  ///
  buffer,

  ///
  asset,

  ///
  stream,

  ///
  urlFile,
}

///
enum AudioState {
  ///
  isPlaying,

  ///
  isPaused,

  ///
  isStopped,

  ///
  isRecording,

  ///
  isRecordingPaused,
}

class _AudioChatWidgetState extends State<AudioChatWidget> {
  bool _isRecording = false;
  final List<String?> _path = [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  ];

  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;
  StreamSubscription? _recordingDataSubscription;

  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();

  String _playerTxt = '00:00:00';

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  Media? _media = Media.urlFile;
  Codec _codec = Codec.mp3;

  bool? _encoderSupported = true; // Optimist
  bool _decoderSupported = true; // Optimist
  bool onRecorded = false;
  bool onPlayed = true;

  StreamController<Food>? recordingDataController;
  IOSink? sink;

  Future<void> _initializeExample() async {
    await playerModule.closePlayer();
    await playerModule.openPlayer();
    await playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
    await recorderModule.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
    await setCodec(_codec);
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await recorderModule.openRecorder();

    if (!await recorderModule.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
    }
  }

  Future<void> init() async {
    await openTheRecorder();
    await _initializeExample();

    if ((!kIsWeb) && Platform.isAndroid) {
      await copyAssets();
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<void> copyAssets() async {
    var dataBuffer = (await rootBundle.load('assets/canardo.png')).buffer.asUint8List();
    var path = '${await playerModule.getResourcePath()}/assets';
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
    await File('$path/canardo.png').writeAsBytes(dataBuffer);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      maxDuration = widget.maxDurasi;
    });
    init();
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
  }

  void cancelRecordingDataSubscription() {
    if (_recordingDataSubscription != null) {
      _recordingDataSubscription!.cancel();
      _recordingDataSubscription = null;
    }
    recordingDataController = null;
    if (sink != null) {
      sink!.close();
      sink = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
    cancelRecorderSubscriptions();
    cancelRecordingDataSubscription();
    releaseFlauto();
  }

  Future<void> releaseFlauto() async {
    try {
      await playerModule.closePlayer();
      await recorderModule.closeRecorder();
    } on Exception {
      playerModule.logger.e('Released unsuccessful');
    }
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
  Future<Uint8List?> makeBuffer(String path) async {
    try {
      if (!await fileExists(path)) return null;
      var file = File(path);
      file.openRead();
      var contents = await file.readAsBytes();
      playerModule.logger.i('The file is ${contents.length} bytes long.');
      return contents;
    } on Exception catch (e) {
      playerModule.logger.e(e);
      return null;
    }
  }

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = playerModule.onProgress!.listen((e) {
      // maxDuration = e.duration.inMilliseconds.toDouble();
      // if (maxDuration <= 0) maxDuration = 0.0;

      sliderCurrentPosition = min(e.position.inMilliseconds.toDouble(), maxDuration);
      if (sliderCurrentPosition < 0.0) {
        sliderCurrentPosition = 0.0;
      }

      var date = DateTime.fromMillisecondsSinceEpoch(e.position.inMilliseconds, isUtc: true);
      var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      var dateMax = DateTime.fromMillisecondsSinceEpoch(maxDuration.toInt(), isUtc: true);
      var txtMax = DateFormat('mm:ss:SS', 'en_GB').format(dateMax);
      setState(() {
        _playerTxt = txt.substring(0, 8);
      });
    });
  }

  Future<Uint8List> _readFileByte(String filePath) async {
    var myUri = Uri.parse(filePath);
    var audioFile = File.fromUri(myUri);
    Uint8List bytes;
    var b = await audioFile.readAsBytes();
    bytes = Uint8List.fromList(b);
    playerModule.logger.d('reading of bytes is completed');
    return bytes;
  }

  final int blockSize = 1;
  Future<void> feedHim(String path) async {
    var buffer = await _readFileByte(path);
    //var buffer = await getAssetData('assets/samples/sample.pcm');

    var lnData = 0;
    var totalLength = buffer.length;
    while (totalLength > 0 && !playerModule.isStopped) {
      var bsize = totalLength > blockSize ? blockSize : totalLength;
      await playerModule.feedFromStream(buffer.sublist(lnData, lnData + bsize)); // await !!!!
      lnData += bsize;
      totalLength -= bsize;
    }
  }

  Future<void> startPlayer() async {
    try {
      String? audioFilePath;
      var codec = _codec;
      if (_media == Media.urlFile) {
        // We have to play an example audio file loaded via a URL
        audioFilePath = widget.data['pesan'];
      }

      if (audioFilePath != null) {
        await playerModule.startPlayer(
            fromURI: audioFilePath,
            codec: codec,
            sampleRate: tSTREAMSAMPLERATE,
            whenFinished: () {
              playerModule.logger.d('Play finished');

              setState(() {
                onPlayed = true;
              });
            });
      }
      _addListeners();
      setState(() {
        onPlayed = false;
      });
      playerModule.logger.d('<--- startPlayer');
    } on Exception catch (err) {
      playerModule.logger.e('error: $err');
    }
  }

  Future<void> stopPlayer() async {
    try {
      await playerModule.stopPlayer();
      playerModule.logger.d('stopPlayer');
      if (_playerSubscription != null) {
        await _playerSubscription!.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
    } on Exception catch (err) {
      playerModule.logger.d('error: $err');
    }
    setState(() {
      onPlayed = true;
    });
  }

  void pauseResumePlayer() async {
    try {
      if (playerModule.isPlaying) {
        await playerModule.pausePlayer();
        onPlayed = true;
      } else {
        await playerModule.resumePlayer();
        onPlayed = false;
      }
    } on Exception catch (err) {
      playerModule.logger.e('error: $err');
    }
    setState(() {});
  }

  void pauseResumeRecorder() async {
    try {
      if (recorderModule.isPaused) {
        await recorderModule.resumeRecorder();
      } else {
        await recorderModule.pauseRecorder();
        assert(recorderModule.isPaused);
      }
    } on Exception catch (err) {
      recorderModule.logger.e('error: $err');
    }
    setState(() {});
  }

  Future<void> seekToPlayer(int milliSecs) async {
    //playerModule.logger.d('-->seekToPlayer');
    try {
      if (playerModule.isPlaying) {
        await playerModule.seekToPlayer(Duration(milliseconds: milliSecs.toInt()));
      }
    } on Exception catch (err) {
      playerModule.logger.e('error: $err');
    }
    setState(() {});
    //playerModule.logger.d('<--seekToPlayer');
  }

  void Function()? onPauseResumePlayerPressed() {
    if (playerModule.isPaused || playerModule.isPlaying) {
      return pauseResumePlayer;
    }
    return null;
  }

  void Function()? onPauseResumeRecorderPressed() {
    if (recorderModule.isPaused || recorderModule.isRecording) {
      return pauseResumeRecorder;
    }
    return null;
  }

  void Function()? onStopPlayerPressed() {
    return (playerModule.isPlaying || playerModule.isPaused) ? stopPlayer : null;
  }

  void Function()? onStartPlayerPressed() {
    if (_media == Media.buffer && kIsWeb) {
      return null;
    }
    if (_media == Media.file ||
        _media == Media.stream ||
        _media == Media.buffer) // A file must be already recorded to play it
    {
      if (_path[_codec.index] == null) return null;
    }

    if (_media == Media.stream && _codec != Codec.pcm16) {
      return null;
    }

    // Disable the button if the selected codec is not supported
    if (!(_decoderSupported || _codec == Codec.pcm16)) {
      return null;
    }

    return (playerModule.isStopped) ? startPlayer : null;
  }

  Future<void> setCodec(Codec codec) async {
    _encoderSupported = await recorderModule.isEncoderSupported(codec);
    _decoderSupported = await playerModule.isDecoderSupported(codec);

    setState(() {
      _codec = codec;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Warna.ungu,
      shape: RoundedRectangleBorder(
        borderRadius: widget.data['pesan_dari'] == "admin"
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
                  onPressed: onStartPlayerPressed() ?? onPauseResumePlayerPressed(),
                  icon: Icon(onPlayed ? Icons.play_arrow : Icons.pause),
                ),
                Container(
                  child: Row(
                    children: [
                      Slider(
                        value: min(sliderCurrentPosition, maxDuration),
                        min: 0.0,
                        max: maxDuration,
                        onChanged: (value) async {
                          await seekToPlayer(value.toInt());
                        },
                        divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt(),
                      ),
                      Column(
                        children: [
                          Text("$_playerTxt"),
                          Text("${widget.data['durasi'].toString()}"),
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
