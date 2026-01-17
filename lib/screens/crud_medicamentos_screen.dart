import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medicamento.dart';
import 'medicamento_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mantenimiento de medicamentos',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: medicamentos.length,
        itemBuilder: (context, index) {
          final m = medicamentos[index];
          return ListTile(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicamentoScreen(medicamentoId: m.id),
                ),
              );
            },
            title: Text(
              m.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              m.paraQueSirve,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar medicamento',
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _mostrarFormulario(medicamento: m),
                ),
                IconButton(
                  tooltip: 'Eliminar medicamento',
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _confirmarEliminacion(m.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _mostrarFormulario({Medicamento? medicamento}) async {
    final nombreCtrl = TextEditingController(text: medicamento?.nombre ?? '');
    final paraQueSirveCtrl = TextEditingController(
      text: medicamento?.paraQueSirve ?? '',
    );
    final comoTomarCtrl = TextEditingController(
      text: medicamento?.comoTomar ?? '',
    );
    final advertenciasCtrl = TextEditingController(
      text: medicamento?.advertencias ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          medicamento == null ? 'Nuevo Medicamento' : 'Editar Medicamento',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: paraQueSirveCtrl,
                decoration: const InputDecoration(
                  labelText: '¿Para qué sirve?',
                ),
                maxLines: 2,
              ),
              TextField(
                controller: comoTomarCtrl,
                decoration: const InputDecoration(labelText: '¿Cómo tomarlo?'),
                maxLines: 2,
              ),
              TextField(
                controller: advertenciasCtrl,
                decoration: const InputDecoration(labelText: 'Advertencias'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isEmpty) return;

              final nuevoMedicamento = Medicamento(
                id:
                    medicamento?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: nombreCtrl.text,
                paraQueSirve: paraQueSirveCtrl.text,
                comoTomar: comoTomarCtrl.text,
                advertencias: advertenciasCtrl.text,
              );

              if (medicamento == null) {
                await DatabaseHelper.instance.insertMedicamento(
                  nuevoMedicamento,
                );
              } else {
                await DatabaseHelper.instance.updateMedicamento(
                  nuevoMedicamento,
                );
              }

              if (mounted) {
                Navigator.pop(context);
                _cargarMedicamentos();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminacion(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar medicamento'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este medicamento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.deleteMedicamento(id);
      _cargarMedicamentos();
    }
  }
}
