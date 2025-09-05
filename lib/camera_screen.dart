import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  double magneticStrength = 0.0;
  List<double> magneticHistory = [];
  bool showFlash = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initCamera();
    });

    initMagnetometer();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      print('Erreur caméra : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’accès à la caméra')),
      );
    }
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
        final strength = sqrt(x * x + y * y + z * z);

        magneticHistory.add(strength);
        if (magneticHistory.length > 10) {
          magneticHistory.removeAt(0);
        }

        final average = magneticHistory.reduce((a, b) => a + b) / magneticHistory.length;

        setState(() {
          magneticStrength = average;
        });
      });
    }
  }

  bool isMagneticStable() {
    if (magneticHistory.length < 10) return false;
    return magneticHistory.every((v) => (v - magneticStrength).abs() < 2);
  }

  void triggerFlash() {
    setState(() => showFlash = true);
    Future.delayed(Duration(milliseconds: 150), () {
      setState(() => showFlash = false);
    });
  }

  Future<void> capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _controller!.value.isTakingPicture) return;

    if (!isMagneticStable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Champ magnétique instable 📡')),
      );
      return;
    }

    try {
      triggerFlash();
      final image = await _controller!.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedPath = '${dir.path}/photo_$timestamp.jpg';
      await File(image.path).copy(savedPath);

      // ✅ Enregistrement dans la galerie iOS
      await Gal.putImage(savedPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📸 Photo enregistrée dans la galerie')),
      );
    } catch (e) {
      print('Erreur capture : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la capture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          (_controller != null && _controller!.value.isInitialized)
              ? CameraPreview(_controller!)
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
                if (!isMagneticStable())
                  Text(
                    "⚠️ Instabilité magnétique détectée",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
