import 'package:proyectog3/screens/recognition/recognition_home.dart';
import 'package:proyectog3/theme/app_theme.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error al capturar la imagen: $e')),
            ],
          ),
          backgroundColor: VoxiaColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: VoxiaColors.accent),
              const SizedBox(height: 16),
              Text(
                'Iniciando cámara...',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vista previa de la cámara
          Positioned.fill(
            child: CameraPreview(_controller),
          ),
          
          // Overlay con guías
          Positioned.fill(
            child: _buildOverlay(),
          ),
          
          // AppBar personalizado
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: VoxiaColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Cámara activa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Instrucciones
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      VoxiaColors.primary.withValues(alpha: 0.8),
                      VoxiaColors.accent.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Enfoca el nombre del medicamento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          
          // Botón de captura
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isProcessing ? null : _takePictureAndRecognize,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isProcessing 
                      ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                      : VoxiaColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: VoxiaColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                ),
              ),
            ),
          ),
          
          // Texto de ayuda
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _isProcessing ? 'Procesando...' : 'Toca para capturar',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final scanAreaWidth = size.width * 0.85;
    final scanAreaHeight = size.height * 0.15;
    final left = (size.width - scanAreaWidth) / 2;
    final top = (size.height - scanAreaHeight) / 2 - 50;

    // Dibujar área oscura alrededor
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight),
        const Radius.circular(16),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Dibujar borde del área de escaneo
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [VoxiaColors.primary, VoxiaColors.accent],
      ).createShader(Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight),
        const Radius.circular(16),
      ),
      borderPaint,
    );

    // Dibujar esquinas decorativas
    final cornerPaint = Paint()
      ..color = VoxiaColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;

    // Esquina superior izquierda
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top + 16), cornerPaint);
    canvas.drawLine(Offset(left + 16, top), Offset(left + cornerLength, top), cornerPaint);

    // Esquina superior derecha
    canvas.drawLine(Offset(left + scanAreaWidth, top + cornerLength), Offset(left + scanAreaWidth, top + 16), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaWidth - 16, top), Offset(left + scanAreaWidth - cornerLength, top), cornerPaint);

    // Esquina inferior izquierda
    canvas.drawLine(Offset(left, top + scanAreaHeight - cornerLength), Offset(left, top + scanAreaHeight - 16), cornerPaint);
    canvas.drawLine(Offset(left + 16, top + scanAreaHeight), Offset(left + cornerLength, top + scanAreaHeight), cornerPaint);

    // Esquina inferior derecha
    canvas.drawLine(Offset(left + scanAreaWidth, top + scanAreaHeight - cornerLength), Offset(left + scanAreaWidth, top + scanAreaHeight - 16), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaWidth - 16, top + scanAreaHeight), Offset(left + scanAreaWidth - cornerLength, top + scanAreaHeight), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
