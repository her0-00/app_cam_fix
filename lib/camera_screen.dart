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
    _configureIOSCamera(); // 🔧 Appel natif iOS
  }

  Future<void> _configureIOSCamera() async {
    const platform = MethodChannel('camfixxr/camera');
    try {
      await platform.invokeMethod('configureCamera');
    } catch (e) {
      print('Erreur configuration iOS : $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final savedPath = '${dir.path}/photo_$timestamp.jpg';
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
    } catch (e) {
      print('Erreur lors de la capture : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur pendant la capture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _capturedImage != null
            ? Image.file(_capturedImage!)
            : Text(
                'Appuie sur le bouton pour capturer une image',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _takePhoto,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
