import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

load_currency_model() async{
  try{
    String res = await Tflite.loadModel(
      model: "assets/tflite/currency.tflite",
      labels: "assets/tflite/currency_labels.txt",
    );
    print('[DEBUG] Loading Currency model -> $res');
  } on PlatformException{
    print('[ERROR] : Failed to load Currency model');
  }
}


currencyDetect(dynamic img_path) async{

  print('[DEBUG] BEFORE Currency Model');
  var recognition = await Tflite.runModelOnImage(path: img_path);

  print('[DEBUG] Currency Detections: $recognition');

  return recognition;
}

Uint8List imageToByteListFloat32(
    img.Image image, int inputSize, double mean, double std) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
      buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
    }
  }
  return convertedBytes.buffer.asUint8List();
}
