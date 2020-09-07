import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

String _locationMessage = "";

getLocation() async {
  Position position =
  await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  print('location: ${position.latitude}');
  final coordinates = new Coordinates(position.latitude, position.longitude);
  var addresses =
  await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  _locationMessage = "${first.featureName} : ${first.addressLine}";
  return _locationMessage.substring(0,_locationMessage.length-13);

}