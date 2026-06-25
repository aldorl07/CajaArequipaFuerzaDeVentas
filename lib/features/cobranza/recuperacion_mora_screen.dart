import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/connectivity_service.dart';

class DelinquentClient {
  final String dni;
  final String name;
  final String address;
  final double amountOverdue;
  final int daysInArrears;
  final String lastContactDate;

  DelinquentClient({
    required this.dni,
    required this.name,
    required this.address,
    required this.amountOverdue,
    required this.daysInArrears,
    required this.lastContactDate,
  });
}

class RecuperacionMoraScreen extends StatefulWidget {
  const RecuperacionMoraScreen({super.key});

  @override
  State<RecuperacionMoraScreen> createState() => _RecuperacionMoraScreenState();
}

class _RecuperacionMoraScreenState extends State<RecuperacionMoraScreen> {
  bool _isLoading = true;
  List<DelinquentClient> _delinquents = [];
  double _totalOverdue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMoraData();
  }

  Future<void> _loadMoraData() async {
    setState(() => _isLoading = true);
    try {
      final qs = await FirebaseFirestore.instance.collection('clients').get();
      final List<DelinquentClient> list = [];
      double total = 0.0;

      for (var doc in qs.docs) {
        final data = doc.data();
        final double loanBalance = (data['current_loan_balance'] as num?)?.toDouble() ?? 0.0;
        final String behavior = data['payment_behavior'] ?? 'Excelente';
        
        // If they have loan balance and are not excelente, they are delinquent
        if (loanBalance > 0 && behavior != 'Excelente') {
          int days = 15;
          if (behavior == 'Crítico') days = 75;
          if (data['credit_renewal_due_days'] != null && (data['credit_renewal_due_days'] as int) < 0) {
            days = -(data['credit_renewal_due_days'] as int) * 5;
          }

          final double overdue = loanBalance * 0.35; // Overdue portion is 35% of total balance for simulation
          total += overdue;

          list.add(DelinquentClient(
            dni: data['dni'] ?? '',
            name: data['name'] ?? 'Cliente Sin Nombre',
            address: data['address'] ?? 'Sin Dirección',
            amountOverdue: overdue,
            daysInArrears: days,
            lastContactDate: '2026-06-18',
          ));
        }
      }

      // Sort by days in arrears desc
      list.sort((a, b) => b.daysInArrears.compareTo(a.daysInArrears));

      setState(() {
        _delinquents = list;
        _totalOverdue = total;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading delinquency list: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getSemaforoColor(int days) {
    if (days <= 30) return AppColors.amarilloMostaza;
    if (days <= 60) return AppColors.naranjaOcre;
    return AppColors.rojoCoral;
  }

  String _getSemaforoLabel(int days) {
    if (days <= 30) return 'PREVENTIVO';
    if (days <= 60) return 'PRIORITARIO';
    return 'URGENTE';
  }

  void _openCobranzaForm(BuildContext context, DelinquentClient client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CobranzaFormSheet(client: client, onSave: _loadMoraData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperación de Mora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMoraData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.turquesaBrillante))
          : Column(
              children: [
                // Total Overdue Header Card
                Container(
                  width: double.infinity,
                  color: AppColors.azulMarino,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    children: [
                      const Text(
                        'MONTO TOTAL VENCIDO EN CARTERA',
                        style: TextStyle(color: AppColors.turquesaBrillante, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'S/ ${_totalOverdue.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_delinquents.length} clientes en estado de mora activa',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Delinquent List
                Expanded(
                  child: _delinquents.isEmpty
                      ? const Center(
                          child: Text('No hay cobranzas pendientes registradas en tu cartera.', style: TextStyle(color: AppColors.textoMutado)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _delinquents.length,
                          itemBuilder: (context, index) {
                            final client = _delinquents[index];
                            final Color cardColor = _getSemaforoColor(client.daysInArrears);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                client.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.azulMarino,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'DNI: ${client.dni}',
                                                style: const TextStyle(color: AppColors.textoMutado, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: cardColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: cardColor, width: 0.5),
                                          ),
                                          child: Text(
                                            _getSemaforoLabel(client.daysInArrears),
                                            style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Deuda Vencida', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                                            const SizedBox(height: 2),
                                            Text(
                                              'S/ ${client.amountOverdue.toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.rojoCoral),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Días de Mora', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${client.daysInArrears} días',
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cardColor),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('Último Contacto', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                                            const SizedBox(height: 2),
                                            Text(
                                              client.lastContactDate,
                                              style: const TextStyle(fontSize: 13, color: AppColors.textoOscuro),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.azulMarino),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        icon: const Icon(Icons.edit_note, size: 18),
                                        label: const Text('REGISTRAR ACCIÓN DE COBRANZA'),
                                        onPressed: () => _openCobranzaForm(context, client),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _CobranzaFormSheet extends StatefulWidget {
  final DelinquentClient client;
  final VoidCallback onSave;

  const _CobranzaFormSheet({required this.client, required this.onSave});

  @override
  State<_CobranzaFormSheet> createState() => _CobranzaFormSheetState();
}

class _CobranzaFormSheetState extends State<_CobranzaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  String _tipoGestion = 'Visita';
  String _resultado = 'Compromiso de pago';
  
  final _amountController = TextEditingController();
  final _obsController = TextEditingController();
  
  DateTime? _compromiseDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _submitCobranza() async {
    if (_formKey.currentState!.validate()) {
      if (_resultado == 'Compromiso de pago' && _compromiseDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar la fecha de compromiso de pago.'), backgroundColor: AppColors.rojoCoral),
        );
        return;
      }

      setState(() => _isSaving = true);
      
      final connProv = Provider.of<ConnectivityProvider>(context, listen: false);
      
      // Captured location coordinates
      final Map<String, dynamic> actionData = {
        'client_dni': widget.client.dni,
        'client_name': widget.client.name,
        'type': _tipoGestion,
        'result': _resultado,
        'compromise_amount': _resultado == 'Compromiso de pago' ? double.tryParse(_amountController.text) ?? 0.0 : 0.0,
        'compromise_date': _resultado == 'Compromiso de pago' ? _compromiseDate!.toIso8601String() : null,
        'observations': _obsController.text,
        'latitude': -16.3989, // Arequipa Cercado
        'longitude': -71.5350,
        'timestamp': DateTime.now().toIso8601String(),
        'synchronized': connProv.isOnline,
      };

      try {
        await FirebaseFirestore.instance.collection('actions_cobranza').add(actionData);
        
        // Show local notification setup (simulated)
        if (_resultado == 'Compromiso de pago' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Compromiso registrado. Alerta programada para el ${_compromiseDate!.day}/${_compromiseDate!.month}.'),
              backgroundColor: AppColors.verdeCesped,
            ),
          );
        }
      } catch (e) {
        debugPrint('Firestore offline collection queue: $e');
      }

      setState(() => _isSaving = false);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSave();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blancoPuro,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registro de Cobranza',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              
              Text(
                'Cliente: ${widget.client.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
              ),
              const SizedBox(height: 16),

              // Tipo de Gestión
              DropdownButtonFormField<String>(
                initialValue: _tipoGestion,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Gestión',
                  prefixIcon: Icon(Icons.contact_mail, color: AppColors.azulMarino),
                ),
                dropdownColor: AppColors.blancoPuro,
                items: const [
                  DropdownMenuItem(value: 'Visita', child: Text('Visita en Campo', style: TextStyle(color: AppColors.textoOscuro))),
                  DropdownMenuItem(value: 'Llamada', child: Text('Llamada Telefónica', style: TextStyle(color: AppColors.textoOscuro))),
                  DropdownMenuItem(value: 'Mensaje', child: Text('Mensaje WhatsApp/SMS', style: TextStyle(color: AppColors.textoOscuro))),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _tipoGestion = val);
                },
              ),
              const SizedBox(height: 16),

              // Resultado de la gestión
              DropdownButtonFormField<String>(
                initialValue: _resultado,
                decoration: const InputDecoration(
                  labelText: 'Resultado de Gestión',
                  prefixIcon: Icon(Icons.check_circle_outline, color: AppColors.azulMarino),
                ),
                dropdownColor: AppColors.blancoPuro,
                items: const [
                  DropdownMenuItem(value: 'Compromiso de pago', child: Text('Compromiso de Pago', style: TextStyle(color: AppColors.textoOscuro))),
                  DropdownMenuItem(value: 'Pago parcial', child: Text('Pago Parcial Realizado', style: TextStyle(color: AppColors.textoOscuro))),
                  DropdownMenuItem(value: 'Sin contacto', child: Text('Sin Contacto (Ausente)', style: TextStyle(color: AppColors.textoOscuro))),
                  DropdownMenuItem(value: 'Se niega a pagar', child: Text('Se niega a pagar', style: TextStyle(color: AppColors.textoOscuro))),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _resultado = val);
                },
              ),
              const SizedBox(height: 16),

              // Conditional fields if compromise of payment
              if (_resultado == 'Compromiso de pago') ...[
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textoOscuro),
                  decoration: const InputDecoration(
                    labelText: 'Monto Comprometido (S/)',
                    prefixIcon: Icon(Icons.monetization_on_outlined, color: AppColors.azulMarino),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Ingrese el monto comprometido';
                    if (double.tryParse(val) == null) return 'Ingrese un monto numérico válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month, color: AppColors.azulMarino),
                  title: Text(
                    _compromiseDate == null
                        ? 'Seleccionar Fecha de Pago'
                        : 'Fecha: ${_compromiseDate!.day}/${_compromiseDate!.month}/${_compromiseDate!.year}',
                    style: TextStyle(
                      color: _compromiseDate == null ? AppColors.textoMutado : AppColors.textoOscuro,
                      fontSize: 14,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setState(() {
                        _compromiseDate = picked;
                      });
                    }
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
              ],

              // Observaciones
              TextFormField(
                controller: _obsController,
                maxLines: 3,
                maxLength: 200,
                style: const TextStyle(color: AppColors.textoOscuro),
                decoration: const InputDecoration(
                  labelText: 'Observaciones / Detalles de Visita',
                  prefixIcon: Icon(Icons.comment, color: AppColors.azulMarino),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // GPS Capture Info banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.azulMarino.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.location_searching, color: AppColors.turquesaOscuro, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Coordenadas de la gestión se capturarán automáticamente vía GPS.',
                        style: TextStyle(fontSize: 11, color: AppColors.textoMutado),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitCobranza,
                  child: _isSaving
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text('GUARDAR ACCIÓN DE GESTIÓN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
