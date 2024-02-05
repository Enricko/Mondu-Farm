import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import '../../chat.dart';
import '../color.dart';

class RecordChatWidget extends StatefulWidget {
  const RecordChatWidget(
      {super.key,
      required this.idUser,
      required this.idTernak,
      required this.kategori});

  final String idUser;
  final String idTernak;
  final String kategori;

  @override
  State<RecordChatWidget> createState() => _RecordChatWidgetState();
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
  remoteExampleFile,
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

class _RecordChatWidgetState extends State<RecordChatWidget> {
  bool _isRecording = false;
  bool readySubmit = false;

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

  List<String> assetSample = [
    'assets/samples/sample.aac',
    'assets/samples/sample.aac',
    'assets/samples/sample.opus',
    'assets/samples/sample_opus.caf',
    'assets/samples/sample.mp3',
    'assets/samples/sample.ogg',
    'assets/samples/sample.pcm',
    'assets/samples/sample.wav',
    'assets/samples/sample.aiff',
    'assets/samples/sample_pcm.caf',
    'assets/samples/sample.flac',
    'assets/samples/sample.mp4',
    'assets/samples/sample.amr', // amrNB
    'assets/samples/sample_xxx.amr', // amrWB
    'assets/samples/sample_xxx.pcm', // pcm8
    'assets/samples/sample_xxx.pcm', // pcmFloat32
    '', // 'assets/samples/sample_xxx.pcm', // pcmWebM
    'assets/samples/sample_opus.webm', // opusWebM
    'assets/samples/sample_vorbis.webm', // vorbisWebM
  ];

  List<String> remoteSample = [
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/01.aac',
    // 'assets/samples/sample.aac',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/01.aac',
    // 'assets/samples/sample.aac',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/08.opus',
    // 'assets/samples/sample.opus',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/04-opus.caf',
    // 'assets/samples/sample_opus.caf',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/05.mp3',
    // 'assets/samples/sample.mp3',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/07.ogg',
    // 'assets/samples/sample.ogg',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/10-pcm16.raw',
    // 'assets/samples/sample.pcm',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/13.wav',
    // 'assets/samples/sample.wav',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/02.aiff',
    // 'assets/samples/sample.aiff',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/01-pcm.caf',
    // 'assets/samples/sample_pcm.caf',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/04.flac',
    // 'assets/samples/sample.flac',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/06.mp4',
    // 'assets/samples/sample.mp4',
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/03.amr',
    // 'assets/samples/sample.amr', // amrNB
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/03.amr',
    // 'assets/samples/sample_xxx.amr', // amrWB
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/09-pcm8.raw',
    // 'assets/samples/sample_xxx.pcm', // pcm8
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/12-pcmfloat.raw',
    // 'assets/samples/sample_xxx.pcm', // pcmFloat32
    '',
    // 'assets/samples/sample_xxx.pcm', // pcmWebM
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/02-opus.webm',
    // 'assets/samples/sample_opus.webm', // opusWebM
    'https://flutter-sound.canardoux.xyz/web_example/assets/extract/03-vorbis.webm',
    // 'assets/samples/sample_vorbis.webm', // vorbisWebM
  ];

  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;
  StreamSubscription? _recordingDataSubscription;

  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();

  Duration _recorderDuration = Duration();
  Duration _playerDuration = Duration();
  double? _dbLevel;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  Media? _media = Media.file;
  Codec _codec = Codec.aacMP4;

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

    // if ((!kIsWeb) && Platform.isAndroid) {
    //   await copyAssets();
    // }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
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

  // Future<void> copyAssets() async {
  //   var dataBuffer = (await rootBundle.load('assets/canardo.png')).buffer.asUint8List();
  //   var path = '${await playerModule.getResourcePath()}/assets';
  //   if (!await Directory(path).exists()) {
  //     await Directory(path).create(recursive: true);
  //   }
  //   await File('$path/canardo.png').writeAsBytes(dataBuffer);
  // }

  @override
  void initState() {
    super.initState();
    init();
    // onStartRecorderPressed();
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

  void startRecorder() async {
    try {
      // Request Microphone permission if needed
      if (!kIsWeb) {
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw RecordingPermissionException(
              'Microphone permission not granted');
        }
      }
      var path = '';
      if (!kIsWeb) {
        var tempDir = await getTemporaryDirectory();
        path = '${tempDir.path}/flutter_sound${ext[_codec.index]}';
        print("Path : ${path}");
      } else {
        path = '_flutter_sound${ext[_codec.index]}';
      }

      if (_media == Media.stream) {
        assert(_codec == Codec.pcm16);
        if (!kIsWeb) {
          var outputFile = File(path);
          if (outputFile.existsSync()) {
            await outputFile.delete();
          }
          sink = outputFile.openWrite();
        } else {
          sink = null; // TODO
        }
        recordingDataController = StreamController<Food>();
        _recordingDataSubscription =
            recordingDataController!.stream.listen((buffer) {
          if (buffer is FoodData) {
            sink!.add(buffer.data!);
          }
        });
        await recorderModule.startRecorder(
          toStream: recordingDataController!.sink,
          codec: _codec,
          numChannels: 1,
          sampleRate: tSTREAMSAMPLERATE, //tSAMPLERATE,
        );
      } else {
        await recorderModule.startRecorder(
          toFile: path,
          codec: _codec,
          bitRate: 8000,
          numChannels: 1,
          sampleRate: (_codec == Codec.pcm16) ? tSTREAMSAMPLERATE : tSAMPLERATE,
        );
      }

      recorderModule.logger.d('startRecorder');

      _recorderSubscription = recorderModule.onProgress!.listen((e) {
        setState(() {
          _recorderDuration = e.duration;
          _dbLevel = e.decibels;
        });
      });

      setState(() {
        _isRecording = true;
        readySubmit = false;
        _path[_codec.index] = path;
      });
    } on Exception catch (err) {
      recorderModule.logger.e('startRecorder error: $err');
      setState(() {
        stopRecorder();
        _isRecording = false;
        readySubmit = false;
        cancelRecordingDataSubscription();
        cancelRecorderSubscriptions();
      });
    }
  }

  void stopRecorder() async {
    try {
      await recorderModule.stopRecorder();
      recorderModule.logger.d('stopRecorder');
      cancelRecorderSubscriptions();
      cancelRecordingDataSubscription();
    } on Exception catch (err) {
      recorderModule.logger.d('stopRecorder error: $err');
    }

    setState(() {
      _isRecording = false;
      readySubmit = true;
    });
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
      maxDuration = e.duration.inMilliseconds.toDouble();
      if (maxDuration <= 0) maxDuration = 0.0;

      sliderCurrentPosition =
          min(e.position.inMilliseconds.toDouble(), maxDuration);
      if (sliderCurrentPosition < 0.0) {
        sliderCurrentPosition = 0.0;
      }

      setState(() {
        _playerDuration = e.position;
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

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  /*
  Future<void> feedHim(String path) async {
    var data = await _readFileByte(path);
    return await playerModule.feedFromStream(data);
  }
*/

  final int blockSize = 4096;

  Future<void> feedHim(String path) async {
    var buffer = await _readFileByte(path);
    //var buffer = await getAssetData('assets/samples/sample.pcm');

    var lnData = 0;
    var totalLength = buffer.length;
    while (totalLength > 0 && !playerModule.isStopped) {
      var bsize = totalLength > blockSize ? blockSize : totalLength;
      await playerModule
          .feedFromStream(buffer.sublist(lnData, lnData + bsize)); // await !!!!
      lnData += bsize;
      totalLength -= bsize;
    }
  }

  Future<void> startPlayer() async {
    try {
      Uint8List? dataBuffer;
      String? audioFilePath;
      var codec = _codec;
      if (_media == Media.asset) {
        dataBuffer = (await rootBundle.load(assetSample[codec.index]))
            .buffer
            .asUint8List();
      } else if (_media == Media.file || _media == Media.stream) {
        // Do we want to play from buffer or from file ?
        if (kIsWeb || await fileExists(_path[codec.index]!)) {
          audioFilePath = _path[codec.index];
        }
      } else if (_media == Media.buffer) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(_path[codec.index]!)) {
          dataBuffer = await makeBuffer(_path[codec.index]!);
          if (dataBuffer == null) {
            throw Exception('Unable to create the buffer');
          }
        }
      } else if (_media == Media.remoteExampleFile) {
        // We have to play an example audio file loaded via a URL
        audioFilePath = remoteSample[_codec.index];
      }

      if (_media == Media.stream) {
        await playerModule.startPlayerFromStream(
          codec: Codec.pcm16, //_codec,
          numChannels: 1,
          sampleRate: tSTREAMSAMPLERATE, //tSAMPLERATE,
        );
        _addListeners();
        setState(() {});
        await feedHim(audioFilePath!);
        //await finishPlayer();
        await stopPlayer();
        return;
      } else {
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
        } else if (dataBuffer != null) {
          if (codec == Codec.pcm16) {
            dataBuffer = await flutterSoundHelper.pcmToWaveBuffer(
              inputBuffer: dataBuffer,
              numChannels: 1,
              sampleRate: (_codec == Codec.pcm16 && _media == Media.asset)
                  ? 48000
                  : tSAMPLERATE,
            );
            codec = Codec.pcm16WAV;
          }
          await playerModule.startPlayer(
              fromDataBuffer: dataBuffer,
              sampleRate: tSAMPLERATE,
              codec: codec,
              whenFinished: () {
                playerModule.logger.d('Play finished');
                setState(() {});
              });
        }
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
        await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
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
    return (playerModule.isPlaying || playerModule.isPaused)
        ? stopPlayer
        : null;
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

  void startStopRecorder() {
    if (recorderModule.isRecording || recorderModule.isPaused) {
      stopRecorder();
      onRecorded = false;
      readySubmit = true;
    } else {
      startRecorder();
      onRecorded = true;
    }
  }

  void Function()? onStartRecorderPressed() {
    // Disable the button if the selected codec is not supported
    if (!_encoderSupported!) return null;
    if (_media == Media.stream && _codec != Codec.pcm16) return null;
    return startStopRecorder;
  }

  // AssetImage recorderAssetImage() {
  //   if (onStartRecorderPressed() == null) {
  //     return AssetImage('res/icons/ic_mic_disabled.png');
  //   }
  //   return (recorderModule.isStopped)
  //       ? AssetImage('res/icons/ic_mic.png')
  //       : AssetImage('res/icons/ic_stop.png');
  // }

  Future<void> setCodec(Codec codec) async {
    _encoderSupported = await recorderModule.isEncoderSupported(codec);
    _decoderSupported = await playerModule.isDecoderSupported(codec);

    setState(() {
      _codec = codec;
    });
  }

  void deleteVoice() async {
    recorderModule.stopRecorder();
    playerModule.closePlayer();
    _playerDuration = Duration.zero;
    _recorderDuration = Duration.zero;
    sliderCurrentPosition = 0;
    maxDuration = 1;
    readySubmit = false;
    setState(() {});
  }

  void submitVoiceNote() async {
    EasyLoading.show(status: 'loading...');

    // await recorderModule.getRecordURL(path: _path[_codec.index]!).then((value) async {
    await Chat.InsertChat(
            _path[_codec.index]!,
            _recorderDuration.inMilliseconds,
            widget.idUser,
            widget.idTernak,
            widget.kategori,
            context)
        .whenComplete(() {
      deleteVoice();
      setState(() {});
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? duration.inHours.toString() + ":" : ""}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return FittedBox(
      child: Container(
        alignment: Alignment.center,
        width: width,
        decoration: BoxDecoration(
            color: Colors.black54, borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10))),
        margin: EdgeInsets.only(top: 5),
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed:
                      onStartPlayerPressed() ?? onPauseResumePlayerPressed(),
                  icon: Icon(
                    onPlayed ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                Expanded(
                  // constraints: BoxConstraints(minWidth: 100, maxWidth: 1000),
                  child: Slider(
                    value: min(sliderCurrentPosition, maxDuration),
                    min: 0.0,
                    max: maxDuration,
                    onChanged: (value) async {
                      await seekToPlayer(value.toInt());
                    },
                    divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt(),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${_formatDuration(onPlayed ? _recorderDuration : _playerDuration)}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text(_mRecorder!.isRecording ? 'Recording in progress' : 'Recorder is stopped'),
                IconButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                    !readySubmit ? Warna.secondary.withOpacity(0.5) : Warna.secondary,
                  )),
                  onPressed: !readySubmit
                      ? null
                      : () {
                          deleteVoice();
                        },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Warna.secondary)),
                  onPressed: onStartRecorderPressed(),
                  icon: Icon(
                    !onRecorded ? Icons.mic : Icons.pause,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                IconButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                    !readySubmit
                        ? Warna.secondary.withOpacity(0.5)
                        : Warna.secondary,
                  )),
                  onPressed: !readySubmit
                      ? null
                      : () {
                          submitVoiceNote();
                        },
                  // disabledColor: Colors.black.withOpacity(0.5),
                  icon: Icon(Icons.send,color: Colors.white,),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:just_audio/just_audio.dart';

// class RecordChatWidget extends StatefulWidget {
//   const RecordChatWidget({super.key, required this.idUser});
//   final String idUser;

//   @override
//   State<RecordChatWidget> createState() => _RecordChatWidgetState();
// }

// class _RecordChatWidgetState extends State<RecordChatWidget> {
//   AudioPlayer? audioPlayer;
//   FlutterSoundRecorder? _audioRecorder;
//   bool isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     audioPlayer = AudioPlayer();
//     _audioRecorder = FlutterSoundRecorder();
//     _initAudioRecorder();
//   }

//   Future<void> _initAudioRecorder() async {
//     await _audioRecorder!.openRecorder();
//   }

//   Future<void> _startRecording() async {
//     try {
//       await _audioRecorder!.startRecorder(
//         toFile: 'your_custom_recording_path.aac', // Set your desired path
//         codec: Codec.aacMP4,
//       );
//       setState(() {
//         isRecording = true;
//       });
//     } catch (err) {
//       print('Recording failed: $err');
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       await _audioRecorder!.stopRecorder();
//       setState(() {
//         isRecording = false;
//       });
//       print('Recording saved.');
//     } catch (err) {
//       print('Stop recording failed: $err');
//     }
//   }

//    Future<void> _playRecording() async {
//     try {
//       await audioPlayer!.setFilePath('your_custom_recording_path.aac'); // Set the recorded file path
//       await audioPlayer!.play();
//     } catch (err) {
//       print('Playback failed: $err');
//     }
//   }

//   @override
//   void dispose() {
//     audioPlayer!.dispose();
//     _audioRecorder!.closeRecorder();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio Recorder'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (isRecording) Text('Recording in progress...'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isRecording ? null : _startRecording,
//               child: Text('Start Recording'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isRecording ? _stopRecording : null,
//               child: Text('Stop Recording'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _playRecording,
//               child: Text('Play Recorded Audio'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
