
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'yolo.dart';
import 'Text2Speech.dart';
import 'Speech2text.dart';
import 'WitAi.dart';
import 'location.dart';

bool busy = false;
void main() {
  runApp(MaterialApp(
    home:Home(),
  ));
}

urlToImgData(String imageUrl) async {
  http.Response response = await http.get(imageUrl)
      .timeout(Duration(milliseconds: 10000),
    onTimeout: () {
      busy = false;
      print('[EXCEPTION] Touch HTTP TimeOut');
      return null;
    } ,
  );
  return response.bodyBytes;
}


class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final URLController = TextEditingController();
  String img_url = 'https://static.dezeen.com/uploads/2020/06/priestmangoode-neptune-spaceship-design_dezeen_2364_hero-2-1024x576.jpg';
  Image img ;
  var objects = new List();
  String Results_text = ' ';

  @override
  void initState() {
    super.initState();
    img = Image(image: NetworkImage(img_url) );
    loadmodel();
    initialize_stt();
    Timer.periodic(new Duration(milliseconds: 2000), (timer) async{ await checkTouchSensor();});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Primary Model'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),

    // REFRESH Button
    floatingActionButton: FloatingActionButton(
      onPressed: () async{
        busy = true;
        await doProcess();
        busy = false;
      },

      child: Icon(Icons.mic),
      backgroundColor: Colors.red,
    ),

    body: Padding(
      padding: EdgeInsets.all(10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // URL INPUT BOX
          TextField(
            controller: URLController,
            autofocus: false,

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: img_url,
            ),
          ),

          SizedBox(height: 20),

          //DISPLAY IMAGE
          img,

          SizedBox(height: 10),
          Text(
            'Results: ',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            Results_text,
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    ),
    );
  }

  checkTouchSensor() async{
    if(busy == false)
      {
        busy = true;
        try{
          http.Response response = await http.get('http://192.168.43.7/touched')
              .timeout(Duration(milliseconds: 5000),
            onTimeout: () {
                busy = false;
                print('[EXCEPTION] Touch HTTP TimeOut');
                return null;
            } ,
          );
          dynamic isTouched = utf8.decode(response.bodyBytes) ;
          print('[DEBUG] Recived from /touched: $isTouched');
          if( isTouched == 'YES' ){
            busy = true;
            await doProcess();
            busy = false;
          }     // IF ENDS
        } catch(_){print(_);}
      busy = false;
      }
  }

  doProcess() async{
    busy = true;
    Results_text = ' ';
    img_url = URLController.text;


    isListening = true;
    dynamic words = await StartListening();
    print('[DEBUG] Recived from StartListening : $words');

    String intent = await getIntents(words);
    print('[DEBUG] Intent Recived : $intent');

    // YOLO
    if( intent == 'detect_objects'){
      print('[DEBUG] Entered YOLO');
      while(true){
        try{
          print('[DEBUG] Entered URL : $img_url');
          dynamic img_data = await urlToImgData(img_url);

          img = Image.memory(img_data);

          dynamic results = await yoloTiny(img_data);
          objects = new List();

          for( int i =0 ; i < results.length ; i++) {
            objects.add(results[i]['detectedClass']);
          }
          print('[DEBUG] Objects: $objects');
          Results_text = objects.toString();
          ReadOut('Detected:' + Results_text);
          break;
        }catch(e){
          print('[ERROR] in YOLO DETECT Trying again');
          print('[ERROR] : $e');
        }
      }       // WHILE LOOP ENDS
    }

    if(intent == 'location'){
      dynamic location = await getLocation();
      print( location);
      ReadOut('Right now , you are at :' + location);

    }

    setState(() {busy = false;});
    speech.stop();
    busy = false;
  }

}



