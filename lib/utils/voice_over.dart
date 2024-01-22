import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceOver{
  final FlutterTts flutterTts = FlutterTts();

   Future<void> playVoiceover(String text) async {

    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak(text);
  }
}