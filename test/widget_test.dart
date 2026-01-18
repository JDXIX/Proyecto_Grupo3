import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:sqflite/sqflite.dart';
import 'package:proyectog3/main.dart';
import 'package:proyectog3/database/database_helper.dart';
import 'package:proyectog3/models/medicamento.dart';

class FakeDatabaseHelper implements DatabaseHelper {
  @override
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<Medicamento?> getMedicamentoById(String id) async {
    if (id.toLowerCase() == 'paracetamol') {
      return Medicamento(
        id: 'paracetamol',
        nombre: 'Paracetamol',
        paraQueSirve: 'Sirve para el dolor.',
        comoTomar: 'Tomar 1.',
        advertencias: 'Cuidado.',
      );
    }
    return null;
  }

  @override
  Future<List<Medicamento>> getAllMedicamentos() async => [];
  
  @override
  Future<void> insertMedicamento(Medicamento m) async {}
  @override
  Future<void> updateMedicamento(Medicamento m) async {}
  @override
  Future<void> deleteMedicamento(String id) async {}
  
  // ignore: unused_element
  Future<Database> _initDatabase() async => throw UnimplementedError();
}

void main() {
  setUpAll(() {
    // Mock Flutter TTS channel
    const MethodChannel ttsChannel = MethodChannel('flutter_tts');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      ttsChannel,
      (MethodCall methodCall) async {
        return 1;
      },
    );
  });

  testWidgets('App shows seeded medicamento', (WidgetTester tester) async {
    // Inject Fake Database
    DatabaseHelper.instance = FakeDatabaseHelper();

    // Build the app
    await tester.pumpWidget(MyApp(cameras: <CameraDescription>[]));

    // Wait for the FutureBuilder/async methods to complete
    await tester.pump(const Duration(milliseconds: 100)); 
    await tester.pumpAndSettle();

    // The seeded database contains 'Paracetamol'
    expect(find.text('Paracetamol'), findsOneWidget);
  });
}
