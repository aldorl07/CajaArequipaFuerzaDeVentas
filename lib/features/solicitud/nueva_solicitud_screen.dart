import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_service.dart';

class NuevaSolicitudScreen extends StatefulWidget {
  final String? prefilledDni;
  final double? prefilledAmount;
  final String? prefilledTerm;
  final bool isResumingDraft;

  const NuevaSolicitudScreen({
    super.key,
    this.prefilledDni,
    this.prefilledAmount,
    this.prefilledTerm,
    this.isResumingDraft = false,
  });

  @override
  State<NuevaSolicitudScreen> createState() => _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState extends State<NuevaSolicitudScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // STEP 1: Solicitante
  final _dniController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  String _estadoCivil = 'Soltero';
  String _gradoInstruccion = 'Secundaria';
  DateTime? _fechaNacimiento;

  // Cónyuge / Garante
  final _garanteNombresController = TextEditingController();
  final _garanteDniController = TextEditingController();
  final _garanteTlfController = TextEditingController();

  // STEP 2: Negocio
  String _tipoNegocio = 'Comercio';
  final _nombreNegocioController = TextEditingController();
  final _direccionNegocioController = TextEditingController();
  final _antiguedadNegocioController = TextEditingController(text: '12');
  final _ingresosController = TextEditingController(text: '2500');
  final _gastosController = TextEditingController(text: '1200');
  final _destinoCreditoController = TextEditingController();
  String _actividadCiiu = 'G4711 - Retail';

  // STEP 3: Condiciones
  double _montoSolicitado = 10000.0;
  String _plazoMeses = '12';
  String _moneda = 'PEN';
  final String _tipoCuota = 'mensual';
  String _garantia = 'sin_garantia';
  final double _teaReferencial = 28.0;

  // STEP 4: Firma
  String? _signatureBase64;
  bool _declaraVeraz = false;

  bool _isLoading = false;

  final List<String> _estadosCiviles = ['Soltero', 'Casado', 'Conviviente', 'Divorciado', 'Viudo'];
  final List<String> _gradosInstruccion = ['Primaria', 'Secundaria', 'Técnico', 'Universitario'];
  final List<String> _tiposNegocio = ['Comercio', 'Servicios', 'Producción', 'Agropecuario'];
  final List<String> _ciiuActividades = [
    'G4711 - Retail de abarrotes',
    'G4771 - Venta de prendas de vestir',
    'I5610 - Restaurantes y servicios móviles',
    'H4921 - Transporte urbano de pasajeros',
    'A0111 - Cultivo de cereales'
  ];
  final List<String> _plazos = ['3', '6', '12', '18', '24', '36', '48', '60'];

  @override
  void initState() {
    super.initState();
    if (widget.prefilledDni != null) {
      _dniController.text = widget.prefilledDni!;
      _loadPrefilledData();
    }
    if (widget.prefilledAmount != null) {
      _montoSolicitado = widget.prefilledAmount!;
    }
    if (widget.prefilledTerm != null) {
      _plazoMeses = widget.prefilledTerm!;
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _garanteNombresController.dispose();
    _garanteDniController.dispose();
    _garanteTlfController.dispose();
    _nombreNegocioController.dispose();
    _direccionNegocioController.dispose();
    _antiguedadNegocioController.dispose();
    _ingresosController.dispose();
    _gastosController.dispose();
    _destinoCreditoController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefilledData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('clients').doc(widget.prefilledDni).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nombresController.text = data['name'] ?? '';
        _telefonoController.text = data['phone'] ?? '';
        _direccionNegocioController.text = data['address'] ?? '';
        _montoSolicitado = (data['credit_renewal_amount'] as num?)?.toDouble() ?? _montoSolicitado;
      }
      
      // If resuming draft
      if (widget.isResumingDraft) {
        final draftDoc = await FirebaseFirestore.instance.collection('credit_requests').doc(widget.prefilledDni).get();
        if (draftDoc.exists) {
          final d = draftDoc.data()!;
          _dniController.text = d['client_dni'] ?? '';
          _nombresController.text = d['client_name'] ?? '';
          _montoSolicitado = (d['amount'] as num?)?.toDouble() ?? _montoSolicitado;
          _plazoMeses = d['term_months']?.toString() ?? _plazoMeses;
          _destinoCreditoController.text = d['destination'] ?? '';
          _ingresosController.text = d['monthly_income']?.toString() ?? _ingresosController.text;
          _currentStep = d['step_completed'] ?? 0;
          _estadoCivil = d['estado_civil'] ?? 'Soltero';
          _tipoNegocio = d['tipo_negocio'] ?? 'Comercio';
          _nombreNegocioController.text = d['nombre_negocio'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error loading prefill data: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveDraft() async {
    final String dni = _dniController.text.isNotEmpty ? _dniController.text : 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final Map<String, dynamic> draft = {
      'client_dni': dni,
      'client_name': _nombresController.text.isNotEmpty ? _nombresController.text : 'Borrador sin nombre',
      'amount': _montoSolicitado,
      'term_months': int.parse(_plazoMeses),
      'destination': _destinoCreditoController.text,
      'monthly_income': double.tryParse(_ingresosController.text) ?? 0.0,
      'status': 'Borrador',
      'step_completed': _currentStep,
      'estado_civil': _estadoCivil,
      'tipo_negocio': _tipoNegocio,
      'nombre_negocio': _nombreNegocioController.text,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance.collection('credit_requests').doc(dni).set(draft);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Borrador guardado localmente.'), backgroundColor: AppColors.turquesaOscuro),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving draft: $e');
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_signatureBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El cliente debe firmar la solicitud antes de continuar.'), backgroundColor: AppColors.rojoCoral),
      );
      return;
    }
    if (!_declaraVeraz) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe marcar la declaración de veracidad de datos.'), backgroundColor: AppColors.rojoCoral),
      );
      return;
    }

    setState(() => _isLoading = true);

    final connProv = Provider.of<ConnectivityProvider>(context, listen: false);
    final syncProv = Provider.of<SyncProvider>(context, listen: false);

    final String dni = _dniController.text;
    final Map<String, dynamic> request = {
      'client_dni': dni,
      'client_name': '${_nombresController.text} ${_apellidosController.text}',
      'amount': _montoSolicitado,
      'term_months': int.parse(_plazoMeses),
      'destination': _destinoCreditoController.text,
      'monthly_income': double.tryParse(_ingresosController.text) ?? 2500.0,
      'bureau_score': 740, // Simulated score
      'bureau_rating': 'Bajo Riesgo',
      'doc_front_path': 'simulated_front.jpg',
      'doc_back_path': 'simulated_back.jpg',
      'status': connProv.isOnline ? 'Sent' : 'PendingSync',
      'firma_cliente_base64': _signatureBase64,
      'moneda': _moneda,
      'tipo_cuota': _tipoCuota,
      'garantia': _garantia,
      'fecha_nacimiento': _fechaNacimiento?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance.collection('credit_requests').doc(dni).set(request);
      
      if (connProv.isOnline) {
        syncProv.syncPendingRequests(true);
      } else {
        await syncProv.updatePendingCount();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(connProv.isOnline 
              ? 'Solicitud enviada al Core Bancario.' 
              : 'Sin red. Guardada en cola offline de Firestore.'),
            backgroundColor: connProv.isOnline ? AppColors.verdeCesped : AppColors.amarilloMostaza,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving credit request: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salir de la Captura'),
        content: const Text('¿Desea guardar esta solicitud como borrador antes de salir para no perder los datos cargados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: const Text('DESCARTAR', style: TextStyle(color: AppColors.rojoCoral)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop('save'),
            child: const Text('GUARDAR BORRADOR'),
          ),
        ],
      ),
    );

    if (result == 'save') {
      await _saveDraft();
      return true;
    } else if (result == 'discard') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nueva Solicitud (4 Pasos)'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.turquesaBrillante))
            : Form(
                key: _formKey,
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 3) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      _submitRequest();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                    }
                  },
                  steps: [
                    Step(
                      title: const Text('Solicitante', style: TextStyle(fontSize: 10)),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.editing,
                      content: _buildStep1Solicitante(),
                    ),
                    Step(
                      title: const Text('Negocio', style: TextStyle(fontSize: 10)),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : (_currentStep == 1 ? StepState.editing : StepState.indexed),
                      content: _buildStep2Negocio(),
                    ),
                    Step(
                      title: const Text('Condiciones', style: TextStyle(fontSize: 10)),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : (_currentStep == 2 ? StepState.editing : StepState.indexed),
                      content: _buildStep3Condiciones(),
                    ),
                    Step(
                      title: const Text('Firma', style: TextStyle(fontSize: 10)),
                      isActive: _currentStep >= 3,
                      state: _currentStep == 3 ? StepState.editing : StepState.indexed,
                      content: _buildStep4Firma(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStep1Solicitante() {
    final showGuarantor = _estadoCivil == 'Casado' || _estadoCivil == 'Conviviente';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Datos del Cliente Solicitante', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulMarino)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dniController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textoOscuro),
          maxLength: 8,
          decoration: const InputDecoration(labelText: 'DNI del Cliente', prefixIcon: Icon(Icons.badge)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nombresController,
          keyboardType: TextInputType.name,
          style: const TextStyle(color: AppColors.textoOscuro),
          decoration: const InputDecoration(labelText: 'Nombres', prefixIcon: Icon(Icons.person)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _apellidosController,
          keyboardType: TextInputType.name,
          style: const TextStyle(color: AppColors.textoOscuro),
          decoration: const InputDecoration(labelText: 'Apellidos', prefixIcon: Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 12),
        
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.cake, color: AppColors.azulMarino),
          title: Text(
            _fechaNacimiento == null
                ? 'Seleccionar Fecha de Nacimiento'
                : 'F. Nac: ${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
            style: TextStyle(
              color: _fechaNacimiento == null ? AppColors.textoMutado : AppColors.textoOscuro,
              fontSize: 14,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 80)),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            );
            if (picked != null) {
              setState(() {
                _fechaNacimiento = picked;
              });
            }
          },
        ),
        const Divider(),
        const SizedBox(height: 12),

        TextFormField(
          controller: _telefonoController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: AppColors.textoOscuro),
          maxLength: 9,
          decoration: const InputDecoration(labelText: 'Teléfono Celular', prefixIcon: Icon(Icons.phone)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _estadoCivil,
          decoration: const InputDecoration(labelText: 'Estado Civil', prefixIcon: Icon(Icons.favorite)),
          dropdownColor: AppColors.blancoPuro,
          items: _estadosCiviles.map((String val) {
            return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(color: AppColors.textoOscuro)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _estadoCivil = val);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _gradoInstruccion,
          decoration: const InputDecoration(labelText: 'Grado de Instrucción', prefixIcon: Icon(Icons.school)),
          dropdownColor: AppColors.blancoPuro,
          items: _gradosInstruccion.map((String val) {
            return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(color: AppColors.textoOscuro)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _gradoInstruccion = val);
          },
        ),

        // Guarantor Conditional Section
        if (showGuarantor) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Datos del Garante / Cónyuge Obligatorio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.rojoCoral)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _garanteDniController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            style: const TextStyle(color: AppColors.textoOscuro),
            decoration: const InputDecoration(labelText: 'DNI Garante', prefixIcon: Icon(Icons.badge_outlined)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _garanteNombresController,
            style: const TextStyle(color: AppColors.textoOscuro),
            decoration: const InputDecoration(labelText: 'Nombres Garante', prefixIcon: Icon(Icons.person_pin)),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2Negocio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Información Comercial / Negocio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulMarino)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _tipoNegocio,
          decoration: const InputDecoration(labelText: 'Tipo de Negocio', prefixIcon: Icon(Icons.store)),
          dropdownColor: AppColors.blancoPuro,
          items: _tiposNegocio.map((String val) {
            return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(color: AppColors.textoOscuro)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _tipoNegocio = val);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nombreNegocioController,
          style: const TextStyle(color: AppColors.textoOscuro),
          decoration: const InputDecoration(labelText: 'Nombre Comercial', prefixIcon: Icon(Icons.storefront)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _direccionNegocioController,
          style: const TextStyle(color: AppColors.textoOscuro),
          decoration: const InputDecoration(labelText: 'Dirección del Negocio', prefixIcon: Icon(Icons.location_on)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _antiguedadNegocioController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textoOscuro),
          decoration: const InputDecoration(labelText: 'Antigüedad en Meses', prefixIcon: Icon(Icons.calendar_month)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _ingresosController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textoOscuro),
          decoration: const InputDecoration(labelText: 'Ingresos Mensuales Estimados (S/)', prefixIcon: Icon(Icons.monetization_on)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _gastosController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textoOscuro),
          decoration: const InputDecoration(labelText: 'Gastos Mensuales (S/)', prefixIcon: Icon(Icons.money_off)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _actividadCiiu,
          decoration: const InputDecoration(labelText: 'Actividad Económica (CIIU)', prefixIcon: Icon(Icons.work)),
          dropdownColor: AppColors.blancoPuro,
          items: _ciiuActividades.map((String val) {
            return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(color: AppColors.textoOscuro, fontSize: 12)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _actividadCiiu = val);
          },
        ),
      ],
    );
  }

  Widget _buildStep3Condiciones() {
    // Amort French calculation
    final double teaDecimal = _teaReferencial / 100.0;
    final double tasaMensual = pow(1.0 + teaDecimal, 1.0 / 12.0) - 1.0;
    final int meses = int.tryParse(_plazoMeses) ?? 12;
    final double cuotaMensual = _montoSolicitado * tasaMensual / (1.0 - pow(1.0 + tasaMensual, -meses));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Condiciones Solicitadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulMarino)),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Monto Solicitado:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
            Text('S/ ${_montoSolicitado.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.turquesaOscuro)),
          ],
        ),
        Slider(
          value: _montoSolicitado,
          min: 500.0,
          max: 150000.0,
          divisions: 299,
          activeColor: AppColors.turquesaBrillante,
          onChanged: (val) {
            setState(() {
              _montoSolicitado = val;
            });
          },
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: _plazoMeses,
          decoration: const InputDecoration(labelText: 'Plazo (Meses)', prefixIcon: Icon(Icons.timelapse)),
          dropdownColor: AppColors.blancoPuro,
          items: _plazos.map((String val) {
            return DropdownMenuItem(value: val, child: Text('$val meses', style: const TextStyle(color: AppColors.textoOscuro)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _plazoMeses = val);
          },
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _moneda,
          decoration: const InputDecoration(labelText: 'Moneda', prefixIcon: Icon(Icons.currency_exchange)),
          dropdownColor: AppColors.blancoPuro,
          items: const [
            DropdownMenuItem(value: 'PEN', child: Text('PEN - Soles', style: TextStyle(color: AppColors.textoOscuro))),
            DropdownMenuItem(value: 'USD', child: Text('USD - Dólares', style: TextStyle(color: AppColors.textoOscuro))),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _moneda = val);
          },
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _garantia,
          decoration: const InputDecoration(labelText: 'Garantía Ofrecida', prefixIcon: Icon(Icons.shield)),
          dropdownColor: AppColors.blancoPuro,
          items: const [
            DropdownMenuItem(value: 'sin_garantia', child: Text('Sin Garantía / A Sola Firma', style: TextStyle(color: AppColors.textoOscuro))),
            DropdownMenuItem(value: 'aval', child: Text('Aval Fiador Solidario', style: TextStyle(color: AppColors.textoOscuro))),
            DropdownMenuItem(value: 'hipotecaria', child: Text('Garantía Hipotecaria', style: TextStyle(color: AppColors.textoOscuro))),
            DropdownMenuItem(value: 'prendaria', child: Text('Garantía Mobiliaria / Prenda', style: TextStyle(color: AppColors.textoOscuro))),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _garantia = val);
          },
        ),
        const SizedBox(height: 20),

        // Live calculation card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.azulMarino,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text('CUOTA MENSUAL ESTIMADA (MÉTODO FRANCÉS)', style: TextStyle(color: AppColors.turquesaBrillante, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('S/ ${cuotaMensual.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Tasa TEA Referencial: $_teaReferencial%', style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildStep4Firma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resumen y Firma de Solicitud', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulMarino)),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.grisClaro,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solicitante: ${_nombresController.text} ${_apellidosController.text}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('DNI: ${_dniController.text}', style: const TextStyle(fontSize: 12)),
              Text('Monto: $_moneda ${_montoSolicitado.toStringAsFixed(0)} • Plazo: $_plazoMeses meses', style: const TextStyle(fontSize: 12)),
              Text('Garantía: $_garantia', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('Firma Digital del Cliente (Lienzo Táctil)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.azulMarino)),
        const SizedBox(height: 8),

        // Custom touch signature pad
        Container(
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.azulMarino, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TouchSignatureCanvas(
              onSignatureChanged: (base64) {
                _signatureBase64 = base64;
              },
            ),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Checkbox(
              value: _declaraVeraz,
              activeColor: AppColors.azulMarino,
              onChanged: (val) {
                if (val != null) setState(() => _declaraVeraz = val);
              },
            ),
            const Expanded(
              child: Text(
                'El cliente declara bajo juramento que toda la información comercial suministrada es verídica.',
                style: TextStyle(fontSize: 11, color: AppColors.textoOscuro),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Touch Signature Canvas implementing gestures and custom painter
class TouchSignatureCanvas extends StatefulWidget {
  final Function(String base64Png)? onSignatureChanged;
  const TouchSignatureCanvas({super.key, this.onSignatureChanged});

  @override
  State<TouchSignatureCanvas> createState() => _TouchSignatureCanvasState();
}

class _TouchSignatureCanvasState extends State<TouchSignatureCanvas> {
  final List<Offset?> _points = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          _points.add(renderBox.globalToLocal(details.globalPosition));
        });
      },
      onPanEnd: (details) {
        _points.add(null);
        widget.onSignatureChanged?.call("MOCK_BASE64_SIGNATURE_DATA");
      },
      child: CustomPaint(
        painter: SignaturePainter(_points),
        size: Size.infinite,
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.azulMarino
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}
