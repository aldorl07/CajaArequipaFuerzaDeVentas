import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_service.dart';

class NuevaSolicitudScreen extends StatefulWidget {
  final String? prefilledDni;
  const NuevaSolicitudScreen({super.key, this.prefilledDni});

  @override
  State<NuevaSolicitudScreen> createState() => _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState extends State<NuevaSolicitudScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _incomeController = TextEditingController();
  
  String _selectedTerm = '12';
  String _selectedDestination = 'Capital de Trabajo';
  
  // Document capture simulation state
  String? _docFrontPath;
  String? _docBackPath;
  bool _isCapturingFront = false;
  bool _isCapturingBack = false;

  // Credit Bureau simulation state
  bool _isCheckingBureau = false;
  int? _bureauScore;
  String? _bureauRating; // 'Bajo Riesgo', 'Medio Riesgo', 'Alto Riesgo'
  Color? _bureauColor;

  final List<String> _terms = ['6', '12', '18', '24', '36', '48'];
  final List<String> _destinations = [
    'Capital de Trabajo',
    'Activo Fijo (Maquinaria)',
    'Consumo / Personal',
    'Vivienda / Construcción'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefilledDni != null) {
      _dniController.text = widget.prefilledDni!;
      _autoFillClientDetails(widget.prefilledDni!);
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _autoFillClientDetails(String dni) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('clients').doc(dni).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          final double sugAmount = (data['credit_renewal_amount'] as num?)?.toDouble() ?? 10000.0;
          _amountController.text = sugAmount.toStringAsFixed(0);
          _incomeController.text = '2500';
        });
      }
    } catch (e) {
      debugPrint('Error autofilling client details from Firestore: $e');
    }
  }

  Future<void> _simulateCapture(bool isFront) async {
    setState(() {
      if (isFront) _isCapturingFront = true;
      else _isCapturingBack = true;
    });

    // Simulate shutter delay
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      // We write a simulated file to document directory to act as physical capture
      final directory = await getApplicationDocumentsDirectory();
      final String side = isFront ? 'front' : 'back';
      final String fileName = 'dni_${_dniController.text.isNotEmpty ? _dniController.text : "temp"}_$side.txt';
      final File mockImageFile = File('${directory.path}/$fileName');
      
      // Write some fake bytes or text representing photo metadata
      await mockImageFile.writeAsString('CAJA AREQUIPA MOCK DNI IMAGE SOURCE METADATA: $side');

      if (mounted) {
        setState(() {
          if (isFront) {
            _docFrontPath = mockImageFile.path;
            _isCapturingFront = false;
          } else {
            _docBackPath = mockImageFile.path;
            _isCapturingBack = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturingFront = false;
          _isCapturingBack = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar archivo: $e')),
        );
      }
    }
  }

  Future<void> _checkCreditBureau() async {
    if (_dniController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese un DNI válido de 8 dígitos para consultar el Buró.'),
          backgroundColor: AppColors.rojoCoral,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingBureau = true;
      _bureauScore = null;
      _bureauRating = null;
    });

    // Simulate bureau verification network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Simulate response based on the DNI input
    final String dni = _dniController.text;
    int score = 680; // default average
    String rating = 'Medio Riesgo';
    Color ratingColor = AppColors.naranjaOcre;

    if (dni.startsWith('4') || dni.startsWith('1')) {
      score = 820; // Excellent credit history
      rating = 'Bajo Riesgo (Verde)';
      ratingColor = AppColors.verdeCesped;
    } else if (dni.startsWith('2') || dni.startsWith('3')) {
      score = 540; // Mid-risk
      rating = 'Riesgo Moderado (Amarillo)';
      ratingColor = AppColors.amarilloMostaza;
    } else if (dni.startsWith('0') || dni.startsWith('9')) {
      score = 310; // High risk or delinquent
      rating = 'Alto Riesgo (Rojo)';
      ratingColor = AppColors.rojoCoral;
    }

    setState(() {
      _isCheckingBureau = false;
      _bureauScore = score;
      _bureauRating = rating;
      _bureauColor = ratingColor;
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_docFrontPath == null || _docBackPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe capturar la foto de DNI (Frontal y Reverso).'),
          backgroundColor: AppColors.rojoCoral,
        ),
      );
      return;
    }

    if (_bureauScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe realizar la consulta del Buró de Crédito antes de guardar.'),
          backgroundColor: AppColors.rojoCoral,
        ),
      );
      return;
    }

    final connProv = Provider.of<ConnectivityProvider>(context, listen: false);
    final syncProv = Provider.of<SyncProvider>(context, listen: false);

    final String dni = _dniController.text;
    final Map<String, dynamic> request = {
      'client_dni': dni,
      'client_name': _nameController.text,
      'amount': double.parse(_amountController.text),
      'term_months': int.parse(_selectedTerm),
      'destination': _selectedDestination,
      'monthly_income': double.parse(_incomeController.text),
      'bureau_score': _bureauScore,
      'bureau_rating': _bureauRating,
      'doc_front_path': _docFrontPath,
      'doc_back_path': _docBackPath,
      'status': connProv.isOnline ? 'Sent' : 'PendingSync', // Online goes sent immediately, Offline gets queued
      'created_at': DateTime.now().toIso8601String(),
    };

    // Save directly to Firestore (Firestore supports offline persistence natively)
    try {
      await FirebaseFirestore.instance.collection('credit_requests').doc(dni).set(request);
    } catch (e) {
      debugPrint('Firestore save error (queued offline): $e');
    }

    if (!mounted) return;

    if (connProv.isOnline) {
      // Sync immediately in the background
      syncProv.syncPendingRequests(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud transmitida con éxito al Core Bancario.'),
          backgroundColor: AppColors.verdeCesped,
        ),
      );
    } else {
      // Queue locally in provider count
      await syncProv.updatePendingCount();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sin conexión. Solicitud guardada localmente en Firestore (se sincronizará automáticamente).'),
          backgroundColor: AppColors.amarilloMostaza,
        ),
      );
    }

    // Go back to dashboard list
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final connProv = Provider.of<ConnectivityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Solicitud'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Offline Status Banner
              if (!connProv.isOnline)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.amarilloMostaza.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.amarilloMostaza, width: 0.5),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.offline_pin, color: AppColors.amarilloMostaza),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Usted se encuentra fuera de línea. La solicitud se almacenará en el dispositivo.',
                          style: TextStyle(fontSize: 12, color: AppColors.azulMarino, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              // SECTION 1: Client Data
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  '1. Datos del Cliente',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // DNI
                      TextFormField(
                        controller: _dniController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textoOscuro),
                        maxLength: 8,
                        decoration: InputDecoration(
                          labelText: 'DNI del Cliente',
                          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.azulMarino),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: AppColors.turquesaOscuro),
                            tooltip: 'Buscar en cartera',
                            onPressed: () {
                              if (_dniController.text.isNotEmpty) {
                                _autoFillClientDetails(_dniController.text);
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'El DNI debe tener 8 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        style: const TextStyle(color: AppColors.textoOscuro),
                        decoration: const InputDecoration(
                          labelText: 'Nombre Completo',
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.azulMarino),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese el nombre del cliente';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 2: Loan Details
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  '2. Detalles de Solicitud',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textoOscuro),
                        decoration: const InputDecoration(
                          labelText: 'Monto Solicitado (S/)',
                          prefixIcon: Icon(Icons.monetization_on_outlined, color: AppColors.azulMarino),
                        ),
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Ingrese un monto mayor a cero';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Monthly Income
                      TextFormField(
                        controller: _incomeController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textoOscuro),
                        decoration: const InputDecoration(
                          labelText: 'Ingresos Mensuales Declarados (S/)',
                          prefixIcon: Icon(Icons.payments_outlined, color: AppColors.azulMarino),
                        ),
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Ingrese un ingreso mensual válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Term (Plazo)
                      DropdownButtonFormField<String>(
                        value: _selectedTerm,
                        decoration: const InputDecoration(
                          labelText: 'Plazo (Meses)',
                          prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.azulMarino),
                        ),
                        dropdownColor: AppColors.blancoPuro,
                        items: _terms.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text('$val meses', style: const TextStyle(color: AppColors.textoOscuro)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTerm = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Destination
                      DropdownButtonFormField<String>(
                        value: _selectedDestination,
                        decoration: const InputDecoration(
                          labelText: 'Destino del Crédito',
                          prefixIcon: Icon(Icons.storefront_outlined, color: AppColors.azulMarino),
                        ),
                        dropdownColor: AppColors.blancoPuro,
                        items: _destinations.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val, style: const TextStyle(color: AppColors.textoOscuro, fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDestination = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 3: Document Capture (Offline compliant)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  '3. Captura de Documentos (DNI)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Front Card
                      Expanded(
                        child: _buildDniCaptureBox(
                          title: 'DNI Frontal',
                          path: _docFrontPath,
                          isCapturing: _isCapturingFront,
                          onTap: () => _simulateCapture(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Back Card
                      Expanded(
                        child: _buildDniCaptureBox(
                          title: 'DNI Reverso',
                          path: _docBackPath,
                          isCapturing: _isCapturingBack,
                          onTap: () => _simulateCapture(false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 4: Credit Bureau (Mock Endpoint verification)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  '4. Consulta de Buró de Crédito',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isCheckingBureau ? null : _checkCreditBureau,
                        icon: _isCheckingBureau
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.azulMarino),
                                ),
                              )
                            : const Icon(Icons.network_ping, size: 18),
                        label: Text(_isCheckingBureau ? 'VERIFICANDO...' : 'CONSULTAR BURÓ DE CRÉDITO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.turquesaOscuro,
                          foregroundColor: AppColors.blancoPuro,
                        ),
                      ),
                      if (_bureauScore != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bureauColor!.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _bureauColor!, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Resultado:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textoOscuro),
                                  ),
                                  Text(
                                    'Score: $_bureauScore / 1000',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textoOscuro),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Evaluación: $_bureauRating',
                                style: TextStyle(
                                  color: _bureauColor!,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Save/Submit Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  child: const Text('TRANSMITIR / GUARDAR SOLICITUD'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDniCaptureBox({
    required String title,
    required String? path,
    required bool isCapturing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isCapturing ? null : onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.grisClaro,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: path != null ? AppColors.turquesaBrillante : AppColors.borde,
            width: path != null ? 2.0 : 1.0,
          ),
        ),
        child: isCapturing
            ? const Center(child: CircularProgressIndicator(color: AppColors.azulMarino))
            : path != null
                ? Stack(
                    children: [
                      // Draw a simulated digital ID card representation
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            color: AppColors.turquesaOscuro.withOpacity(0.1),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('PERÚ DNI', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.azulMarino)),
                                    Icon(Icons.credit_card, size: 10, color: AppColors.azulMarino),
                                  ],
                                ),
                                Container(
                                  width: 25,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors.azulMarino.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Icon(Icons.person, size: 20, color: Colors.white70),
                                ),
                                Text(
                                  'DNI: ${_dniController.text.isNotEmpty ? _dniController.text : "--------"}',
                                  style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Check icon on corner
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.verdeCesped,
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, color: AppColors.textoMutado, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 12, color: AppColors.textoMutado, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tocar para capturar',
                        style: TextStyle(fontSize: 9, color: AppColors.textoMutado),
                      ),
                    ],
                  ),
      ),
    );
  }
}
