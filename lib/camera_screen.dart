import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        // 📁 Sauvegarde locale
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final savedPath = '${dir.path}/photo_$timestamp.jpg';
        await imageFile.copy(savedPath);

        // 🖼️ Enregistrement dans la galerie iOS
        await Gal.putImage(savedPath);

        setState(() {
          _capturedImage = File(savedPath);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📸 Photo enregistrée dans la galerie')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucune photo capturée')),
        );
      }
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.redAccent,
            onPressed: _takePhoto,
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            backgroundColor: Colors.blueGrey,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryScreen()),
              );
            },
            child: Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
