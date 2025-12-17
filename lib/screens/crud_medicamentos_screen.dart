import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medicamento.dart';

class CrudMedicamentosScreen extends StatefulWidget {
  const CrudMedicamentosScreen({super.key});

  @override
  State<CrudMedicamentosScreen> createState() => _CrudMedicamentosScreenState();
}

class _CrudMedicamentosScreenState extends State<CrudMedicamentosScreen> {
  List<Medicamento> medicamentos = [];

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
  }

  Future<void> _cargarMedicamentos() async {
    final data = await DatabaseHelper.instance.getAllMedicamentos();
    setState(() {
      medicamentos = data;
    });
  }

  Future<void> _agregarMedicamento() async {
    final nuevo = Medicamento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: 'Nuevo medicamento',
      paraQueSirve: 'Descripción simple.',
      comoTomar: 'Indicación simple.',
      advertencias: 'Advertencia simple.',
    );

    await DatabaseHelper.instance.insertMedicamento(nuevo);
    _cargarMedicamentos();
  }

  Future<void> _eliminarMedicamento(String id) async {
    await DatabaseHelper.instance.deleteMedicamento(id);
    _cargarMedicamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimiento de medicamentos')),
      body: ListView.builder(
        itemCount: medicamentos.length,
        itemBuilder: (context, index) {
          final m = medicamentos[index];
          return ListTile(
            title: Text(m.nombre),
            subtitle: Text(m.paraQueSirve),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _eliminarMedicamento(m.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarMedicamento,
        child: const Icon(Icons.add),
      ),
    );
  }
}
