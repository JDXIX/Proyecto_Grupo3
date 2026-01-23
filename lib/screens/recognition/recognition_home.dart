import 'dart:io';

import 'package:proyectog3/screens/recognition/camera_screen.dart';
import 'package:proyectog3/screens/recognition/settings.dart';
import 'package:proyectog3/screens/medicamento_screen.dart';
import 'package:proyectog3/screens/crud_medicamentos_screen.dart';
import 'package:proyectog3/database/database_helper.dart';
import 'package:proyectog3/models/medicamento.dart';
import 'package:proyectog3/services/audio_service.dart';
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
  final AudioService _audioService = AudioService();
  String _recognizedText = '';
  XFile? _imageFile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _audioService.init();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _audioService.dispose();
    super.dispose();
  }

  /// `Request permission for camera or gallery access.`
  Future<bool> _requestPermissionFor(ImageSource source) async {
    if (source == ImageSource.camera) {
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }
      return status.isGranted;
    } else {
      if (Platform.isIOS) {
        var status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }
        if (status == PermissionStatus.limited) return true;
        return status.isGranted;
      } else {
        var status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
  }

  /// `Busca el medicamento en la base de datos basándose en el texto reconocido.`
  Future<void> _analizarYBuscarMedicamento(String text) async {
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);

    // Intentamos limpiar un poco el texto. A veces MLKit devuelve basura.
    // Buscamos palabras que parezcan nombres (más de 3 letras, mayúsculas, etc)
    final lines = text.split('\n');
    Medicamento? encontrado;
    String candidateName = "";

    for (var line in lines) {
      final possibleName = line.trim();
      if (possibleName.length < 3) continue;

      encontrado = await DatabaseHelper.instance.getMedicamentoByNombre(possibleName);
      if (encontrado != null) {
        candidateName = possibleName;
        break;
      }
    }

    // Si no se encontró por línea exacta, probamos con palabras individuales
    if (encontrado == null) {
      final words = text.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'), ' ').split(RegExp(r'\s+'));
      for (var word in words) {
        if (word.length < 4) continue;
        encontrado = await DatabaseHelper.instance.getMedicamentoByNombre(word);
        if (encontrado != null) {
          candidateName = word;
          break;
        }
      }
    }

    setState(() => _isProcessing = false);

    if (encontrado != null) {
      if (!mounted) return;
      await _audioService.speak("Medicamento encontrado: ${encontrado.nombre}. Abriendo detalles.");
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicamentoScreen(
            medicamentoId: encontrado!.id,
            cameras: widget.cameras,
          ),
        ),
      );
    } else {
      // No encontrado: Diálogo de Advertencia
      final primerPalabraLikely = text.split(RegExp(r'\s+')).firstWhere((w) => w.length > 3, orElse: () => "");
      _mostrarDialogoNoEncontrado(primerPalabraLikely);
    }
  }

  void _mostrarDialogoNoEncontrado(String textDetected) {
    _audioService.speak("No encontré información de este medicamento. ¿Deseas agregarlo?");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medicamento No Encontrado'),
        content: Text(
          'No se tiene información de "$textDetected" en la base de datos.\n\n¿Deseas agregarlo ahora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // cerrar diálogo
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrudMedicamentosScreen(
                    cameras: widget.cameras,
                    initialNombre: textDetected,
                  ),
                ),
              );
            },
            child: const Text('Sí, Agregar'),
          ),
        ],
      ),
    );
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

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _imageFile = pickedFile;
        _recognizedText = recognizedText.text;
      });

      // Disparar búsqueda automática
      await _analizarYBuscarMedicamento(recognizedText.text);

    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

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
      appBar: AppBar(
        title: const Text('Escáner de Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Mantenimiento',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CrudMedicamentosScreen(cameras: widget.cameras),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Apunta a la caja del medicamento para obtener información accesible.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar Foto'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final granted = await _requestPermissionFor(ImageSource.camera);
                    if (!granted) {
                      _showPermissionDeniedDialog();
                      return;
                    }
                    if (widget.cameras.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay cámaras disponibles')),
                      );
                      return;
                    }
                    final cam = widget.cameras.firstWhere(
                      (c) => c.lensDirection == CameraLensDirection.back,
                      orElse: () => widget.cameras.first,
                    );
                    final result = await navigator.push<RecognizeResult>(
                      MaterialPageRoute(builder: (_) => CameraScreen(camera: cam)),
                    );
                    if (result != null) {
                      setState(() {
                        _imageFile = XFile(result.imagePath);
                        _recognizedText = result.text;
                      });
                      await _analizarYBuscarMedicamento(result.text);
                    }
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Cámara en Vivo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : _imageFile == null
                      ? const Center(
                          child: Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(_imageFile!.path)),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Texto detectado:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _recognizedText.isEmpty ? 'Analizando...' : _recognizedText,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
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
