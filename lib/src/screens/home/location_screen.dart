import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focusaro_clone/src/utils/services/location_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class LocationScreen extends StatefulWidget {
  static const String id = 'location_screen';
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _soundMode = 'Unknown';
  String _permissionStatus = 'Unknown';

  // google maps configs
  static bool switchValue = false;
  final Location _locationTracker = Location();
  final _firestore = FirebaseFirestore.instance;
  Set<Marker> _markers = {};

  Circle circle = const Circle(
    circleId: CircleId('home'),
    radius: 12,
    fillColor: Colors.blueAccent,
    strokeColor: Colors.blueAccent,
  );

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(27.7089427, 85.3086209),
    zoom: 14.4746,
  );

  LatLng? _selectedLocation;
  @override
  void initState() {
    super.initState();

    _markers.add(
      Marker(
        markerId: const MarkerId('home'),
        position: LatLng(37.4219999, -122.0840575),
        infoWindow: const InfoWindow(title: 'Home'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    getCurrentSoundMode();
    getPermissionStatus();
  }

  void _addMarker(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('marker_1'),
          position: location,
        ),
      );
    });
  }

  void _saveLocation() {
    if (_selectedLocation != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to save this location?'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  _firestore
                      .collection('user')
                      .doc('mINhLg007Rc964sto22qNgibQJ92')
                      .update({
                    'targetLocations': [
                      {
                        'latitude': _selectedLocation!.latitude,
                        'longitude': _selectedLocation!.longitude,
                      }
                    ]
                  });
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location saved to Firestore')),
                  );
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No location selected')),
      );
    }
  }

  Future<void> getPermissionStatus() async {
    bool? permissionStatus = false;
    try {
      permissionStatus = await PermissionHandler.permissionsGranted;
      print(permissionStatus);
    } catch (err) {
      print(err);
    }

    setState(() {
      _permissionStatus =
          permissionStatus! ? "Permissions Enabled" : "Permissions not granted";
    });
  }

  Future<void> getCurrentSoundMode() async {
    String? ringerStatus;
    try {
      ringerStatus = (await SoundMode.ringerModeStatus) as String?;

      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 1), () async {
          ringerStatus = (await SoundMode.ringerModeStatus) as String?;
        });
      }
    } catch (err) {
      ringerStatus = 'Failed to get device\'s ringer status.$err';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    if (!mounted) return;

    setState(() {
      _soundMode = ringerStatus!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userInfo =
        ModalRoute.of(context)?.settings.arguments as dynamic ?? '';
    return StreamProvider<UserLocation>(
      create: (context) => LocationService().locationStream,
      initialData: UserLocation(latitude: 0.0, longitude: 0.0, focus: true),
      child: Scaffold(
        backgroundColor: switchValue ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          brightness: Brightness.dark,
          elevation: 8,
          title: const Padding(
            padding: EdgeInsets.only(
              right: 0.0,
              top: 0.0,
              left: 0.0,
            ),
            child: Text(
              'Focus Map',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
          actions: <Widget>[
            Switch(
              value: switchValue,
              activeColor: Colors.teal[700],
              onChanged: (value) {
                setState(() {
                  // print(value);
                  switchValue = value;
                  if (switchValue) {
                    _firestore
                        .collection('user')
                        .doc('mINhLg007Rc964sto22qNgibQJ92')
                        .update({
                      'focusMode': true,
                    });
                  } else {
                    _firestore
                        .collection('user')
                        .doc('mINhLg007Rc964sto22qNgibQJ92')
                        .update({
                      'focusMode': false,
                    });
                  }
                });
              },
            ),
            IconButton(
                icon: const Icon(Icons.settings, size: 30.0),
                onPressed: () =>
                    {Navigator.of(context).pushNamed('settings_screen')}),
          ],
        ),
        body: GoogleMap(
          markers: _markers,
          initialCameraPosition: initialLocation,
          onTap: _addMarker,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // You can customize the map using the controller
          },
        ),
        floatingActionButton: _selectedLocation != null
            ? FloatingActionButton(
                child: const Icon(Icons.save),
                onPressed: () {
                  _saveLocation();
                })
            : null,
      ),
    );
  }

  Future<void> setSilentMode() async {
    String message;

    try {
      message =
          (await SoundMode.setSoundMode(RingerModeStatus.silent)) as String;

      setState(() {
        _soundMode = message;
      });
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
  }

  Future<void> setNormalMode() async {
    String message;

    try {
      message = await SoundMode.setSoundMode(RingerModeStatus.normal) as String;
      setState(() {
        _soundMode = message;
      });
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
  }

  Future<void> setVibrateMode() async {
    String message;

    try {
      message =
          await SoundMode.setSoundMode(RingerModeStatus.vibrate) as String;

      setState(() {
        _soundMode = message;
      });
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
  }

  Future<void> openDoNotDisturbSettings() async {
    await PermissionHandler.openDoNotDisturbSetting();
  }
}
