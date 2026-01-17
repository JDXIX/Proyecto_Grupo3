import 'package:flutter/material.dart';
import 'screens/medicamento_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MedicamentoScreen(),
    );
  }
}
