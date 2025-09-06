import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _activateRawMode(); // ⚙️ Mode brut au démarrage
  }

  Future<void> _activateRawMode() async {
    const platform = MethodChannel('camfixxr/camera');
    try {
      await platform.invokeMethod('activateRawMode');
      print('✅ Mode brut activé');
    } catch (e) {
      print('Erreur activation mode brut : $e');
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final dir = await getApplicationDocumentsDirectory();
      final savedPath = '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await imageFile.copy(savedPath);
      await Gal.putImage(savedFile.path);
      setState(() => _capturedImage = savedFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📸 Photo enregistrée dans la galerie')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Aucune photo capturée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('CamFix XR'), backgroundColor: Colors.redAccent),
      body: Center(
        child: _capturedImage != null
            ? Image.file(_capturedImage!)
            : Text('Appuie sur le bouton pour capturer une image',
                style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _takePhoto,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
