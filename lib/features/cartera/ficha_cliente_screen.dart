import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../solicitud/nueva_solicitud_screen.dart';
import 'registrar_desertor_screen.dart';
import 'evaluar_credito_wizard_screen.dart';

class FichaClienteScreen extends StatefulWidget {
  final String clientDni;
  const FichaClienteScreen({super.key, required this.clientDni});

  @override
  State<FichaClienteScreen> createState() => _FichaClienteScreenState();
}

class _FichaClienteScreenState extends State<FichaClienteScreen> {
  Map<String, dynamic>? _client;
  Map<String, dynamic>? _activeRequest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientDetails();
  }

  Future<void> _loadClientDetails() async {
    setState(() => _isLoading = true);
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .doc(widget.clientDni)
          .get();

      if (docSnapshot.exists) {
        // Consultar si tiene una solicitud de crédito pendiente
        final requestsSnapshot = await FirebaseFirestore.instance
            .collection('credit_requests')
            .where('dni', isEqualTo: widget.clientDni)
            .where('status', isEqualTo: 'Pendiente')
            .limit(1)
            .get();

        setState(() {
          _client = docSnapshot.data();
          if (requestsSnapshot.docs.isNotEmpty) {
            _activeRequest = requestsSnapshot.docs.first.data();
            _activeRequest!['id'] = requestsSnapshot.docs.first.id;
          } else {
            _activeRequest = null;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _client = null;
          _activeRequest = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading client/requests from Firestore: $e');
      setState(() {
        _client = null;
        _activeRequest = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _evaluarSolicitud(
    BuildContext context, {
    required String id,
    required String dni,
    required double amount,
    required bool aprobar,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (aprobar) {
        await firestore.runTransaction((transaction) async {
          final clientRef = firestore.collection('clients').doc(dni);
          final requestRef = firestore.collection('credit_requests').doc(id);

          final clientDoc = await transaction.get(clientRef);
          if (!clientDoc.exists) {
            throw Exception('El cliente con DNI $dni no está registrado en la base de datos de Fuerza de Ventas.');
          }

          final clientData = clientDoc.data()!;
          final double savingsBalance = (clientData['savings_balance'] as num?)?.toDouble() ?? 0.0;

          transaction.update(requestRef, {'status': 'Aprobado'});
          transaction.update(clientRef, {
            'current_loan_balance': amount,
            'savings_balance': savingsBalance + amount,
          });
        });

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Solicitud de crédito APROBADA con éxito. Saldo y deuda actualizados en Firestore.'),
            backgroundColor: AppColors.verdeCesped,
          ),
        );
      } else {
        await firestore.collection('credit_requests').doc(id).update({
          'status': 'Rechazado',
        });

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Solicitud de crédito RECHAZADA.'),
            backgroundColor: AppColors.rojoCoral,
          ),
        );
      }
      
      // Recargar datos
      _loadClientDetails();
    } catch (e) {
      debugPrint('Error evaluando solicitud de crédito en Ficha: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al evaluar la solicitud: $e'),
          backgroundColor: AppColors.rojoCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando Ficha...')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.turquesaBrillante)),
      );
    }

    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cliente No Encontrado')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.rojoCoral),
              const SizedBox(height: 16),
              const Text('No se encontraron detalles del cliente.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('REGRESAR'),
              ),
            ],
          ),
        ),
      );
    }

    final String name = _client!['name'] ?? 'Sin Nombre';
    final String dni = _client!['dni'] ?? '--------';
    final String phone = _client!['phone'] ?? '---';
    final String address = _client!['address'] ?? '---';
    final String riskTier = _client!['credit_risk_tier'] ?? 'Bajo';
    final double savingsBalance = _client!['savings_balance'] ?? 0.0;
    final double currentLoanBalance = _client!['current_loan_balance'] ?? 0.0;
    final String behavior = _client!['payment_behavior'] ?? 'Excelente';
    final bool isDesertor = _client!['status'] == 'Desertor' || (_client!['isDeserted'] ?? false);

    // Pre-evaluación Express logic
    String preEvalStatus;
    String preEvalMessage;
    Color preEvalColor;
    IconData preEvalIcon;
    int bureauScore;

    if (isDesertor) {
      preEvalStatus = 'CLIENTE DESERTOR';
      preEvalMessage = 'Este cliente se encuentra registrado como DESERTOR. Motivo: ${_client!['desertion_details']?['motivo_desercion'] ?? 'No especificado'}.';
      preEvalColor = AppColors.rojoCoral;
      preEvalIcon = Icons.person_off_outlined;
      bureauScore = 0;
    } else if (behavior == 'Excelente') {
      preEvalStatus = 'PRE-APROBADO (Apto)';
      preEvalMessage = 'El cliente califica para una oferta recurrente de hasta S/ 50,000 con Tasa Preferencial de 22.5% TEA. Aprobación inmediata.';
      preEvalColor = AppColors.verdeCesped;
      preEvalIcon = Icons.check_circle;
      bureauScore = 780;
    } else if (behavior == 'Regular') {
      preEvalStatus = 'APROBADO CONDICIONAL';
      preEvalMessage = 'El cliente califica para un crédito de hasta S/ 15,000. Requiere sustento de ingresos complementario y firma de aval solidario.';
      preEvalColor = AppColors.amarilloMostaza;
      preEvalIcon = Icons.info_outline;
      bureauScore = 620;
    } else {
      preEvalStatus = 'NO APTO / RECHAZADO';
      preEvalMessage = 'No elegible para financiamiento. El cliente presenta un nivel de riesgo crítico con atrasos SBS superiores a 30 días.';
      preEvalColor = AppColors.rojoCoral;
      preEvalIcon = Icons.cancel_outlined;
      bureauScore = 340;
    }

    // Risk tier colors
    Color riskColor;
    switch (riskTier.toLowerCase()) {
      case 'bajo':
        riskColor = AppColors.verdeCesped;
        break;
      case 'medio':
        riskColor = AppColors.naranjaOcre;
        break;
      case 'alto':
        riskColor = AppColors.rojoCoral;
        break;
      default:
        riskColor = AppColors.textoMutado;
    }

    // Payment behavior configuration
    List<Map<String, dynamic>> paymentHistory = [];
    if (behavior == 'Excelente') {
      paymentHistory = [
        {'month': 'Ene', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'Feb', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'Mar', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'Abr', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'May', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'Jun', 'status': 'Al día', 'color': AppColors.verdeCesped},
      ];
    } else if (behavior == 'Regular') {
      paymentHistory = [
        {'month': 'Ene', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'Feb', 'status': 'Atraso 5d', 'color': AppColors.amarilloMostaza},
        {'month': 'Mar', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'Abr', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'May', 'status': 'Atraso 3d', 'color': AppColors.amarilloMostaza},
        {'month': 'Jun', 'status': 'Al día', 'color': AppColors.verdeCesped},
      ];
    } else {
      paymentHistory = [
        {'month': 'Ene', 'status': 'Atraso 12d', 'color': AppColors.rojoCoral},
        {'month': 'Feb', 'status': 'Atraso 20d', 'color': AppColors.rojoCoral},
        {'month': 'Mar', 'status': 'Atraso 8d', 'color': AppColors.rojoCoral},
        {'month': 'Abr', 'status': 'Al día', 'color': AppColors.verdeCesped},
        {'month': 'May', 'status': 'Atraso 30d', 'color': AppColors.rojoCoral},
        {'month': 'Jun', 'status': 'Atraso 15d', 'color': AppColors.rojoCoral},
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha del Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card (Client name, DNI, Risk)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulMarino,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: riskColor, width: 1),
                          ),
                          child: Text(
                            'Riesgo: $riskTier',
                            style: TextStyle(
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'DNI: $dni',
                      style: const TextStyle(color: AppColors.textoMutado, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // General Info rows
                    _buildInfoRow(Icons.phone, 'Teléfono', phone),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.location_on, 'Dirección', address),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Products Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Productos Activos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProductRow(
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.turquesaOscuro,
                      title: 'Cuenta de Ahorros Persona',
                      subtitle: 'Saldo disponible',
                      amount: savingsBalance,
                    ),
                    const Divider(height: 24),
                    _buildProductRow(
                      icon: Icons.monetization_on,
                      iconColor: AppColors.verdeCesped,
                      title: 'Crédito Vigente - Microempresa',
                      subtitle: 'Monto pendiente de pago',
                      amount: currentLoanBalance,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Behavior / credit score section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Comportamiento de Pago',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Calificación Interna:',
                          style: TextStyle(fontSize: 14, color: AppColors.textoOscuro),
                        ),
                        Text(
                          behavior.toUpperCase(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: behavior == 'Excelente'
                                ? AppColors.verdeCesped
                                : (behavior == 'Regular' ? AppColors.amarilloMostaza : AppColors.rojoCoral),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Historial de pagos (últimos 6 meses):',
                      style: TextStyle(fontSize: 12, color: AppColors.textoMutado),
                    ),
                    const SizedBox(height: 12),
                    
                    // Simple Timeline/Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: paymentHistory.map((item) {
                        return Expanded(
                          child: Column(
                            children: [
                              Text(
                                item['month'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: item['color'] as Color, width: 1.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['status'],
                                style: TextStyle(
                                  fontSize: 9,
                                  color: item['color'] as Color,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pre-evaluación Express (RF-42 & Use Case)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Pre-evaluación Express (Buró)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
            ),
            Card(
              color: preEvalColor.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: preEvalColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(preEvalIcon, color: preEvalColor, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            preEvalStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: preEvalColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      preEvalMessage,
                      style: const TextStyle(fontSize: 13, color: AppColors.textoOscuro),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Score de Buró (Simulado):',
                          style: TextStyle(fontSize: 12, color: AppColors.textoMutado),
                        ),
                        Text(
                          bureauScore > 0 ? '$bureauScore pts' : 'N/A',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_activeRequest != null) ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.turquesaBrillante,
                        foregroundColor: AppColors.azulMarino,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EvaluarCreditoWizardScreen(
                              requestId: _activeRequest!['id'],
                              clientDni: dni,
                              clientName: name,
                              creditType: _activeRequest!['credit_type'] ?? 'Crédito',
                              amount: (_activeRequest!['amount'] as num).toDouble(),
                              term: _activeRequest!['term_months'] ?? 12,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadClientDetails();
                        }
                      },
                      icon: const Icon(Icons.rate_review_outlined, size: 20),
                      label: const Text('EVALUAR CRÉDITO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rojoCoral,
                        side: const BorderSide(color: AppColors.rojoCoral, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _evaluarSolicitud(
                        context,
                        id: _activeRequest!['id'],
                        dni: dni,
                        amount: (_activeRequest!['amount'] as num).toDouble(),
                        aprobar: false,
                      ),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text(
                        'RECHAZAR SOLICITUD DE CRÉDITO',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ] else ...[
                  if (!isDesertor) ...[
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NuevaSolicitudScreen(prefilledDni: dni),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('NUEVA SOLICITUD DE CRÉDITO'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rojoCoral,
                        side: const BorderSide(color: AppColors.rojoCoral, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegistrarDesertorScreen(
                              clientDni: dni,
                              clientName: name,
                            ),
                          ),
                        );
                        if (result == true) {
                          // Refresh client details
                          _loadClientDetails();
                        }
                      },
                      icon: Icon(isDesertor ? Icons.edit_note : Icons.person_off_outlined, size: 20),
                      label: Text(
                        isDesertor ? 'MODIFICAR DESERCIÓN' : 'REGISTRAR DESERCIÓN',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.azulMarino, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textoMutado),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoOscuro,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double amount,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          radius: 20,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textoMutado),
              ),
            ],
          ),
        ),
        Text(
          'S/ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.azulMarino,
          ),
        ),
      ],
    );
  }
}
