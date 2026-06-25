import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../auth/auth_view_model.dart';
import '../auth/login_screen.dart';
import '../cartera/cartera_screen.dart';
import '../ruta/ruta_screen.dart';
import '../solicitud/estado_solicitudes_screen.dart';
import '../solicitud/nueva_solicitud_screen.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Inicio - Caja Arequipa',
    'Cartera del Día',
    'Planificación de Ruta',
    'Estado de Solicitudes',
  ];

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final connProv = Provider.of<ConnectivityProvider>(context);
    final syncProv = Provider.of<SyncProvider>(context);

    // List of screens for bottom navigation
    final List<Widget> screens = [
      const HomeTab(),
      const CarteraScreen(),
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
                activeColor: AppColors.turquesaBrillante,
                inactiveThumbColor: AppColors.rojoCoral,
                inactiveTrackColor: AppColors.rojoCoral.withOpacity(0.3),
                onChanged: (val) {
                  connProv.setOnline(val);
                  if (val) {
                    // Trigger sync when going online
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
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Cartera',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Ruta',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Solicitudes',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
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

// Home Tab details (Inicio summary)
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final connProv = Provider.of<ConnectivityProvider>(context);
    final syncProv = Provider.of<SyncProvider>(context);

    // Dynamic greeting based on time of day
    final hour = DateTime.now().hour;
    String greeting = 'Buenos días';
    if (hour >= 12 && hour < 19) {
      greeting = 'Buenas tardes';
    } else if (hour >= 19 || hour < 6) {
      greeting = 'Buenas noches';
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Officer Greeting Banner
            Card(
              color: AppColors.azulMarino,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.turquesaBrillante,
                      radius: 26,
                      child: Text(
                        authVM.userName != null ? authVM.userName!.substring(0, 2).toUpperCase() : 'OF',
                        style: const TextStyle(
                          color: AppColors.azulMarino,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: const TextStyle(
                              color: AppColors.turquesaBrillante,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            authVM.userName ?? 'Oficial de Crédito',
                            style: const TextStyle(
                              color: AppColors.blancoPuro,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Agencia Arequipa Metropolitana',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sincronización Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sync, color: AppColors.azulMarino),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Sincronización de Datos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulMarino,
                            ),
                          ),
                        ),
                        if (syncProv.pendingCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.amarilloMostaza,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${syncProv.pendingCount} pendientes',
                              style: const TextStyle(
                                color: AppColors.azulMarino,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      syncProv.pendingCount > 0
                          ? 'Tienes solicitudes capturadas en modo offline esperando ser transmitidas.'
                          : 'Todos tus expedientes y documentos se encuentran sincronizados con el Core Bancario.',
                      style: const TextStyle(color: AppColors.textoMutado, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text(syncProv.isSyncing ? 'SINCRONIZANDO...' : 'SINCRONIZAR AHORA'),
                      onPressed: syncProv.isSyncing || syncProv.pendingCount == 0
                          ? null
                          : () {
                              if (!connProv.isOnline) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Por favor, active el modo Online para sincronizar.'),
                                    backgroundColor: AppColors.rojoCoral,
                                  ),
                                );
                              } else {
                                syncProv.syncPendingRequests(true);
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Summary statistics title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Text(
                'Resumen Comercial',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
            ),

            // Portfolio stats Grid (Savings, active loans, pending renewals)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  title: 'Ahorros Cartera',
                  value: 'S/ 45,600',
                  subtitle: 'Depósitos en cuentas',
                  icon: Icons.account_balance_wallet,
                  color: AppColors.turquesaOscuro,
                ),
                _buildStatCard(
                  title: 'Colocaciones',
                  value: 'S/ 120,500',
                  subtitle: 'Saldo de crédito activo',
                  icon: Icons.monetization_on,
                  color: AppColors.verdeCesped,
                ),
                _buildStatCard(
                  title: 'Renovaciones',
                  value: '5 Clientes',
                  subtitle: 'Para vencer esta semana',
                  icon: Icons.autorenew,
                  color: AppColors.amarilloMostaza,
                ),
                _buildStatCard(
                  title: 'Monto a Renovar',
                  value: 'S/ 105,000',
                  subtitle: 'Meta de renovación',
                  icon: Icons.trending_up,
                  color: AppColors.naranjaOcre,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick actions list
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Text(
                'Accesos Rápidos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
            ),

            // Quick Actions list
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.azulMarino,
                child: Icon(Icons.person_add, color: AppColors.blancoPuro),
              ),
              title: const Text('Nueva Solicitud de Crédito'),
              subtitle: const Text('Registrar expediente en campo'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NuevaSolicitudScreen()),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.turquesaOscuro,
                child: Icon(Icons.map, color: AppColors.blancoPuro),
              ),
              title: const Text('Mapa de Ruta'),
              subtitle: const Text('Visitar clientes agendados'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                // Normally we'd navigate to the Ruta screen, here we simulate tab change
                // But since this is a separate screen, we can handle it.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Use la pestaña "Ruta" de la barra inferior para ver el mapa.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulMarino,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textoMutado,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
