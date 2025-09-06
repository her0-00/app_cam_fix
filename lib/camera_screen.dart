import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedRawImage;
  String _cameraStatus = "⏳ Mode RAW en attente...";

  @override
  void initState() {
    super.initState();
    _cameraStatus = "📷 Appuie pour capturer en RAW";
  }

  Future<void> _captureRawPhoto() async {
    const platform = MethodChannel('raw_camera_plugin');
    try {
      final path = await platform.invokeMethod<String>('captureRawPhoto');
      if (path != null) {
        final rawFile = File(path);
        final dir = await getApplicationDocumentsDirectory();
        final savedPath = '${dir.path}/photo_raw_${DateTime.now().millisecondsSinceEpoch}.dng';
        final savedFile = await rawFile.copy(savedPath);
        await Gal.putImage(savedFile.path); // Enregistre dans la galerie
        setState(() {
          _capturedRawImage = savedFile;
          _cameraStatus = "✅ Photo RAW enregistrée";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📸 Photo RAW enregistrée dans la galerie')),
        );
      } else {
        setState(() => _cameraStatus = "⚠️ Aucun fichier reçu");
      }
    } catch (e) {
      setState(() => _cameraStatus = "❌ Erreur RAW");
      print('Erreur RAW : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur lors de la capture RAW')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('CamFix XR — RAW Mode'), backgroundColor: Colors.redAccent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_cameraStatus, style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
            SizedBox(height: 20),
            _capturedRawImage != null
                ? Text('📂 Fichier RAW : ${_capturedRawImage!.path}',
                    style: TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center)
                : Text('Appuie sur le bouton pour capturer une image RAW',
                    style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _captureRawPhoto,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
