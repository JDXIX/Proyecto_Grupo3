import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:proyectog3/screens/recognition/recognition_home.dart';
import 'package:proyectog3/theme/app_theme.dart';
import 'package:proyectog3/widgets/voxia_widgets.dart';
import '../database/database_helper.dart';
import '../models/medicamento.dart';
import '../services/audio_service.dart';
import 'crud_medicamentos_screen.dart';

class MedicamentoScreen extends StatefulWidget {
  final String? medicamentoId;
  final List<CameraDescription> cameras;

  const MedicamentoScreen({
    super.key,
    this.medicamentoId,
    required this.cameras,
  });

  @override
  State<MedicamentoScreen> createState() => _MedicamentoScreenState();
}

class _MedicamentoScreenState extends State<MedicamentoScreen> {
  Medicamento? medicamento;
  final AudioService audioService = AudioService();

  @override
  void initState() {
    super.initState();
    audioService.init();
    _cargarMedicamento();
  }

  @override
  void dispose() {
    audioService.dispose();
    super.dispose();
  }

  void _cargarMedicamento() async {
    final idToLoad = widget.medicamentoId;
    if (idToLoad == null) return;

    final result = await DatabaseHelper.instance.getMedicamentoById(idToLoad);

    setState(() {
      medicamento = result;
    });

    if (result != null) {
      audioService.speak(
        "Medicamento: ${result.nombre}. Sirve para: ${result.paraQueSirve}. Como tomar: ${result.comoTomar}. Advertencias: ${result.advertencias}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (medicamento == null) {
      return Scaffold(
        body: VoxiaBackground(
          child: const Center(
            child: VoxiaLoadingIndicator(message: 'Cargando medicamento...'),
          ),
        ),
      );
    }

    return Scaffold(
      body: VoxiaBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // AppBar personalizado
              SliverAppBar(
                expandedHeight: 60,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16),
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
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
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
                      icon: const Icon(Icons.camera_alt_rounded, color: VoxiaColors.primary),
                      tooltip: 'Escanear medicamento',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecognitionHomeScreen(cameras: widget.cameras),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16),
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
                      icon: const Icon(Icons.medical_services_outlined, color: VoxiaColors.primary),
                      tooltip: 'Mantenimiento de medicamentos',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CrudMedicamentosScreen(cameras: widget.cameras),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              // Contenido principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      
                      // Header del medicamento
                      _buildMedicamentoHeader(),
                      
                      const SizedBox(height: 24),
                      
                      // Secciones de información
                      VoxiaInfoSection(
                        title: '¿Para qué sirve?',
                        content: medicamento!.paraQueSirve,
                        icon: Icons.help_outline_rounded,
                        onAudioPressed: () => audioService.speak(medicamento!.paraQueSirve),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      VoxiaInfoSection(
                        title: '¿Cómo tomarlo?',
                        content: medicamento!.comoTomar,
                        icon: Icons.medication_rounded,
                        onAudioPressed: () => audioService.speak(medicamento!.comoTomar),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildWarningSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Botón para escuchar todo
                      _buildListenAllButton(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicamentoHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: VoxiaColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: VoxiaColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            medicamento!.nombre,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Información del medicamento',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      decoration: BoxDecoration(
        color: VoxiaColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: VoxiaColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: VoxiaColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: VoxiaColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Advertencias',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VoxiaColors.primaryDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => audioService.speak(medicamento!.advertencias),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: VoxiaColors.warning,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Escuchar advertencias',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              medicamento!.advertencias,
              style: TextStyle(
                fontSize: 16,
                color: VoxiaColors.textMedium,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListenAllButton() {
    return VoxiaGradientButton(
      text: 'Escuchar toda la información',
      icon: Icons.volume_up_rounded,
      onPressed: () {
        audioService.speak(
          "Medicamento: ${medicamento!.nombre}. Sirve para: ${medicamento!.paraQueSirve}. Cómo tomarlo: ${medicamento!.comoTomar}. Advertencias: ${medicamento!.advertencias}",
        );
      },
    );
  }
}
