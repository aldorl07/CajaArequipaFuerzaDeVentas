import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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

class SignatureWidget extends StatefulWidget {
  final Function(List<Offset?>) onSigned;
  final VoidCallback onClear;
  const SignatureWidget({super.key, required this.onSigned, required this.onClear});

  @override
  State<SignatureWidget> createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends State<SignatureWidget> {
  List<Offset?> points = [];

  void _clear() {
    setState(() {
      points.clear();
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borde),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  points.add(renderBox.globalToLocal(details.globalPosition));
                });
                widget.onSigned(points);
              },
              onPanEnd: (details) {
                points.add(null);
                widget.onSigned(points);
              },
              child: CustomPaint(
                painter: SignaturePainter(points),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.clear, size: 16, color: AppColors.rojoCoral),
            label: const Text('Limpiar Firma', style: TextStyle(color: AppColors.rojoCoral, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class EvaluarCreditoWizardScreen extends StatefulWidget {
  final String requestId;
  final String clientDni;
  final String clientName;
  final String creditType;
  final double amount;
  final int term;

  const EvaluarCreditoWizardScreen({
    super.key,
    required this.requestId,
    required this.clientDni,
    required this.clientName,
    required this.creditType,
    required this.amount,
    required this.term,
  });

  @override
  State<EvaluarCreditoWizardScreen> createState() => _EvaluarCreditoWizardScreenState();
}

class _EvaluarCreditoWizardScreenState extends State<EvaluarCreditoWizardScreen> {
  int _currentStep = 0;

  // Paso 1: Validación de Datos
  bool _validarNombre = false;
  bool _validarDni = false;
  bool _validarDireccion = false;
  bool _validarTelefono = false;

  // Paso 3: Confirmación de Visita e Firma
  bool _visitaRealizada = false;
  bool _clienteFirmo = false;
  List<Offset?> _signaturePoints = [];

  // Decisión del Comité
  String _decision = 'Aprobado'; // 'Aprobado', 'Condicionado', 'Rechazado'
  double _montoAprobado = 0.0;
  final _montoAprobadoController = TextEditingController();
  final _motivoRechazoController = TextEditingController();

  // Cálculos financieros
  late double _tea;
  late double _tem;
  late double _cuota;
  late double _totalPagar;

  @override
  void initState() {
    super.initState();
    _montoAprobado = widget.amount;
    _montoAprobadoController.text = widget.amount.toStringAsFixed(0);
    _calcularValoresFinancieros();
    _loadRequestDataAndCalculate();
  }

  @override
  void dispose() {
    _montoAprobadoController.dispose();
    _motivoRechazoController.dispose();
    super.dispose();
  }

  void _calcularValoresFinancieros() {
    _setDefaultTea();
    _tem = pow(1 + _tea, 1 / 12) - 1;
    final num factor = pow(1 + _tem, widget.term);
    _cuota = _montoAprobado * (_tem * factor) / (factor - 1);
    _totalPagar = _cuota * widget.term;
  }

  void _setDefaultTea() {
    if (widget.creditType.contains('MYPE')) {
      _tea = 0.4092; // 40.92% (Con seguro por defecto)
    } else if (widget.creditType.contains('Hipotecario')) {
      _tea = 0.089;
    } else if (widget.creditType.contains('Vehicular')) {
      _tea = 0.120;
    } else {
      _tea = 0.145;
    }
  }

  Future<void> _loadRequestDataAndCalculate() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('credit_requests')
          .doc(widget.requestId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final double? dbTea = (data['tea'] as num?)?.toDouble();
        if (dbTea != null) {
          _tea = dbTea;
        }
      }
    } catch (e) {
      debugPrint('Error al consultar datos de TEA: $e');
    }

    _tem = pow(1 + _tea, 1 / 12) - 1;
    _recalcularConMonto(_montoAprobado);
    if (mounted) {
      setState(() {});
    }
  }

  void _recalcularConMonto(double amount) {
    _montoAprobado = amount;
    final num factor = pow(1 + _tem, widget.term);
    _cuota = _montoAprobado * (_tem * factor) / (factor - 1);
    _totalPagar = _cuota * widget.term;
  }

  Future<void> _finalizarEvaluacion(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_decision == 'Rechazado') {
        final String motivo = _motivoRechazoController.text.trim();
        if (motivo.isEmpty) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Por favor, ingrese el motivo del rechazo.'),
              backgroundColor: AppColors.rojoCoral,
            ),
          );
          return;
        }

        await firestore.collection('credit_requests').doc(widget.requestId).update({
          'status': 'Rechazado',
          'rejection_reason': motivo,
        });

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Crédito Rechazado y cerrado con éxito.'),
            backgroundColor: AppColors.rojoCoral,
          ),
        );

        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
        return;
      }

      // Si es Aprobado o Condicionado
      await firestore.runTransaction((transaction) async {
        final clientRef = firestore.collection('clients').doc(widget.clientDni);
        final requestRef = firestore.collection('credit_requests').doc(widget.requestId);

        final clientDoc = await transaction.get(clientRef);
        if (!clientDoc.exists) {
          throw Exception('El cliente con DNI ${widget.clientDni} no está registrado.');
        }

        final clientData = clientDoc.data()!;
        final double savingsBalance = (clientData['savings_balance'] as num?)?.toDouble() ?? 0.0;

        transaction.update(requestRef, {
          'status': _decision,
          'approved_amount': _montoAprobado,
          'monthly_installment': _cuota,
          'total_payable': _totalPagar,
        });

        transaction.update(clientRef, {
          'current_loan_balance': _montoAprobado,
          'savings_balance': savingsBalance + _montoAprobado,
        });
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('Crédito ${_decision == "Condicionado" ? "Condicionado" : "Aprobado"} y Desembolsado con éxito.'),
          backgroundColor: AppColors.verdeCesped,
        ),
      );

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error en transacción de desembolso: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al finalizar desembolso: $e'),
          backgroundColor: AppColors.rojoCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('Evaluación de Crédito'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Indicador de pasos superior
          Container(
            color: AppColors.blancoPuro,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, 'Datos', Icons.person),
                _buildStepLine(0),
                _buildStepIndicator(1, 'Condiciones', Icons.calculate),
                _buildStepLine(1),
                _buildStepIndicator(2, 'Firma', Icons.border_color),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          // Botones de acción inferiores
          Container(
            color: AppColors.blancoPuro,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.azulMarino,
                      side: const BorderSide(color: AppColors.azulMarino),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Anterior', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  const SizedBox(),
                ElevatedButton(
                  onPressed: _isStepValid()
                      ? () {
                          if (_currentStep < 2) {
                            setState(() {
                              _currentStep++;
                            });
                          } else {
                            _finalizarEvaluacion(context);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulMarino,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  child: Text(
                    _currentStep == 2
                        ? (_decision == 'Rechazado' ? 'Finalizar y Rechazar' : 'Finalizar y Desembolsar')
                        : 'Siguiente',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title, IconData icon) {
    final bool isCompleted = stepIndex < _currentStep;
    final bool isActive = stepIndex == _currentStep;

    Color color = AppColors.textoMutado;
    if (isCompleted) color = AppColors.verdeCesped;
    if (isActive) color = AppColors.azulMarino;

    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStepIndex) {
    final bool isPassed = afterStepIndex < _currentStep;
    return Container(
      width: 40,
      height: 2,
      color: isPassed ? AppColors.verdeCesped : AppColors.borde,
    );
  }

  bool _isStepValid() {
    if (_currentStep == 0) {
      return _validarNombre && _validarDni && _validarDireccion && _validarTelefono;
    }
    if (_currentStep == 1) {
      if (_decision == 'Rechazado') {
        return _motivoRechazoController.text.trim().isNotEmpty;
      }
      if (_decision == 'Condicionado') {
        final double? parsed = double.tryParse(_montoAprobadoController.text);
        return parsed != null && parsed > 0 && parsed <= widget.amount;
      }
      return true;
    }
    if (_currentStep == 2) {
      if (_decision == 'Rechazado') {
        return true; // No requiere firma ni visita para rechazar
      }
      return _visitaRealizada && _clienteFirmo;
    }
    return false;
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1DataValidation();
      case 1:
        return _buildStep2CreditConditions();
      case 2:
        return _buildStep3Signature();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1DataValidation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Paso 1: Validación de Datos del Usuario',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
        ),
        const SizedBox(height: 8),
        const Text(
          'Revise y valide cada dato con la documentación física del cliente.',
          style: TextStyle(color: AppColors.textoMutado, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _buildValidationCard(
          title: 'Nombre Completo',
          value: widget.clientName,
          icon: Icons.person_outline,
          isValid: _validarNombre,
          onChanged: (val) => setState(() => _validarNombre = val ?? false),
        ),
        _buildValidationCard(
          title: 'DNI / Documento de Identidad',
          value: widget.clientDni,
          icon: Icons.badge_outlined,
          isValid: _validarDni,
          onChanged: (val) => setState(() => _validarDni = val ?? false),
        ),
        _buildValidationCard(
          title: 'Domicilio / Dirección del Cliente',
          value: 'Av. Arequipa 456, Cercado (Arequipa)',
          icon: Icons.home_outlined,
          isValid: _validarDireccion,
          onChanged: (val) => setState(() => _validarDireccion = val ?? false),
        ),
        _buildValidationCard(
          title: 'Teléfono de Contacto',
          value: '999888777',
          icon: Icons.phone_outlined,
          isValid: _validarTelefono,
          onChanged: (val) => setState(() => _validarTelefono = val ?? false),
        ),
      ],
    );
  }

  Widget _buildValidationCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isValid,
    required ValueChanged<bool?> onChanged,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isValid ? AppColors.verdeCesped : AppColors.borde, width: isValid ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.azulMarino.withValues(alpha: 0.08),
              child: Icon(icon, color: AppColors.azulMarino, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textoMutado)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                ],
              ),
            ),
            Checkbox(
              value: isValid,
              activeColor: AppColors.verdeCesped,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2CreditConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Paso 2: Decisión del Comité y Condiciones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
        ),
        const SizedBox(height: 8),
        const Text(
          'Seleccione la decisión del comité de crédito y revise las condiciones financieras.',
          style: TextStyle(color: AppColors.textoMutado, fontSize: 13),
        ),
        const SizedBox(height: 16),
        
        const Text(
          'Decisión del Comité:',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Aprobar'),
                selected: _decision == 'Aprobado',
                selectedColor: AppColors.verdeCesped.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _decision == 'Aprobado' ? AppColors.verdeCesped : AppColors.textoOscuro,
                ),
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _decision = 'Aprobado';
                      _recalcularConMonto(widget.amount);
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Condicionar'),
                selected: _decision == 'Condicionado',
                selectedColor: AppColors.amarilloMostaza.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _decision == 'Condicionado' ? AppColors.amarilloMostaza : AppColors.textoOscuro,
                ),
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _decision = 'Condicionado';
                      final double valInput = double.tryParse(_montoAprobadoController.text) ?? widget.amount;
                      _recalcularConMonto(valInput);
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Rechazar'),
                selected: _decision == 'Rechazado',
                selectedColor: AppColors.rojoCoral.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _decision == 'Rechazado' ? AppColors.rojoCoral : AppColors.textoOscuro,
                ),
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _decision = 'Rechazado';
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_decision == 'Condicionado') ...[
          TextFormField(
            controller: _montoAprobadoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Monto Aprobado Reducido (S/)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppColors.azulMarino),
            ),
            onChanged: (val) {
              final double? parsed = double.tryParse(val);
              if (parsed != null && parsed > 0 && parsed <= widget.amount) {
                setState(() {
                  _recalcularConMonto(parsed);
                });
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        if (_decision == 'Rechazado') ...[
          TextFormField(
            controller: _motivoRechazoController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Motivo del Rechazo',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.report_problem_outlined, color: AppColors.rojoCoral),
            ),
            onChanged: (val) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
        ],

        if (_decision != 'Rechazado')
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildFinanceRow('Tipo de Crédito', widget.creditType, isBold: true),
                  const Divider(height: 20),
                  _buildFinanceRow('Monto Solicitado', 'S/ ${widget.amount.toStringAsFixed(2)}'),
                  _buildFinanceRow('Monto Aprobado', 'S/ ${_montoAprobado.toStringAsFixed(2)}', valueColor: AppColors.azulMarino, isBold: true),
                  _buildFinanceRow('Plazo', '${widget.term} meses'),
                  const Divider(height: 20),
                  _buildFinanceRow('Tasa de Interés Anual (TEA)', '${(_tea * 100).toStringAsFixed(2)}% TEA', valueColor: AppColors.naranjaOcre),
                  _buildFinanceRow('Tasa de Interés Mensual (TEM)', '${(_tem * 100).toStringAsFixed(2)}% TEM', valueColor: AppColors.turquesaOscuro),
                  const Divider(height: 20),
                  _buildFinanceRow('Cuota Fija Estimada', 'S/ ${_cuota.toStringAsFixed(2)} / mes', valueColor: AppColors.verdeCesped, isBold: true),
                  _buildFinanceRow('Total de Intereses', 'S/ ${(_totalPagar - _montoAprobado).toStringAsFixed(2)}'),
                  _buildFinanceRow('Total a Pagar', 'S/ ${_totalPagar.toStringAsFixed(2)}', valueColor: AppColors.azulMarino, isBold: true),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFinanceRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textoMutado)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textoOscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Signature() {
    if (_decision == 'Rechazado') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Paso 3: Confirmación de Rechazo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.rojoCoral),
          ),
          const SizedBox(height: 8),
          const Text(
            'El expediente se cerrará y no se registrarán cargos de desembolso.',
            style: TextStyle(color: AppColors.textoMutado, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del Rechazo:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildFinanceRow('Cliente', widget.clientName),
                  _buildFinanceRow('DNI', widget.clientDni),
                  _buildFinanceRow('Monto Solicitado', 'S/ ${widget.amount.toStringAsFixed(2)}'),
                  const Divider(height: 20),
                  const Text(
                    'Motivo de Rechazo:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.rojoCoral, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _motivoRechazoController.text.isNotEmpty ? _motivoRechazoController.text : '(Sin especificar)',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textoOscuro),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Paso 3: Visita y Firma Digital del Cliente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
        ),
        const SizedBox(height: 8),
        const Text(
          'Confirme la visita comercial y solicite la firma del cliente.',
          style: TextStyle(color: AppColors.textoMutado, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: CheckboxListTile(
            title: const Text(
              'Visita Realizada',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro, fontSize: 14),
            ),
            subtitle: const Text('Confirmo que realicé la visita en el domicilio del cliente.', style: TextStyle(fontSize: 12)),
            value: _visitaRealizada,
            activeColor: AppColors.verdeCesped,
            onChanged: (val) => setState(() => _visitaRealizada = val ?? false),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Firma Digital del Cliente',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro, fontSize: 14),
        ),
        const SizedBox(height: 4),
        const Text(
          'Solicite al cliente que firme con el dedo dentro del recuadro.',
          style: TextStyle(fontSize: 12, color: AppColors.textoMutado),
        ),
        const SizedBox(height: 10),
        SignatureWidget(
          onSigned: (points) {
            setState(() {
              _signaturePoints = points;
              _clienteFirmo = points.isNotEmpty && points.any((p) => p != null);
            });
          },
          onClear: () {
            setState(() {
              _signaturePoints.clear();
              _clienteFirmo = false;
            });
          },
        ),
      ],
    );
  }
}
