import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../auth/auth_oficial_view_model.dart';
import '../auth/login_oficial_screen.dart';
import 'cartera_view_model.dart';
import 'ficha_cliente_screen.dart';
import '../ruta/ruta_screen.dart';
import '../solicitud/estado_solicitudes_screen.dart';
import '../solicitud/nueva_solicitud_screen.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_service.dart';

class CarteraDiariaScreen extends StatefulWidget {
  const CarteraDiariaScreen({super.key});

  @override
  State<CarteraDiariaScreen> createState() => _CarteraDiariaScreenState();
}

class _CarteraDiariaScreenState extends State<CarteraDiariaScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Cartera Diaria (Visitas)',
    'Planificación de Ruta',
    'Estado de Solicitudes',
  ];

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthOficialViewModel>(context);
    final connProv = Provider.of<ConnectivityProvider>(context);
    final syncProv = Provider.of<SyncProvider>(context);

    // List of screens for bottom navigation
    final List<Widget> screens = [
      const CarteraVisitasTab(),
      const RutaScreen(),
      const EstadoSolicitudesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Connection simulated toggle indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                connProv.isOnline ? Icons.wifi : Icons.wifi_off,
                size: 18,
                color: connProv.isOnline ? AppColors.turquesaBrillante : AppColors.amarilloMostaza,
              ),
              const SizedBox(width: 4),
              Text(
                connProv.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: connProv.isOnline ? AppColors.turquesaBrillante : AppColors.amarilloMostaza,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: connProv.isOnline,
                activeThumbColor: AppColors.turquesaBrillante,
                activeTrackColor: AppColors.turquesaBrillante.withValues(alpha: 0.5),
                inactiveThumbColor: AppColors.rojoCoral,
                inactiveTrackColor: AppColors.rojoCoral.withValues(alpha: 0.3),
                onChanged: (val) {
                  connProv.setOnline(val);
                  if (val) {
                    syncProv.syncPendingRequests(true);
                  }
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authVM.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginOficialScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Banner Indicator
          if (!connProv.isOnline)
            Container(
              color: AppColors.amarilloMostaza,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.azulMarino, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Modo Offline Activo - Las solicitudes se guardarán localmente',
                    style: TextStyle(
                      color: AppColors.azulMarino,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Sync Progress Banner
          if (syncProv.isSyncing)
            Container(
              color: AppColors.turquesaOscuro,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.blancoPuro),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      syncProv.syncMessage,
                      style: const TextStyle(
                        color: AppColors.blancoPuro,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Cartera Diaria',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa Ruta',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Solicitudes',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.turquesaBrillante,
              foregroundColor: AppColors.azulMarino,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NuevaSolicitudScreen()),
                );
              },
            )
          : null,
    );
  }
}

// Cartera Visitas Tab UI (HU-V02)
class CarteraVisitasTab extends StatelessWidget {
  const CarteraVisitasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthOficialViewModel>(context);
    final carteraVM = Provider.of<CarteraViewModel>(context);

    // Calculation progress percentage
    final double progress = carteraVM.totalVisits > 0 
        ? carteraVM.completedVisits / carteraVM.totalVisits 
        : 0.0;

    return Column(
      children: [
        // Greeting & Visit summary card
        Container(
          width: double.infinity,
          color: AppColors.azulMarino,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${authVM.officerName ?? "Oficial"}',
                style: const TextStyle(
                  color: AppColors.turquesaBrillante,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Código de Empleado: OF12345',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 16),
              
              // Progress Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progreso de Visitas del Día:',
                          style: TextStyle(color: AppColors.blancoPuro, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${carteraVM.completedVisits} / ${carteraVM.totalVisits} completadas',
                          style: const TextStyle(
                            color: AppColors.amarilloMostaza,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.turquesaBrillante),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Visits List title
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Clientes a Visitar Hoy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.azulMarino,
              ),
            ),
          ),
        ),

        // List body
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: carteraVM.clients.length,
            itemBuilder: (context, index) {
              final client = carteraVM.clients[index];
              return _buildVisitCard(context, carteraVM, client, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisitCard(
    BuildContext context, 
    CarteraViewModel carteraVM, 
    VisitClient client, 
    int index
  ) {
    // Choose color for management badges
    Color badgeColor;
    switch (client.managementType.toLowerCase()) {
      case 'renovación':
        badgeColor = AppColors.amarilloMostaza;
        break;
      case 'nuevo':
        badgeColor = AppColors.turquesaOscuro;
        break;
      case 'cobranza':
        badgeColor = AppColors.rojoCoral;
        break;
      default:
        badgeColor = AppColors.textoMutado;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Name & Status Switch
            Row(
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
                
                // Visited check
                Column(
                  children: [
                    Switch(
                      value: client.isVisited,
                      activeThumbColor: AppColors.verdeCesped,
                      activeTrackColor: AppColors.verdeCesped.withValues(alpha: 0.5),
                      onChanged: (val) {
                        carteraVM.toggleVisitStatus(index);
                      },
                    ),
                    Text(
                      client.isVisited ? 'VISITADO' : 'PENDIENTE',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: client.isVisited ? AppColors.verdeCesped : AppColors.textoMutado,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 6),
            Text(
              client.address,
              style: const TextStyle(color: AppColors.textoMutado, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Row 3: Badges and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Management type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: badgeColor, width: 0.5),
                      ),
                      child: Text(
                        client.managementType,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ref: S/ ${client.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Ficha Button
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.azulMarino,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FichaClienteScreen(clientDni: client.dni),
                          ),
                        );
                      },
                      child: const Text('Ver Ficha', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    // Nueva Solicitud Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.turquesaBrillante,
                        foregroundColor: AppColors.azulMarino,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NuevaSolicitudScreen(prefilledDni: client.dni),
                          ),
                        );
                      },
                      child: const Text('Solicitud'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
