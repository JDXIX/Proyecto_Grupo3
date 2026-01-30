import 'dart:io';

import 'package:proyectog3/screens/recognition/camera_screen.dart';
import 'package:proyectog3/screens/medicamento_screen.dart';
import 'package:proyectog3/screens/crud_medicamentos_screen.dart';
import 'package:proyectog3/database/database_helper.dart';
import 'package:proyectog3/models/medicamento.dart';
import 'package:proyectog3/services/audio_service.dart';
import 'package:proyectog3/theme/app_theme.dart';
import 'package:proyectog3/widgets/voxia_widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VoxiaColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_off_rounded, color: VoxiaColors.warning),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Medicamento No Encontrado',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No se encontró información de:',
              style: TextStyle(color: VoxiaColors.textMedium),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: VoxiaColors.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"$textDetected"',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: VoxiaColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('¿Deseas agregarlo a la base de datos?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
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
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VoxiaColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline, color: VoxiaColors.warning, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Permiso Requerido', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: const Text(
          'Esta característica requiere permisos de acceso. Puede otorgarlos en la Configuración de su dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VoxiaBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // AppBar personalizado
              SliverAppBar(
                expandedHeight: 60,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: VoxiaColors.primary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.medical_services_outlined, color: VoxiaColors.primary),
                      tooltip: 'Gestionar medicamentos',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CrudMedicamentosScreen(cameras: widget.cameras),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Contenido principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Logo y título VOXIA
                      const VoxiaHeader(
                        showLogo: true,
                        showTitle: true,
                        logoSize: 100,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Tarjeta de instrucciones mejorada
                      _buildInstructionCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Botones de acción
                      _buildActionButtons(),
                      
                      const SizedBox(height: 24),
                      
                      // Área de resultados
                      _buildResultsArea(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInstructionCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            VoxiaColors.primary.withValues(alpha: 0.1),
            VoxiaColors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: VoxiaColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: VoxiaColors.accentGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: VoxiaColors.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cómo funciona?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VoxiaColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escanea el nombre de tu medicamento y obtén información útil al instante con asistencia por voz',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: VoxiaColors.textMedium,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Elige una opción',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: VoxiaColors.textMedium,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Botón Cámara (principal)
        VoxiaGradientButton(
          text: 'Usar Cámara',
          icon: Icons.camera_alt_rounded,
          isLoading: _isProcessing,
          onPressed: _isProcessing ? null : () async {
            final navigator = Navigator.of(context);
            final granted = await _requestPermissionFor(ImageSource.camera);
            if (!granted) {
              _showPermissionDeniedDialog();
              return;
            }
            if (widget.cameras.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('No hay cámaras disponibles'),
                  backgroundColor: VoxiaColors.warning,
                ),
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
        ),
        
        const SizedBox(height: 12),
        
        // Botón Galería (secundario)
        VoxiaOutlinedButton(
          text: 'Seleccionar de Galería',
          icon: Icons.photo_library_rounded,
          onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }
  
  Widget _buildResultsArea() {
    if (_isProcessing) {
      return const VoxiaLoadingIndicator(
        message: 'Analizando imagen...',
      );
    }
    
    if (_imageFile == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: VoxiaColors.primaryLight.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VoxiaColors.accentLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_search_rounded,
                size: 48,
                color: VoxiaColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin imagen seleccionada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VoxiaColors.textMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Captura o selecciona una imagen para comenzar',
              style: TextStyle(
                fontSize: 13,
                color: VoxiaColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: VoxiaColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              'Imagen capturada',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VoxiaColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: VoxiaColors.primary.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_imageFile!.path),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
