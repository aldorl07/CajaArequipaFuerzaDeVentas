import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class RegistrarDesertorScreen extends StatefulWidget {
  final String clientDni;
  final String clientName;

  const RegistrarDesertorScreen({
    super.key,
    required this.clientDni,
    required this.clientName,
  });

  @override
  State<RegistrarDesertorScreen> createState() => _RegistrarDesertorScreenState();
}

class _RegistrarDesertorScreenState extends State<RegistrarDesertorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _motivoDesercion = 'Tasa de interés alta';
  final _institucionMigradaController = TextEditingController();
  String _probabilidadRetorno = 'Media';
  final _observacionesController = TextEditingController();

  final List<String> _motivos = [
    'Tasa de interés alta',
    'Mal servicio / atención lenta',
    'Competencia ofrece mejores montos',
    'Migró a otra entidad financiera',
    'Cierre / quiebra de negocio',
    'Otros motivos personales',
  ];

  final List<String> _probabilidades = ['Alta', 'Media', 'Baja'];

  @override
  void dispose() {
    _institucionMigradaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _guardarDesercion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic> desertionData = {
      'motivo_desercion': _motivoDesercion,
      'institucion_migrada': _institucionMigradaController.text.trim().isEmpty 
          ? 'No especificado' 
          : _institucionMigradaController.text.trim(),
      'probabilidad_retorno': _probabilidadRetorno,
      'observaciones': _observacionesController.text.trim(),
      'fecha_registro': DateTime.now().toIso8601String(),
    };

    try {
      // Update client record in Firestore
      await FirebaseFirestore.instance.collection('clients').doc(widget.clientDni).update({
        'status': 'Desertor',
        'isDeserted': true,
        'desertion_details': desertionData,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente registrado como Desertor exitosamente.'),
            backgroundColor: AppColors.turquesaOscuro,
          ),
        );
        // Pop back twice to return to the daily portfolio (since we were in FichaCliente)
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error saving desertion details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar registro. Intente nuevamente.'),
            backgroundColor: AppColors.rojoCoral,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Deserción'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.turquesaBrillante))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.azulMarino,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información del Cliente',
                            style: TextStyle(color: AppColors.turquesaBrillante, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.clientName,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DNI: ${widget.clientDni}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Detalles de Deserción (RF-42)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                    ),
                    const SizedBox(height: 12),

                    // Motivo dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _motivoDesercion,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de Deserción',
                        prefixIcon: Icon(Icons.help_outline, color: AppColors.azulMarino),
                      ),
                      dropdownColor: AppColors.blancoPuro,
                      items: _motivos.map((String val) {
                        return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(color: AppColors.textoOscuro)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _motivoDesercion = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Institución a la que migró
                    TextFormField(
                      controller: _institucionMigradaController,
                      style: const TextStyle(color: AppColors.textoOscuro),
                      decoration: const InputDecoration(
                        labelText: 'Institución a la que migró (si se conoce)',
                        prefixIcon: Icon(Icons.account_balance, color: AppColors.azulMarino),
                        hintText: 'Ej. Compartamos, Mibanco, etc.',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Probabilidad de retorno selector
                    const Text(
                      'Probabilidad de Retorno',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _probabilidades.map((prob) {
                        final isSelected = _probabilidadRetorno == prob;
                        Color chipColor;
                        switch (prob) {
                          case 'Alta':
                            chipColor = AppColors.verdeCesped;
                            break;
                          case 'Media':
                            chipColor = AppColors.amarilloMostaza;
                            break;
                          default:
                            chipColor = AppColors.rojoCoral;
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () => setState(() => _probabilidadRetorno = prob),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? chipColor : Colors.transparent,
                                  border: Border.all(color: chipColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  prob,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : chipColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Observaciones libres
                    TextFormField(
                      controller: _observacionesController,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textoOscuro),
                      decoration: const InputDecoration(
                        labelText: 'Observaciones Libres',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 50.0),
                          child: Icon(Icons.chat_bubble_outline, color: AppColors.azulMarino),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, ingrese observaciones o comentarios.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azulMarino,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _guardarDesercion,
                        icon: const Icon(Icons.save),
                        label: const Text('GUARDAR REGISTRO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
