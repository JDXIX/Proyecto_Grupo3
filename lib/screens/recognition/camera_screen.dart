import 'package:proyectog3/screens/recognition/recognition_home.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {});
        })
        .catchError((e) {
          debugPrint('Camera init error: $e');
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _takePictureAndRecognize() async {
    if (!_controller.value.isInitialized || _controller.value.isTakingPicture) {
      return;
    }

    try {
      setState(() => _isProcessing = true);
      final pic = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(pic.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      if (!mounted) return;
      Navigator.of(context).pop(RecognizeResult(pic.path, recognizedText.text));
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al capturar la imagen: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cámara en Vivo')),
      body: Stack(
        children: [
          CameraPreview(_controller),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _isProcessing ? null : _takePictureAndRecognize,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
