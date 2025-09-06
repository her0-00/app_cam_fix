import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:flutter/services.dart';

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
  String _cameraStatus = "⏳ Initialisation...";

  @override
  void initState() {
    super.initState();
    _cameraStatus = "📷 Appuie pour capturer sans stabilisation";
  }

  Future<void> _captureFrameWithoutOIS() async {
    const platform = MethodChannel('raw_camera_plugin');
    try {
      final path = await platform.invokeMethod<String>('captureFrameWithoutOIS');
      if (path != null) {
        final imageFile = File(path);
        final dir = await getApplicationDocumentsDirectory();
        final savedPath = '${dir.path}/frame_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile = await imageFile.copy(savedPath);
        await Gal.putImage(savedFile.path); // Enregistre dans la galerie
        setState(() {
          _capturedImage = savedFile;
          _cameraStatus = "✅ Image enregistrée sans OIS";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📸 Image enregistrée dans la galerie')),
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
      appBar: AppBar(title: Text('CamFix XR — Sans Stabilisation'), backgroundColor: Colors.redAccent),
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
                : Text('Appuie sur le bouton pour capturer une image sans stabilisation',
                    style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _captureFrameWithoutOIS,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
