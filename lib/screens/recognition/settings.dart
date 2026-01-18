import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDebugScreen extends StatefulWidget {
  const PermissionDebugScreen({super.key});

  @override
  State<PermissionDebugScreen> createState() => _PermissionDebugScreenState();
}

class _PermissionDebugScreenState extends State<PermissionDebugScreen> {
  PermissionStatus? _camera;
  PermissionStatus? _photos;
  PermissionStatus? _storage;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final cam = await Permission.camera.status;
    final photos = await Permission.photos.status;
    final storage = await Permission.storage.status;
    if (!mounted) return;
    setState(() {
      _camera = cam;
      _photos = photos;
      _storage = storage;
    });
  }

  Widget _statusRow(
    String label,
    PermissionStatus? status,
    VoidCallback onRequest,
  ) {
    return ListTile(
      title: Text(label),
      subtitle: Text(status?.toString() ?? 'desconocido'),
      trailing: ElevatedButton(
        onPressed: onRequest,
        child: const Text('Solicitar'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Depuración de Permisos')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            _statusRow('Cámara', _camera, () async {
              await Permission.camera.request();
              await _refresh();
            }),
            _statusRow('Fotos', _photos, () async {
              await Permission.photos.request();
              await _refresh();
            }),
            _statusRow('Almacenamiento', _storage, () async {
              await Permission.storage.request();
              await _refresh();
            }),
            ListTile(
              title: const Text('Abrir Configuración de la App'),
              trailing: ElevatedButton(
                onPressed: () => openAppSettings(),
                child: const Text('Abrir'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Si la configuración de la app solo muestra Siri y Buscar, es posible que la app no haya solicitado el permiso correcto o que el sistema agrupe la configuración de manera diferente. Utiliza los botones "Solicitar" de arriba para activar los diálogos del sistema cuando sea posible.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
