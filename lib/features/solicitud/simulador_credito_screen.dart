import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'nueva_solicitud_screen.dart';

class SimuladorCreditoScreen extends StatefulWidget {
  const SimuladorCreditoScreen({super.key});

  @override
  State<SimuladorCreditoScreen> createState() => _SimuladorCreditoScreenState();
}

class _SimuladorCreditoScreenState extends State<SimuladorCreditoScreen> {
  double _monto = 10000.0;
  double _plazo = 12.0; // in months
  double _tea = 28.0; // 28% TEA

  @override
  Widget build(BuildContext context) {
    // French Amortization Calculations
    final double teaDecimal = _tea / 100.0;
    final double tasaMensual = pow(1.0 + teaDecimal, 1.0 / 12.0) - 1.0;
    final double cuotaMensual = _monto * tasaMensual / (1.0 - pow(1.0 + tasaMensual, -_plazo));
    final double totalAPagar = cuotaMensual * _plazo;
    final double costoFinanciero = totalAPagar - _monto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Crédito'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instruction header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.azulMarino.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.azulMarino, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Calcule cuotas referenciales de forma instantánea usando el método de amortización francés.',
                      style: TextStyle(color: AppColors.textoOscuro, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Monte slider card
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
                          'Monto del Crédito',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                        ),
                        Text(
                          'S/ ${_monto.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.turquesaOscuro),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _monto,
                      min: 500.0,
                      max: 150000.0,
                      divisions: 299, // steps of 500
                      activeColor: AppColors.turquesaBrillante,
                      inactiveColor: AppColors.borde,
                      onChanged: (val) {
                        setState(() {
                          _monto = val;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('S/ 500', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                        Text('S/ 150,000', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Plazo slider card
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
                          'Plazo de Pago',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                        ),
                        Text(
                          '${_plazo.toStringAsFixed(0)} meses',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.turquesaOscuro),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _plazo,
                      min: 3.0,
                      max: 60.0,
                      divisions: 57, // monthly steps
                      activeColor: AppColors.turquesaBrillante,
                      inactiveColor: AppColors.borde,
                      onChanged: (val) {
                        setState(() {
                          _plazo = val;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('3 meses', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                        Text('60 meses', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tasa slider card
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
                          'Tasa de Interés (TEA)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                        ),
                        Text(
                          '${_tea.toStringAsFixed(1)} %',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.turquesaOscuro),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _tea,
                      min: 12.0,
                      max: 60.0,
                      divisions: 96, // steps of 0.5%
                      activeColor: AppColors.turquesaBrillante,
                      inactiveColor: AppColors.borde,
                      onChanged: (val) {
                        setState(() {
                          _tea = val;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('12.0% TEA', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                        Text('60.0% TEA', style: TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Result Cards
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Resultados de la Simulación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.azulMarino,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'CUOTA MENSUAL ESTIMADA',
                    style: TextStyle(color: AppColors.turquesaBrillante, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'S/ ${cuotaMensual.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Pagar:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        'S/ ${totalAPagar.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Costo Financiero (Interés):',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        'S/ ${costoFinanciero.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.amarilloMostaza, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tasa Efectiva Mensual (TEM):',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        '${(tasaMensual * 100.0).toStringAsFixed(4)} %',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdeCesped,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_task),
                label: const Text('INICIAR SOLICITUD CON ESTOS DATOS'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NuevaSolicitudScreen(
                        prefilledDni: null,
                        prefilledAmount: _monto,
                        prefilledTerm: _plazo.toInt().toString(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
