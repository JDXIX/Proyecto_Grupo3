import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medicamento.dart';
import '../services/audio_service.dart';
import 'crud_medicamentos_screen.dart';

class MedicamentoScreen extends StatefulWidget {
  const MedicamentoScreen({super.key});

  @override
  State<MedicamentoScreen> createState() => _MedicamentoScreenState();
}

class _MedicamentoScreenState extends State<MedicamentoScreen> {
  Medicamento? medicamento;
  final AudioService audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _cargarMedicamento();
  }

  void _cargarMedicamento() async {
    // 🔹 Simulación del resultado del OCR (Grupo 2)
    final result = await DatabaseHelper.instance.getMedicamentoById(
      'paracetamol',
    );

    setState(() {
      medicamento = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (medicamento == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de medicación'),
        centerTitle: true,

        // 🔹 BOTÓN PARA ACCEDER AL CRUD (MANTENIMIENTO)
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Mantenimiento de medicamentos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CrudMedicamentosScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            _tituloMedicamento(),
            const SizedBox(height: 24),
            _seccion(
              titulo: '¿Para qué sirve?',
              texto: medicamento!.paraQueSirve,
            ),
            _seccion(titulo: '¿Cómo tomarlo?', texto: medicamento!.comoTomar),
            _seccion(titulo: 'Advertencias', texto: medicamento!.advertencias),
          ],
        ),
      ),
    );
  }

  Widget _tituloMedicamento() {
    return Center(
      child: Text(
        medicamento!.nombre,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _seccion({required String titulo, required String texto}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(texto, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Center(
              child: IconButton(
                icon: const Icon(Icons.volume_up, size: 40),
                onPressed: () => audioService.speak(texto),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
