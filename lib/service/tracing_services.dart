import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationTracker {
  Position? lastPosition;
  double totalDistance = 0.0;
  double currentSpeed = 0.0;
  StreamSubscription<Position>? positionStream;

  Function speedUpdate;
  BuildContext context; 

  LocationTracker(this.speedUpdate, this.context);

  Future<void> startTracking() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return; 
    }


    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissions denied.');
      }
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (lastPosition != null) {
        totalDistance += Geolocator.distanceBetween(
                lastPosition!.latitude,
                lastPosition!.longitude,
                position.latitude,
                position.longitude) /
            1000;

        currentSpeed = position.speed * 3.6;
        speedUpdate(currentSpeed);
      }
      lastPosition = position;
    });
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Please turn on the location'),
          actions: <Widget>[
            TextButton(
              child: const Text('Settings'),
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void stopTracking() {
    positionStream?.cancel();
  }
}

class WaitTimer {
  Duration totalWaitTime = Duration.zero;
  Timer? timer;
  Function updateUI;

  WaitTimer(this.updateUI);

  void startWait() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      totalWaitTime += const Duration(seconds: 1);
      updateUI();
    });
  }

  void stopWait() {
    timer?.cancel();
  }

  String formatWaitTime() {
    return "${totalWaitTime.inHours}:${totalWaitTime.inMinutes % 60}:${totalWaitTime.inSeconds % 60}";
  }
}
