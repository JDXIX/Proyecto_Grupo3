import 'dart:io';

import 'package:proyectog3/screens/recognition/camera_screen.dart';
import 'package:proyectog3/screens/recognition/settings.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// `Result from text recognition model, including image path and recognized text.`
class RecognizeResult {
  final String imagePath;
  final String text;
  RecognizeResult(this.imagePath, this.text);
}

class RecognitionHomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const RecognitionHomeScreen({super.key, required this.cameras});

  @override
  State<RecognitionHomeScreen> createState() => _RecognitionHomeScreenState();
}

class _RecognitionHomeScreenState extends State<RecognitionHomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  String _recognizedText = '';
  XFile? _imageFile;
  bool _isProcessing = false;
  File? selectedImage;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  /// `Request permission for camera or gallery access.`
  Future<bool> _requestPermissionFor(ImageSource source) async {
    if (source == ImageSource.camera) {
      var status = await Permission.camera.status;
      debugPrint('[permission] camera status: $status');
      if (status.isDenied) {
        status = await Permission.camera.request();
        debugPrint('[permission] camera requested, new status: $status');
      }
      if (status.isPermanentlyDenied) {
        // Let the caller show an explanatory dialog and offer to open settings.
        return false;
      }
      return status.isGranted;
    } else {
      // gallery/photos
      if (Platform.isIOS) {
        var status = await Permission.photos.status;
        debugPrint('[permission] photos status: $status');
        if (status.isDenied) {
          status = await Permission.photos.request();
          debugPrint('[permission] photos requested, new status: $status');
        }
        // iOS 14+ has a 'limited' status; treat it as allowed for reading selected photos.
        if (status == PermissionStatus.limited) return true;
        // If the user permanently denied Photos permission, the modern iOS photo picker
        // (PHPicker) may still present a picker without granting the Photos permission to
        // the app. To avoid blocking the user from selecting an image, allow proceeding
        // to the picker. If you want to force the user to re-enable permissions, the
        // caller will show an explicit dialog to open App Settings.
        if (status.isPermanentlyDenied) return true;
        return status.isGranted;
      } else {
        // Android: request storage (legacy) permission as a fallback
        var status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
        if (status.isPermanentlyDenied) return false;
        return status.isGranted;
      }
    }
  }

  /// `Pick an image from gallery or camera, then recognize text.`
  Future<void> _pickImage(ImageSource source) async {
    if (!(Platform.isIOS && source == ImageSource.gallery)) {
      final granted = await _requestPermissionFor(source);
      if (!granted) {
        if (!mounted) return;
        _showPermissionDeniedDialog();
        return;
      }
    }

    try {
      setState(() {
        _isProcessing = true;
        _recognizedText = '';
      });

      final XFile? pickedFile = await _picker
          .pickImage(source: source, maxWidth: 2048, imageQuality: 85)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              debugPrint('[picker] pickImage timed out after 20s');
              return null;
            },
          );
      debugPrint('[picker] pickImage returned: ${pickedFile?.path}');

      if (pickedFile == null) return;

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      setState(() {
        _imageFile = pickedFile;
        _recognizedText = recognizedText.text;
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al seleccionar imagen: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// `Muestra un diálogo informando al usuario que se requiere permiso.`
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso Requerido'),
        content: const Text(
          'Esta característica requiere permisos. Puede otorgarlos en la Configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reconocimiento de Texto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// `Botones de Acción`
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                /// `Botón de Galería`
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),

                /// `Botón de Cámara`
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Usar Cámara'),
                ),

                /// `Botón de Cámara en Vivo`
                ElevatedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    final granted = await _requestPermissionFor(
                      ImageSource.camera,
                    );
                    if (!granted) {
                      if (!mounted) return;
                      _showPermissionDeniedDialog();
                      return;
                    }
                    if (widget.cameras.isEmpty) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('No hay cámaras disponibles')),
                      );
                      return;
                    }
                    final cam = widget.cameras.firstWhere(
                      (c) => c.lensDirection == CameraLensDirection.back,
                      orElse: () => widget.cameras.first,
                    );
                    final result = await navigator.push<RecognizeResult>(
                      MaterialPageRoute(
                        builder: (_) => CameraScreen(camera: cam),
                      ),
                    );
                    if (!mounted) return;
                    if (result != null) {
                      setState(() {
                        _imageFile = XFile(result.imagePath);
                        _recognizedText = result.text;
                      });
                    }
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Cámara en Vivo'),
                ),

                /// `Botón de Permisos`
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PermissionDebugScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.settings),
                  label: const Text('Permisos'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// `Área de Visualización`
            Expanded(
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : _imageFile == null
                  ? const Center(child: Text('Ninguna imagen seleccionada'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.file(File(_imageFile!.path)),
                          const SizedBox(height: 12),

                          /// `Texto Reconocido`
                          Container(
                            padding: const EdgeInsets.all(12),
                            color: Colors.black87,
                            child: Text(
                              _recognizedText.isEmpty
                                  ? 'No se reconoció texto.'
                                  : _recognizedText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),

                          /// `Copiar Texto`
                          ElevatedButton.icon(
                            onPressed: _recognizedText.isEmpty
                                ? null
                                : () {
                                    Clipboard.setData(
                                      ClipboardData(text: _recognizedText),
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Texto copiado al portapapeles',
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copiar Texto'),
                          ),
                          const SizedBox(height: 52),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
