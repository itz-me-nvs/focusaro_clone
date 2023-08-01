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
  late UserLocation _currentLocation;
  Location location = Location();

  final StreamController<UserLocation> _locationController =
      StreamController<UserLocation>.broadcast();

  LocationService() {
    location.requestPermission().then((granted) {
      if (granted == PermissionStatus.granted) {
        location.onLocationChanged.listen((locationData) {
          if (locationData.latitude != null && locationData.longitude != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude!,
              longitude: locationData.longitude!,
              focus: true,
            ));
          }
        });
      }
    });
  }

  Stream<UserLocation> get locationStream => _locationController.stream;
}
