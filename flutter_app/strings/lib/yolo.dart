import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

loadmodel() async{
  try{
    String res = await Tflite.loadModel(
      model: "assets/tflite/yolov2_tiny.tflite",
      labels: "assets/tflite/yolov2_tiny.txt",
    );
    print('[DEBUG] Loading Yolo model -> $res');
  } on PlatformException{
    print('[ERROR] : Failed to load Yolo model');
  }
}


yoloTiny(dynamic image_data) async{

  print('[DEBUG] BEFORE YOLO');
  img.Image image;
  image = img.decodeImage(image_data);
  img.Image resizedImage = img.copyResize(image, height: 416, width: 416);
  print('[DEBUG] After copyResize');

  var recognition = await Tflite.detectObjectOnBinary(
    binary: imageToByteListFloat32(resizedImage, 416 , 0 , 255),
    model: "YOLO",
    numResultsPerClass: 1,
    threshold: 0.3,
  );
  print('[DEBUG] AFTER YOLO');
  print('[DEBUG] Detections: $recognition');

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
