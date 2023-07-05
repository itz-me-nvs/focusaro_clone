import 'dart:async';
import 'package:location/location.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final bool focus;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.focus,
  });
}

class LocationService {
  // Keep track of current Location
  late UserLocation _currentLocation;
  Location location = Location();
  // Continuously emit location updates
  final StreamController<UserLocation> _locationController =
      StreamController<UserLocation>.broadcast();

  LocationService() {
    location.requestPermission().then((granted) {
      if (granted == PermissionStatus.granted) {
        location.onLocationChanged.listen((locationData) {
          // if(locationData)

          if (locationData.latitude != null && locationData.longitude != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude ?? 0,
              longitude: locationData.longitude ?? 0,
              focus: true,
            ));
          }
        });
      }
    });
  }

  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();

      _currentLocation = UserLocation(
        latitude: userLocation.latitude ?? 0,
        longitude: userLocation.longitude ?? 0,
        focus: true,
      );
    } catch (e) {
      print('Could not get the location: $e');
    }

    return _currentLocation;
  }
}
