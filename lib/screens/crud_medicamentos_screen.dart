import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:proyectog3/theme/app_theme.dart';
import 'package:proyectog3/widgets/voxia_widgets.dart';
import '../database/database_helper.dart';
import '../models/medicamento.dart';
import 'medicamento_screen.dart';

class CrudMedicamentosScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String? initialNombre;

  const CrudMedicamentosScreen({
    super.key,
    required this.cameras,
    this.initialNombre,
  });

  @override
  State<CrudMedicamentosScreen> createState() => _CrudMedicamentosScreenState();
}

class _CrudMedicamentosScreenState extends State<CrudMedicamentosScreen> {
  List<Medicamento> medicamentos = [];
  List<Medicamento> medicamentosFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
    _searchController.addListener(_filtrarMedicamentos);
    if (widget.initialNombre != null) {
      Future.microtask(() => _mostrarFormulario(nombrePredefinido: widget.initialNombre));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarMedicamentos() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllMedicamentos();
    setState(() {
      medicamentos = data;
      medicamentosFiltrados = data;
      _isLoading = false;
    });
  }

  void _filtrarMedicamentos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        medicamentosFiltrados = medicamentos;
      } else {
        medicamentosFiltrados = medicamentos
            .where((m) => m.nombre.toLowerCase().contains(query))
            .toList();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VoxiaBackground(
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personalizado
              _buildCustomAppBar(),
              
              // Campo de búsqueda
              _buildSearchBar(),
              
              // Lista de medicamentos
              Expanded(
                child: _isLoading
                    ? const VoxiaLoadingIndicator(message: 'Cargando medicamentos...')
                    : medicamentos.isEmpty
                        ? _buildEmptyState()
                        : medicamentosFiltrados.isEmpty
                            ? _buildNoResultsState()
                            : _buildMedicamentosList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: VoxiaColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: VoxiaColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _mostrarFormulario(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: VoxiaColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Medicamentos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: VoxiaColors.primaryDark,
                  ),
                ),
                Text(
                  _searchController.text.isEmpty
                      ? '${medicamentos.length} medicamentos registrados'
                      : '${medicamentosFiltrados.length} de ${medicamentos.length} medicamentos',
                  style: TextStyle(
                    fontSize: 13,
                    color: VoxiaColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VoxiaColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar medicamento...',
          hintStyle: TextStyle(
            color: VoxiaColors.textMedium.withValues(alpha: 0.6),
            fontSize: 15,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: VoxiaColors.primary,
              size: 24,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: VoxiaColors.textMedium,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
        ),
        style: const TextStyle(
          fontSize: 15,
          color: VoxiaColors.primaryDark,
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return VoxiaEmptyState(
      icon: Icons.medication_outlined,
      title: 'Sin medicamentos registrados',
      subtitle: 'Agrega tu primer medicamento tocando el botón +',
      action: VoxiaGradientButton(
        text: 'Agregar medicamento',
        icon: Icons.add_rounded,
        onPressed: () => _mostrarFormulario(),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return VoxiaEmptyState(
      icon: Icons.search_off_rounded,
      title: 'No se encontraron resultados',
      subtitle: 'No hay medicamentos que coincidan con "${_searchController.text}"',
      action: VoxiaOutlinedButton(
        text: 'Limpiar búsqueda',
        onPressed: () => _searchController.clear(),
      ),
    );
  }

  Widget _buildMedicamentosList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: medicamentosFiltrados.length,
      itemBuilder: (context, index) {
        final m = medicamentosFiltrados[index];
        return _buildMedicamentoCard(m, index);
      },
    );
  }

  Widget _buildMedicamentoCard(Medicamento m, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VoxiaColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MedicamentoScreen(
                  medicamentoId: m.id,
                  cameras: widget.cameras,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono con gradiente
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: VoxiaColors.accentGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Información del medicamento
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: VoxiaColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.paraQueSirve,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: VoxiaColors.textMedium,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botones de acción
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: VoxiaColors.primary,
                      onTap: () => _mostrarFormulario(medicamento: m),
                      tooltip: 'Editar',
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: VoxiaColors.error,
                      onTap: () => _confirmarEliminacion(m.id),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarFormulario({Medicamento? medicamento, String? nombrePredefinido}) async {
    final nombreCtrl = TextEditingController(text: medicamento?.nombre ?? nombrePredefinido ?? '');
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header del diálogo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: VoxiaColors.accentGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          medicamento == null ? Icons.add_rounded : Icons.edit_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          medicamento == null ? 'Nuevo Medicamento' : 'Editar Medicamento',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: VoxiaColors.primaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: VoxiaColors.textMedium, size: 22),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Campos del formulario
                  _buildTextField(
                    controller: nombreCtrl,
                    label: 'Nombre del medicamento',
                    icon: Icons.medication_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: paraQueSirveCtrl,
                    label: '¿Para qué sirve?',
                    icon: Icons.help_outline_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: comoTomarCtrl,
                    label: '¿Cómo tomarlo?',
                    icon: Icons.schedule_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: advertenciasCtrl,
                    label: 'Advertencias',
                    icon: Icons.warning_amber_rounded,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: VoxiaOutlinedButton(
                          text: 'Cancelar',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: VoxiaGradientButton(
                          text: 'Guardar',
                          icon: Icons.check_rounded,
                          onPressed: () async {
                            if (nombreCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('El nombre es obligatorio'),
                                  backgroundColor: VoxiaColors.error,
                                ),
                              );
                              return;
                            }

                            final nuevoMedicamento = Medicamento(
                              id: medicamento?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              nombre: nombreCtrl.text,
                              paraQueSirve: paraQueSirveCtrl.text,
                              comoTomar: comoTomarCtrl.text,
                              advertencias: advertenciasCtrl.text,
                            );

                            if (medicamento == null) {
                              await DatabaseHelper.instance.insertMedicamento(nuevoMedicamento);
                            } else {
                              await DatabaseHelper.instance.updateMedicamento(nuevoMedicamento);
                            }

                            if (mounted) {
                              Navigator.pop(context);
                              _cargarMedicamentos();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(medicamento == null 
                                        ? 'Medicamento agregado exitosamente'
                                        : 'Medicamento actualizado exitosamente'),
                                    ],
                                  ),
                                  backgroundColor: VoxiaColors.success,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: VoxiaColors.primary, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Future<void> _confirmarEliminacion(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VoxiaColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: VoxiaColors.error, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Eliminar medicamento',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este medicamento? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: VoxiaColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.deleteMedicamento(id);
      _cargarMedicamentos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Medicamento eliminado'),
              ],
            ),
            backgroundColor: VoxiaColors.success,
          ),
        );
      }
    }
  }
}
