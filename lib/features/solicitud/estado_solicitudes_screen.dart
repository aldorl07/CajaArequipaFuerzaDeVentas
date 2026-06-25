import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/services/database_helper.dart';

class EstadoSolicitudesScreen extends StatefulWidget {
  const EstadoSolicitudesScreen({super.key});

  @override
  State<EstadoSolicitudesScreen> createState() => _EstadoSolicitudesScreenState();
}

class _EstadoSolicitudesScreenState extends State<EstadoSolicitudesScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos'; // 'Todos', 'Pendientes', 'Evaluación', 'Aprobados'

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final reqs = await DatabaseHelper.instance.getCreditRequests();
    setState(() {
      _requests = reqs;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredRequests {
    if (_selectedFilter == 'Todos') return _requests;
    
    return _requests.where((r) {
      final String status = r['status'] ?? '';
      if (_selectedFilter == 'Pendientes') {
        return status == 'PendingSync' || status == 'Draft';
      } else if (_selectedFilter == 'Evaluación') {
        return status == 'Syncing' || status == 'Enviado' || status == 'En Evaluación';
      } else if (_selectedFilter == 'Aprobados') {
        return status == 'Aprobado' || status == 'Desembolsado';
      }
      return true;
    }).toList();
  }

  Future<void> _deleteRequest(int id) async {
    await DatabaseHelper.instance.deleteCreditRequest(id);
    _loadRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud eliminada.')),
    );
  }

  Future<void> _clearAll() async {
    await DatabaseHelper.instance.clearAllRequests();
    _loadRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historial limpiado con éxito.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Buttons
        Container(
          color: AppColors.azulMarino,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterButton('Todos'),
              _buildFilterButton('Pendientes'),
              _buildFilterButton('Evaluación'),
              _buildFilterButton('Aprobados'),
            ],
          ),
        ),

        // Clear All Action
        if (_requests.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete_sweep, size: 16, color: AppColors.rojoCoral),
                label: const Text('Limpiar Historial', style: TextStyle(color: AppColors.rojoCoral, fontSize: 12)),
              ),
            ),
          ),

        // List body
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.turquesaBrillante))
              : _filteredRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 64, color: AppColors.textoMutado.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay solicitudes en esta sección',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Las solicitudes guardadas aparecerán aquí',
                            style: TextStyle(color: AppColors.textoMutado),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRequests,
                      color: AppColors.turquesaBrillante,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _filteredRequests.length,
                        itemBuilder: (context, index) {
                          final req = _filteredRequests[index];
                          return _buildRequestCard(req);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.turquesaBrillante : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.azulMarino : AppColors.blancoPuro,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final int id = req['id'];
    final String clientName = req['client_name'] ?? 'Cliente';
    final String clientDni = req['client_dni'] ?? '--------';
    final double amount = req['amount'] ?? 0.0;
    final int term = req['term_months'] ?? 12;
    final String status = req['status'] ?? 'Draft';
    final String createdAtStr = req['created_at'] ?? '';
    
    String dateFormatted = '';
    try {
      final dt = DateTime.parse(createdAtStr);
      dateFormatted = DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      dateFormatted = createdAtStr;
    }

    // Determine color & icon based on status
    Color statusColor;
    IconData statusIcon;
    String statusLabel = status;

    switch (status) {
      case 'Draft':
        statusColor = AppColors.textoMutado;
        statusIcon = Icons.edit_note;
        statusLabel = 'Borrador';
        break;
      case 'PendingSync':
        statusColor = AppColors.amarilloMostaza;
        statusIcon = Icons.cloud_off;
        statusLabel = 'Pendiente Sinc.';
        break;
      case 'Syncing':
        statusColor = AppColors.turquesaOscuro;
        statusIcon = Icons.sync;
        statusLabel = 'Sincronizando...';
        break;
      case 'Enviado':
        statusColor = AppColors.azulMarino;
        statusIcon = Icons.send;
        statusLabel = 'Enviado';
        break;
      case 'En Evaluación':
        statusColor = AppColors.naranjaOcre;
        statusIcon = Icons.analytics_outlined;
        statusLabel = 'En Evaluación';
        break;
      case 'Aprobado':
        statusColor = AppColors.verdeCesped;
        statusIcon = Icons.check_circle;
        statusLabel = 'Aprobado';
        break;
      case 'Desembolsado':
        statusColor = AppColors.verdeCesped;
        statusIcon = Icons.payments;
        statusLabel = 'Desembolsado';
        break;
      case 'Rechazado':
        statusColor = AppColors.rojoCoral;
        statusIcon = Icons.cancel;
        statusLabel = 'Rechazado';
        break;
      default:
        statusColor = AppColors.textoMutado;
        statusIcon = Icons.help_outline;
    }

    return Card(
      child: ExpansionTile(
        key: PageStorageKey<int>(id),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.12),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          clientName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.azulMarino),
        ),
        subtitle: Text(
          'S/ ${amount.toStringAsFixed(0)} • $term meses • DNI: $clientDni',
          style: const TextStyle(fontSize: 11, color: AppColors.textoMutado),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Captura: $dateFormatted', style: const TextStyle(fontSize: 11, color: AppColors.textoMutado)),
                    TextButton.icon(
                      onPressed: () => _deleteRequest(id),
                      icon: const Icon(Icons.delete_outline, size: 14, color: AppColors.rojoCoral),
                      label: const Text('Eliminar', style: TextStyle(color: AppColors.rojoCoral, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Stepper Visual
                const Text(
                  'Estado del Flujo Bancario:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.azulMarino),
                ),
                const SizedBox(height: 16),
                _buildFlowStepper(status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Vertical/horizontal flow stepper implementation
  Widget _buildFlowStepper(String currentStatus) {
    final List<String> steps = ['PendingSync', 'Enviado', 'En Evaluación', 'Aprobado', 'Desembolsado'];
    final List<String> stepLabels = ['Capturado', 'Enviado', 'Evaluación', 'Aprobado', 'Desembolsado'];
    
    int activeIndex = -1;
    if (currentStatus == 'PendingSync') activeIndex = 0;
    if (currentStatus == 'Syncing') activeIndex = 0; // showing sync trigger
    if (currentStatus == 'Enviado') activeIndex = 1;
    if (currentStatus == 'En Evaluación') activeIndex = 2;
    if (currentStatus == 'Aprobado') activeIndex = 3;
    if (currentStatus == 'Desembolsado') activeIndex = 4;
    if (currentStatus == 'Rechazado') activeIndex = 2; // failed during evaluation

    return Row(
      children: List.generate(steps.length, (index) {
        final bool isCompleted = index <= activeIndex && currentStatus != 'Rechazado';
        final bool isActive = index == activeIndex;
        final bool isFailed = currentStatus == 'Rechazado' && index == 3;

        Color dotColor = AppColors.borde;
        if (isCompleted) {
          dotColor = index == 4 ? AppColors.verdeCesped : AppColors.turquesaOscuro;
        }
        if (isActive) {
          dotColor = currentStatus == 'PendingSync' ? AppColors.amarilloMostaza : AppColors.turquesaBrillante;
        }
        if (isFailed) {
          dotColor = AppColors.rojoCoral;
        }

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0 ? Colors.transparent : (index <= activeIndex ? AppColors.turquesaOscuro : AppColors.borde),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: isCompleted && index < 4
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : (isFailed ? const Icon(Icons.close, size: 10, color: Colors.white) : null),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == steps.length - 1 ? Colors.transparent : (index < activeIndex ? AppColors.turquesaOscuro : AppColors.borde),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isFailed ? 'Rechazado' : stepLabels[index],
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: isCompleted || isActive ? FontWeight.bold : FontWeight.normal,
                  color: isFailed 
                      ? AppColors.rojoCoral 
                      : (isCompleted || isActive ? AppColors.azulMarino : AppColors.textoMutado),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}
