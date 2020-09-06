
import 'package:wit_ai/wit_ai.dart';


String _intentFromWit = "";
double _confidenceFromWit = 0;





getIntents(String msg) async {
  final wit = Wit(accessToken: 'JWXVHPNZVJ5E74DDT5CTETVJ2SVV2F4V');
  dynamic response = await wit.message(msg);
  if (response == null)
    print("no data recives");
  else {
    _confidenceFromWit = response['intents'][0]['confidence'];
    _intentFromWit = response['intents'][0]['name'];
  }
  return _intentFromWit;
}