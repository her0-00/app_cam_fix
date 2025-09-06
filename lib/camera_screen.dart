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
  int _selectedFPS = 30;
  bool _isStabilized = true;

  @override
  void initState() {
    super.initState();
    _setCameraFPS(_selectedFPS);
    _setStabilization(_isStabilized);
  }

  Future<void> _setCameraFPS(int fps) async {
    const platform = MethodChannel('camfixxr/camera');
    try {
      await platform.invokeMethod('setFPS', {'fps': fps});
      print('✅ FPS réglé sur $fps');
    } catch (e) {
      print('Erreur configuration FPS : $e');
    }
  }

  Future<void> _setStabilization(bool enabled) async {
    const platform = MethodChannel('camfixxr/camera');
    try {
      await platform.invokeMethod('setStabilization', {'enabled': enabled});
      setState(() => _isStabilized = enabled);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(enabled ? '🎯 Stabilisation activée' : '🚫 Stabilisation désactivée')),
      );
    } catch (e) {
      print('Erreur stabilisation : $e');
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
      appBar: AppBar(
        title: Text('CamFix XR'),
        backgroundColor: Colors.redAccent,
        actions: [
          DropdownButton<int>(
            value: _selectedFPS,
            dropdownColor: Colors.black,
            iconEnabledColor: Colors.white,
            items:  [15, 30, 60,90,140,180,200,240,280].map((fps) {
              return DropdownMenuItem(
                value: fps,
                child: Text('$fps FPS', style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (fps) {
              if (fps != null) {
                setState(() => _selectedFPS = fps);
                _setCameraFPS(fps);
              }
            },
          ),
          Switch(
            value: _isStabilized,
            onChanged: (value) => _setStabilization(value),
            activeColor: Colors.greenAccent,
          ),
        ],
      ),
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
