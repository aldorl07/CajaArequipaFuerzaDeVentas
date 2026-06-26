import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../auth/auth_oficial_view_model.dart';
import '../auth/login_oficial_screen.dart';
import 'cartera_view_model.dart';
import 'ficha_cliente_screen.dart';
import 'evaluar_credito_wizard_screen.dart';
import '../ruta/ruta_screen.dart';
import '../solicitud/estado_solicitudes_screen.dart';
import '../solicitud/nueva_solicitud_screen.dart';
import '../solicitud/simulador_credito_screen.dart';
import '../solicitud/borradores_screen.dart';
import '../cobranza/recuperacion_mora_screen.dart';
import '../reportes/reportes_supervision_screen.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_service.dart';
import 'alertas_campanas_screen.dart';
import 'solicitudes_credito_screen.dart';

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

  void _navigateToTab(int index) {
    Navigator.of(context).pop(); // Close drawer
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _confirmLogout(BuildContext context, AuthOficialViewModel authVM, SyncProvider syncProv) {
    Navigator.of(context).pop(); // Close drawer
    final pending = syncProv.pendingCount;

    if (pending > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Solicitudes Pendientes'),
          content: Text('Tiene $pending expedientes guardados localmente pendientes de transmisión.\n\n¿Está seguro de cerrar sesión de todos modos? Se podrían perder estos datos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojoCoral),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await authVM.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginOficialScreen()),
                  );
                }
              },
              child: const Text('CERRAR DE TODOS MODOS', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Desea cerrar la sesión del portal de crédito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await authVM.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginOficialScreen()),
                  );
                }
              },
              child: const Text('CERRAR SESIÓN'),
            ),
          ],
        ),
      );
    }
  }

  void _simulateNightlyDownload(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(); // Close drawer
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        double progress = 0.0;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (progress < 1.0) {
                setDialogState(() {
                  progress += 0.15;
                  if (progress > 1.0) progress = 1.0;
                });
              }
            });

            if (progress >= 1.0) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Descarga nocturna completada. Cartera diaria sincronizada localmente (WorkManager).'),
                    backgroundColor: AppColors.verdeCesped,
                  ),
                );
              });
            }

            return AlertDialog(
              title: const Text('Descarga Nocturna (WorkManager)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Simulando tarea en segundo plano de descarga de cartera para hoy...', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    color: AppColors.turquesaBrillante,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, AuthOficialViewModel authVM, SyncProvider syncProv) {
    final role = authVM.userRole;

    return Drawer(
      backgroundColor: AppColors.blancoPuro,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.azulMarino,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.turquesaBrillante,
              child: Text(
                authVM.officerName?.substring(0, 2).toUpperCase() ?? 'OF',
                style: const TextStyle(color: AppColors.azulMarino, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            accountName: Text(
              authVM.officerName ?? 'Aldo Requena',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Código: ${authVM.employeeCode ?? "OF12345"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.turquesaOscuro,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outline, color: AppColors.azulMarino),
                  title: const Text('Mi Cartera Diaria', style: TextStyle(color: AppColors.textoOscuro)),
                  onTap: () => _navigateToTab(0),
                ),
                ListTile(
                  leading: const Icon(Icons.map_outlined, color: AppColors.azulMarino),
                  title: const Text('Planificación de Ruta', style: TextStyle(color: AppColors.textoOscuro)),
                  onTap: () => _navigateToTab(1),
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_outlined, color: AppColors.azulMarino),
                  title: const Text('Estado de Solicitudes', style: TextStyle(color: AppColors.textoOscuro)),
                  onTap: () => _navigateToTab(2),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.folder_open_outlined, color: AppColors.azulMarino),
                  title: const Text('Borradores de Solicitud', style: TextStyle(color: AppColors.textoOscuro)),
                  onTap: () => _navigateToScreen(const BorradoresScreen()),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('credit_requests')
                      .where('status', isEqualTo: 'Pendiente')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int pendingCount = 0;
                    if (snapshot.hasData) {
                      pendingCount = snapshot.data!.docs.length;
                    }

                    return ListTile(
                      leading: const Icon(Icons.rate_review_outlined, color: AppColors.azulMarino),
                      title: const Text('Solicitudes de Crédito', style: TextStyle(color: AppColors.textoOscuro)),
                      trailing: pendingCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.rojoCoral,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : null,
                      onTap: () => _navigateToScreen(const SolicitudesCreditoScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calculate_outlined, color: AppColors.azulMarino),
                  title: const Text('Simulador de Crédito', style: TextStyle(color: AppColors.textoOscuro)),
                  onTap: () => _navigateToScreen(const SimuladorCreditoScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.payments_outlined, color: AppColors.azulMarino),
                  title: const Text('Recuperación de Mora (Cobranza)', style: TextStyle(color: AppColors.textoOscuro)),
                  onTap: () => _navigateToScreen(const RecuperacionMoraScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.campaign_outlined, color: AppColors.azulMarino),
                  title: const Text('Alertas y Campañas', style: TextStyle(color: AppColors.textoOscuro)),
                  onTap: () => _navigateToScreen(const AlertasCampanasScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined, color: AppColors.azulMarino),
                  title: const Text('Descarga Nocturna (Simular)', style: TextStyle(color: AppColors.textoOscuro)),
                  onTap: () => _simulateNightlyDownload(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bar_chart_outlined, color: AppColors.amarilloMostaza),
                  title: const Text('Reportes y Supervisión', style: TextStyle(color: AppColors.textoOscuro, fontWeight: FontWeight.bold)),
                  onTap: () => _navigateToScreen(const ReportesSupervisionScreen()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (syncProv.pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.amarilloMostaza.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.amarilloMostaza, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sync_problem, color: AppColors.amarilloMostaza, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${syncProv.pendingCount} pendientes de envío',
                            style: const TextStyle(fontSize: 10, color: AppColors.textoOscuro, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rojoCoral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('CERRAR SESIÓN'),
                  onPressed: () => _confirmLogout(context, authVM, syncProv),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Caja Arequipa Movilidad v1.2',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textoMutado, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        ],
      ),
      drawer: _buildDrawer(context, authVM, syncProv),
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
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('credit_requests')
            .where('status', isEqualTo: 'Pendiente')
            .snapshots(),
        builder: (context, snapshot) {
          final pendingCount = snapshot.data?.docs.length ?? 0;
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Cartera Diaria',
              ),
              const NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: 'Mapa Ruta',
              ),
              NavigationDestination(
                icon: pendingCount > 0
                    ? Badge(
                        backgroundColor: AppColors.rojoCoral,
                        label: Text(
                          '$pendingCount',
                          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        child: const Icon(Icons.assignment_outlined),
                      )
                    : const Icon(Icons.assignment_outlined),
                selectedIcon: pendingCount > 0
                    ? Badge(
                        backgroundColor: AppColors.rojoCoral,
                        label: Text(
                          '$pendingCount',
                          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        child: const Icon(Icons.assignment),
                      )
                    : const Icon(Icons.assignment),
                label: 'Solicitudes',
              ),
            ],
          );
        },
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

// Cartera Visitas Tab UI (HU-V02 & Use Cases)
class CarteraVisitasTab extends StatefulWidget {
  const CarteraVisitasTab({super.key});

  @override
  State<CarteraVisitasTab> createState() => _CarteraVisitasTabState();
}

class _CarteraVisitasTabState extends State<CarteraVisitasTab> {
  String _searchQuery = '';
  String _statusFilter = 'Todos'; // 'Todos', 'Pendiente', 'Visitado', 'Desertor'
  String _typeFilter = 'Todos';   // 'Todos', 'Renovación', 'Nuevo', 'Cobranza'

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthOficialViewModel>(context);
    final carteraVM = Provider.of<CarteraViewModel>(context);

    // Apply filters
    final filteredClients = carteraVM.clients.where((client) {
      // 1. Search filter
      if (_searchQuery.isNotEmpty) {
        final nameMatch = client.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final dniMatch = client.dni.contains(_searchQuery);
        if (!nameMatch && !dniMatch) return false;
      }

      // 2. Status filter
      if (_statusFilter == 'Pendiente') {
        if (client.isVisited || client.status == 'Desertor') return false;
      } else if (_statusFilter == 'Visitado') {
        if (!client.isVisited || client.status == 'Desertor') return false;
      } else if (_statusFilter == 'Desertor') {
        if (client.status != 'Desertor') return false;
      } else {
        // 'Todos' shows all active (non-deserted) clients by default
        if (client.status == 'Desertor') return false;
      }

      // 3. Management type filter
      if (_typeFilter != 'Todos') {
        if (client.managementType != _typeFilter) return false;
      }

      return true;
    }).toList();

    // Calculation progress percentage for active visits only
    final activeClients = carteraVM.clients.where((c) => c.status != 'Desertor').toList();
    final completedActive = activeClients.where((c) => c.isVisited).length;
    final double progress = activeClients.isNotEmpty 
        ? completedActive / activeClients.length 
        : 0.0;

    // We can only reorder when NO filters are active
    final bool canReorder = _searchQuery.isEmpty && _statusFilter == 'Todos' && _typeFilter == 'Todos';

    return Column(
      children: [
        // Greeting & Visit summary card
        Container(
          width: double.infinity,
          color: AppColors.azulMarino,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                    ],
                  ),
                  IconButton(
                    icon: const Badge(
                      label: Text('3', style: TextStyle(fontSize: 8, color: Colors.white)),
                      child: Icon(Icons.notifications_outlined, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AlertasCampanasScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Progress Box
              Container(
                padding: const EdgeInsets.all(12),
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
                          style: TextStyle(color: AppColors.blancoPuro, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$completedActive / ${activeClients.length} completadas',
                          style: const TextStyle(
                            color: AppColors.amarilloMostaza,
                            fontSize: 11,
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

        // SEARCH BAR
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            style: const TextStyle(color: AppColors.textoOscuro, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o DNI...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
        ),

        // FILTER CHIPS ROW
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _buildFilterChip('Estado: Todos', _statusFilter == 'Todos', () => setState(() => _statusFilter = 'Todos')),
              const SizedBox(width: 4),
              _buildFilterChip('Pendientes', _statusFilter == 'Pendiente', () => setState(() => _statusFilter = 'Pendiente')),
              const SizedBox(width: 4),
              _buildFilterChip('Visitados', _statusFilter == 'Visitado', () => setState(() => _statusFilter = 'Visitado')),
              const SizedBox(width: 4),
              _buildFilterChip('Desertores', _statusFilter == 'Desertor', () => setState(() => _statusFilter = 'Desertor')),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('|', style: TextStyle(color: Colors.grey)),
              ),

              _buildFilterChip('Tipos: Todos', _typeFilter == 'Todos', () => setState(() => _typeFilter = 'Todos')),
              const SizedBox(width: 4),
              _buildFilterChip('Renovación', _typeFilter == 'Renovación', () => setState(() => _typeFilter = 'Renovación')),
              const SizedBox(width: 4),
              _buildFilterChip('Nuevos', _typeFilter == 'Nuevo', () => setState(() => _typeFilter = 'Nuevo')),
              const SizedBox(width: 4),
              _buildFilterChip('Cobranza', _typeFilter == 'Cobranza', () => setState(() => _typeFilter = 'Cobranza')),
            ],
          ),
        ),

        // Visits List title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Clientes a Visitar Hoy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulMarino,
                  ),
                ),
                if (canReorder && filteredClients.length > 1)
                  const Row(
                    children: [
                      Icon(Icons.drag_indicator, size: 14, color: AppColors.textoMutado),
                      SizedBox(width: 4),
                      Text('Mantener presionado para ordenar', style: TextStyle(fontSize: 10, color: AppColors.textoMutado)),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // List body
        Expanded(
          child: filteredClients.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron clientes con los filtros aplicados.',
                    style: TextStyle(color: AppColors.textoMutado, fontSize: 12),
                  ),
                )
              : canReorder
                  ? ReorderableListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filteredClients.length,
                      onReorder: (oldIndex, newIndex) {
                        carteraVM.reorderClients(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        return Container(
                          key: ValueKey(client.dni),
                          child: _buildVisitCard(context, carteraVM, client, index, true),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        return _buildVisitCard(context, carteraVM, client, index, false);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppColors.textoOscuro)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.azulMarino,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppColors.azulMarino : Colors.grey[300]!),
      ),
    );
  }

  Widget _buildVisitCard(
    BuildContext context, 
    CarteraViewModel carteraVM, 
    VisitClient client, 
    int index,
    bool isReorderable,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('credit_requests')
          .where('dni', isEqualTo: client.dni)
          .where('status', isEqualTo: 'Pendiente')
          .snapshots(),
      builder: (context, snapshot) {
        double displayAmount = client.amount;
        String displayType = client.managementType;
        bool hasPendingRequest = false;
        Map<String, dynamic>? pendingRequestData;
        String pendingRequestId = '';

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          hasPendingRequest = true;
          final doc = snapshot.data!.docs.first;
          pendingRequestId = doc.id;
          pendingRequestData = doc.data() as Map<String, dynamic>;
          displayAmount = (pendingRequestData['amount'] as num?)?.toDouble() ?? client.amount;
          displayType = pendingRequestData['credit_type'] ?? client.managementType;
        }

        Color badgeColor;
        if (client.status == 'Desertor') {
          badgeColor = AppColors.rojoCoral;
        } else {
          switch (displayType.toLowerCase()) {
            case 'renovación':
              badgeColor = AppColors.amarilloMostaza;
              break;
            case 'nuevo':
            case 'crédito mype':
            case 'crédito personal':
              badgeColor = AppColors.turquesaOscuro;
              break;
            case 'cobranza':
              badgeColor = AppColors.rojoCoral;
              break;
            default:
              badgeColor = AppColors.turquesaOscuro;
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isReorderable)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0, top: 4.0),
                        child: Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulMarino,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'DNI: ${client.dni}',
                            style: const TextStyle(color: AppColors.textoMutado, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    
                    // Visited check / Deserted tag
                    if (client.status != 'Desertor')
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
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.rojoCoral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.rojoCoral, width: 0.5),
                        ),
                        child: const Text(
                          'DESERTOR',
                          style: TextStyle(color: AppColors.rojoCoral, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 4),
                Text(
                  client.address,
                  style: const TextStyle(color: AppColors.textoMutado, fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: badgeColor, width: 0.5),
                          ),
                          child: Text(
                            client.status == 'Desertor' ? 'DESERTOR' : displayType,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ref: S/ ${displayAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.azulMarino,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FichaClienteScreen(clientDni: client.dni),
                              ),
                            );
                          },
                          child: const Text('Ver Ficha', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 4),
                        if (client.status != 'Desertor')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.turquesaBrillante,
                              foregroundColor: AppColors.azulMarino,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (hasPendingRequest && pendingRequestData != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EvaluarCreditoWizardScreen(
                                      requestId: pendingRequestId,
                                      clientDni: client.dni,
                                      clientName: client.name,
                                      creditType: displayType,
                                      amount: displayAmount,
                                      term: pendingRequestData!['term_months'] ?? 12,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NuevaSolicitudScreen(prefilledDni: client.dni),
                                  ),
                                );
                              }
                            },
                            child: Text(hasPendingRequest ? 'Evaluar' : 'Solicitud'),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
