import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../solicitud/nueva_solicitud_screen.dart';

class FichaClienteScreen extends StatefulWidget {
  final String clientDni;
  const FichaClienteScreen({super.key, required this.clientDni});

  @override
  State<FichaClienteScreen> createState() => _FichaClienteScreenState();
}

class _FichaClienteScreenState extends State<FichaClienteScreen> {
  Map<String, dynamic>? _client;
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
        setState(() {
          _client = docSnapshot.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _client = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading client from Firestore: $e');
      setState(() {
        _client = null;
        _isLoading = false;
      });
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
                            color: riskColor.withOpacity(0.15),
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
                                  color: (item['color'] as Color).withOpacity(0.2),
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
            const SizedBox(height: 24),

            // Main CTA Button
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
          backgroundColor: iconColor.withOpacity(0.12),
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
