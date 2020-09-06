import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts flutterTts = FlutterTts();

ReadOut( String msg ) async{
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1);

  await flutterTts.speak(msg);
}