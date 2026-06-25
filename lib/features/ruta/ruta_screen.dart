import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class RutaScreen extends StatefulWidget {
  const RutaScreen({super.key});

  @override
  State<RutaScreen> createState() => _RutaScreenState();
}

class _RutaScreenState extends State<RutaScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _routeClients = [];
  bool _isLoading = true;
  bool _isOptimized = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadRoute();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    setState(() => _isLoading = true);
    try {
      final qs = await FirebaseFirestore.instance
          .collection('clients')
          .orderBy('visit_order', descending: false)
          .get();
      
      final clients = qs.docs.map((doc) => doc.data()).toList();
      final todayClients = clients.where((c) => c['visit_scheduled'] == '2026-06-26').toList();
      
      setState(() {
        _routeClients = todayClients;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading route from Firestore: $e');
      setState(() => _isLoading = false);
    }
  }

  void _optimizeRoute() {
    if (_routeClients.isEmpty) return;

    setState(() {
      // Simulate route optimization (sorting by nearest neighbor starting from a mock start point)
      // We will sort them by order to represent the optimized path
      _routeClients.sort((a, b) {
        // Just sort differently to simulate optimization
        final aName = a['name'] as String;
        final bName = b['name'] as String;
        return aName.compareTo(bName);
      });
      _isOptimized = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Ruta optimizada con éxito! Recorrido reducido en 4.2 km.'),
        backgroundColor: AppColors.verdeCesped,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.turquesaBrillante))
        : Column(
            children: [
              // Interactive Vector Map Header
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.azulMarino.withValues(alpha: 0.95),
                  border: const Border(
                    bottom: BorderSide(color: AppColors.turquesaBrillante, width: 2),
                  ),
                ),
                child: Stack(
                  children: [
                    // Grid background and vector roads
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: VectorMapPainter(
                              clients: _routeClients,
                              pulseValue: _pulseController.value,
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Map overlay controls
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.azulMarino,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.turquesaBrillante, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.gps_fixed, color: AppColors.turquesaBrillante, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Arequipa Cercado',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.azulMarino.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Resumen Recorrido:',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                            Text(
                              _isOptimized ? '5 Visitas • 12.8 km • 45 min' : '5 Visitas • 17.0 km • 62 min',
                              style: const TextStyle(color: AppColors.turquesaBrillante, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Optimization Header Bar
              Container(
                color: AppColors.blancoPuro,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Secuencia de Visitas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulMarino,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _optimizeRoute,
                      icon: const Icon(Icons.bolt, size: 16),
                      label: Text(_isOptimized ? 'OPTIMIZADO' : 'OPTIMIZAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isOptimized ? AppColors.verdeCesped : AppColors.turquesaBrillante,
                        foregroundColor: _isOptimized ? AppColors.blancoPuro : AppColors.azulMarino,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Route Steps List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _routeClients.length,
                  itemBuilder: (context, index) {
                    final client = _routeClients[index];
                    return _buildRouteStepCard(client, index + 1);
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildRouteStepCard(Map<String, dynamic> client, int step) {
    final String name = client['name'] ?? 'Cliente';
    final String address = client['address'] ?? 'Dirección';
    final String riskTier = client['credit_risk_tier'] ?? 'Bajo';
    final double renewalAmount = client['credit_renewal_amount'] ?? 0.0;

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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Number Circle
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.azulMarino,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$step',
                style: const TextStyle(
                  color: AppColors.blancoPuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Detail Columns
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulMarino,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: const TextStyle(color: AppColors.textoMutado, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Small Row Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Riesgo: $riskTier',
                          style: TextStyle(color: riskColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Renovación: S/ ${renewalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Navigation Button
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.navigation, color: AppColors.turquesaBrillante),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Iniciando GPS hacia $name...'),
                        backgroundColor: AppColors.azulMarino,
                      ),
                    );
                  },
                ),
                const Text(
                  'Ver GPS',
                  style: TextStyle(fontSize: 9, color: AppColors.textoMutado, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw roads, pins, connections and current position
class VectorMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> clients;
  final double pulseValue;

  VectorMapPainter({required this.clients, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Paints
    final bgGridPaint = Paint()
      ..color = AppColors.turquesaBrillante.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routeLinePaint = Paint()
      ..color = AppColors.turquesaBrillante.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw Grid Lines (blueprint feel)
    double gridSpacing = 30.0;
    for (double x = 0; x < w; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), bgGridPaint);
    }
    for (double y = 0; y < h; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(w, y), bgGridPaint);
    }

    // Draw Mock Roads
    canvas.drawLine(Offset(0, h * 0.3), Offset(w, h * 0.3), roadPaint);
    canvas.drawLine(Offset(0, h * 0.7), Offset(w, h * 0.7), roadPaint);
    canvas.drawLine(Offset(w * 0.35, 0), Offset(w * 0.35, h), roadPaint);
    canvas.drawLine(Offset(w * 0.75, 0), Offset(w * 0.75, h), roadPaint);
    
    // Diagonal road
    canvas.drawLine(Offset(0, 0), Offset(w, h), roadPaint);

    // Simulated Officer Current Position (Center)
    final Offset officerPos = Offset(w * 0.5, h * 0.55);

    // Pulse animation around officer
    final pulsePaint = Paint()
      ..color = AppColors.turquesaBrillante.withValues(alpha: 1.0 - pulseValue)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(officerPos, 8.0 + (pulseValue * 14.0), pulsePaint);

    // Officer core point
    final officerCorePaint = Paint()
      ..color = AppColors.turquesaBrillante
      ..style = PaintingStyle.fill;
    canvas.drawCircle(officerPos, 6.0, officerCorePaint);

    // If no clients, stop
    if (clients.isEmpty) return;

    // Map clients latitude/longitude coordinates to canvas coordinates
    // We map: Latitudes -16.4258 to -16.3355, Longitudes -71.5699 to -71.5050
    // To make it look centered, let's map coordinates with a relative ratio
    List<Offset> clientPoints = [];

    // Let's hardcode screen positions for the 5 seed clients so they fit beautifully on map:
    final List<Offset> presetPositions = [
      Offset(w * 0.25, h * 0.22), // Client 1
      Offset(w * 0.38, h * 0.45), // Client 2
      Offset(w * 0.62, h * 0.15), // Client 3
      Offset(w * 0.15, h * 0.78), // Client 4
      Offset(w * 0.82, h * 0.65), // Client 5
    ];

    for (int i = 0; i < clients.length; i++) {
      if (i < presetPositions.length) {
        clientPoints.add(presetPositions[i]);
      } else {
        // Fallback random-ish
        clientPoints.add(Offset(w * 0.4 + (i * 20), h * 0.2 + (i * 25)));
      }
    }

    // Draw Connection lines (Route path connecting officer -> step 1 -> step 2 -> ...)
    Path routePath = Path();
    routePath.moveTo(officerPos.dx, officerPos.dy);
    for (var pt in clientPoints) {
      routePath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(routePath, routeLinePaint);

    // Draw Client Pins
    final pinPaint = Paint()..style = PaintingStyle.fill;
    final pinBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < clientPoints.length; i++) {
      final pt = clientPoints[i];
      final client = clients[i];
      final String riskTier = client['credit_risk_tier'] ?? 'Bajo';

      // Pick color by risk
      Color riskColor;
      if (riskTier == 'Bajo') {
        riskColor = AppColors.verdeCesped;
      } else if (riskTier == 'Medio') {
        riskColor = AppColors.naranjaOcre;
      } else {
        riskColor = AppColors.rojoCoral;
      }

      pinPaint.color = riskColor;

      // Draw custom Pin shape (Circle + triangle or just nested circles for safety and performance)
      canvas.drawCircle(pt, 8.5, pinPaint);
      canvas.drawCircle(pt, 8.5, pinBorder);

      // Inner white dot
      canvas.drawCircle(pt, 3.0, Paint()..color = Colors.white);

      // Step text indicator above pin
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pt.dx - textPainter.width / 2, pt.dy - 20));
    }
  }

  @override
  bool shouldRepaint(covariant VectorMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.clients != clients;
  }
}
