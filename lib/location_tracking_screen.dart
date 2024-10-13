import 'package:flutter/material.dart';
import 'package:geolocator_track/service/tracing_services.dart';

class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  late LocationTracker locationTracker; // Declare LocationTracker
  late WaitTimer waitTimer;
  bool isWaiting = false;
  bool isTracking = false;
  double currentSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    waitTimer = WaitTimer(() {
      setState(() {});
    });

    // Initialize LocationTracker with context
    locationTracker = LocationTracker((double speed) {
      setState(() {
        currentSpeed = speed;
      });
      if (isWaiting && speed > 30.0) {
        stopWait();
      }
    }, context); // Pass context here
  }

  void startTracking() async {
    try {
      await locationTracker.startTracking();
      setState(() {
        isTracking = true;
      });
    } catch (e) {
      // Handle exceptions (like service disabled or permissions denied)
      _showErrorDialog(e.toString());
    }
  }

  void stopTracking() {
    locationTracker.stopTracking();
    setState(() {
      isTracking = false;
    });
  }

  void startWait() {
    waitTimer.startWait();
    setState(() {
      isWaiting = true;
    });
  }

  void stopWait() {
    waitTimer.stopWait();
    setState(() {
      isWaiting = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 300,
              decoration: BoxDecoration(
                color: const Color(0xffF4F6F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Distance Traveled',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '${locationTracker.totalDistance.toStringAsFixed(2)} km',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 120,
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F6F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Wait Time',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          waitTimer.formatWaitTime(),
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 120,
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F6F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Current Speed',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '${currentSpeed.toStringAsFixed(2)} km/h',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: isWaiting ? stopWait : startWait,
                  child: Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xff33363F),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        isWaiting ? 'Resume' : 'Wait',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: isTracking ? stopTracking : startTracking,
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xff5D60EF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        isTracking ? 'Stop Tracking' : 'Start Tracking',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
