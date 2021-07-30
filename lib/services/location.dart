// TODO Implement this library.
import 'package:geolocator/geolocator.dart';

class Location {
  double latitude;
  double longitude;

  Future<Position> getLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
        .then((position) =>
            {latitude = position.latitude, longitude = position.longitude});
  }
}
