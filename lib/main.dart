import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screens/recognition/recognition_home.dart';
import 'theme/app_theme.dart';

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
      title: 'VOXIA - Guía de Medicación',
      theme: VoxiaTheme.lightTheme,
      home: RecognitionHomeScreen(cameras: cameras),
    );
  }
}
