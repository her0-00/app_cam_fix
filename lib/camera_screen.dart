import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:raw_camera_plugin/raw_camera_plugin.dart';

void main() => runApp(CamFixXRApp());

class CamFixXRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CamFix XR',
      theme: ThemeData.dark(),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;
  String _cameraStatus = "🔄 Préparation du capteur…";
  bool _isSensorReady = false;

  @override
  void initState() {
    super.initState();
    RawCameraPlugin.setSensorReadyHandler(() {
      setState(() {
        _isSensorReady = true;
        _cameraStatus = "📷 Capteur prêt — tu peux capturer";
      });
    });
    RawCameraPlugin.captureHighQualityPhoto(); // Lance la préparation
  }

  Future<void> _captureHighQualityPhoto() async {
    try {
      final path = await RawCameraPlugin.captureHighQualityPhoto();
      if (path != null) {
        final imageFile = File(path);
        final dir = await getApplicationDocumentsDirectory();
        final savedPath = '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile = await imageFile.copy(savedPath);
        await Gal.putImage(savedFile.path);
        setState(() {
          _capturedImage = savedFile;
          _cameraStatus = "✅ Photo enregistrée";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📸 Photo enregistrée dans la galerie')),
        );
      } else {
        setState(() => _cameraStatus = "⚠️ Aucun fichier reçu");
      }
    } catch (e) {
      setState(() => _cameraStatus = "❌ Erreur lors de la capture");
      print('Erreur : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur lors de la capture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('CamFix XR — Haute Qualité'), backgroundColor: Colors.redAccent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_cameraStatus, style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
            SizedBox(height: 20),
            _capturedImage != null
                ? Column(
                    children: [
                      Image.file(_capturedImage!, height: 200),
                      SizedBox(height: 10),
                      Text('📂 Fichier : ${_capturedImage!.path}',
                          style: TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
                    ],
                  )
                : Text('Appuie sur le bouton une fois le capteur prêt',
                    style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isSensorReady ? Colors.redAccent : Colors.grey,
        onPressed: _isSensorReady ? _captureHighQualityPhoto : null,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
