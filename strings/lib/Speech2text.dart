import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math';



stt.SpeechToText speech = stt.SpeechToText();
bool isListening = false;
dynamic final_words;
double minSoundLevel = -50000,maxSoundLevel = 50000;

initialize_stt() async{
  print('[DEBUG] Initialized STT');
  bool hasSpeech = await speech.initialize(
      onStatus: (val) => print('STT onStatus: $val'),
      onError: (val) => print('STT onError : $val'),
    );
}


StartListening() async{
  try{
    isListening = true;
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        localeId: "en_IN",
        onSoundLevelChange: soundLevelListener,
        cancelOnError: false,
        partialResults: false,
        onDevice: true,
        listenMode: stt.ListenMode.confirmation
    );

    while(isListening){
      await Future.delayed(Duration(milliseconds: 100));
    }
    return final_words;
  }catch(_) {}

}

resultListener(SpeechRecognitionResult result){
  if(result.finalResult)
    final_words = result.recognizedWords;
    print('[DEBUG] Words in Speech: $final_words');
    isListening = false;
}

soundLevelListener(double level){
  minSoundLevel = min(minSoundLevel,level);
  maxSoundLevel = max(maxSoundLevel,level);

}
