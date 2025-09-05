import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:path_provider/path_provider.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  double magneticStrength = 0.0;
  bool showFlash = false;

  @override
  void initState() {
    super.initState();
    initCamera();
    initMagnetometer();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    setState(() {});
  }

  void initMagnetometer() async {
    final sensorManager = SensorManager();
    final isAvailable = await sensorManager.isSensorAvailable(Sensors.MAGNETIC_FIELD);

    if (isAvailable) {
      final stream = await sensorManager.sensorUpdates(
        sensorId: Sensors.MAGNETIC_FIELD,
        interval: Duration(milliseconds: 500),
      );

      stream.listen((event) {
        final x = event.data[0];
        final y = event.data[1];
        final z = event.data[2];
        setState(() {
          magneticStrength = sqrt(x * x + y * y + z * z);
        });
      });
    }
  }

  void triggerFlash() {
    setState(() => showFlash = true);
    Future.delayed(Duration(milliseconds: 150), () {
      setState(() => showFlash = false);
    });
  }

  Future<void> capturePhoto() async {
    if (!_controller.value.isInitialized) return;
    triggerFlash();
    final image = await _controller.takePicture();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await File(image.path).copy('${dir.path}/photo_$timestamp.jpg');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📸 Photo enregistrée')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? CameraPreview(_controller)
              : Center(child: CircularProgressIndicator()),

          if (showFlash)
            Container(color: Colors.white.withOpacity(0.8)),

          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: FloatingActionButton(
              backgroundColor: Colors.redAccent,
              onPressed: capturePhoto,
              child: Icon(Icons.camera),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.photo_library, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryScreen()),
                );
              },
            ),
          ),

          Positioned(
            bottom: 100,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Champ magnétique : ${magneticStrength.toStringAsFixed(2)} µT",
                  style: TextStyle(color: Colors.white),
                ),
                if (magneticStrength > 100)
                  Text(
                    "⚠️ Aimant détecté ! Risque de flou.",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
