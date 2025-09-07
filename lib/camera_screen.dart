import 'dart:io';
import 'package:flutter/material.dart';
import 'package:raw_camera_plugin/raw_camera_plugin.dart';
import 'package:gal/gal.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;
  String _status = "🎥 Prévisualisation en cours...";

  @override
  void initState() {
    super.initState();
    RawCameraPlugin.setRawPhotoCapturedHandler((path) async {
      final file = File(path);
      await Gal.putImage(path);
      setState(() {
        _capturedImage = file;
        _status = "✅ Frame capturée et enregistrée";
      });
    });
  }

  Future<void> _captureRawPhoto() async {
    setState(() => _status = "📸 Capture en cours...");
    await RawCameraPlugin.captureRawPhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CamFix XR — Capture RAW'),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          const Expanded(child: RawCameraPreview()),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_status, style: const TextStyle(color: Colors.greenAccent)),
          ),
          if (_capturedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_capturedImage!, height: 200),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              onPressed: _captureRawPhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capturer cette frame"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
