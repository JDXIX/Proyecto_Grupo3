import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screens/medicamento_screen.dart';
import 'screens/recognition/recognition_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guía accesible de medicación',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(
          0xFF0073E6,
        ), // Vibrant blue seed from selected palette
      ),
      home: RecognitionHomeScreen(cameras: cameras),
    );
  }
}
