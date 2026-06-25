import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/services/database_helper.dart';
import 'ficha_cliente_screen.dart';
import '../solicitud/nueva_solicitud_screen.dart';

class CarteraScreen extends StatefulWidget {
  const CarteraScreen({super.key});

  @override
  State<CarteraScreen> createState() => _CarteraScreenState();
}

class _CarteraScreenState extends State<CarteraScreen> {
  List<Map<String, dynamic>> _allClients = [];
  List<Map<String, dynamic>> _filteredClients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'Todos'; // 'Todos', 'Renovaciones', 'Vencidos'

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    final clients = await DatabaseHelper.instance.getClients();
    setState(() {
      _allClients = clients;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    List<Map<String, dynamic>> temp = List.from(_allClients);

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((c) {
        final name = (c['name'] ?? '').toString().toLowerCase();
        final dni = (c['dni'] ?? '').toString();
        return name.contains(_searchQuery.toLowerCase()) || dni.contains(_searchQuery);
      }).toList();
    }

    // Tab category filter
    if (_selectedFilter == 'Renovaciones') {
      // Due soon (within 10 days and not expired)
      temp = temp.where((c) {
        final dueDays = c['credit_renewal_due_days'] ?? 0;
        return dueDays >= 0 && dueDays <= 10;
      }).toList();
    } else if (_selectedFilter == 'Vencidos') {
      // Expired (negative days)
      temp = temp.where((c) {
        final dueDays = c['credit_renewal_due_days'] ?? 0;
        return dueDays < 0;
      }).toList();
    }

    setState(() {
      _filteredClients = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Filter header
        Container(
          color: AppColors.azulMarino,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // Search text field
              TextField(
                onChanged: (val) {
                  _searchQuery = val;
                  _applyFilter();
                },
                style: const TextStyle(color: AppColors.textoOscuro),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o DNI...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.azulMarino),
                  fillColor: AppColors.blancoPuro,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Filter Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterChip('Todos'),
                  _buildFilterChip('Renovaciones'),
                  _buildFilterChip('Vencidos'),
                ],
              ),
            ],
          ),
        ),

        // List body
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.turquesaBrillante))
              : _filteredClients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: AppColors.textoMutado.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'No se encontraron clientes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Prueba cambiando el término de búsqueda',
                            style: TextStyle(color: AppColors.textoMutado),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadClients,
                      color: AppColors.turquesaBrillante,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = _filteredClients[index];
                          return _buildClientCard(client);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _applyFilter();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.turquesaBrillante : AppColors.azulMarino.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.turquesaBrillante : AppColors.blancoPuro.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.azulMarino : AppColors.blancoPuro,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final String name = client['name'] ?? 'Sin Nombre';
    final String dni = client['dni'] ?? '--------';
    final double renewalAmount = client['credit_renewal_amount'] ?? 0.0;
    final int dueDays = client['credit_renewal_due_days'] ?? 0;
    final String riskTier = client['credit_risk_tier'] ?? 'Bajo';
    
    // Choose color for risk tier
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

    // Renew status indicator
    String renewalText = '';
    Color renewalColor = AppColors.textoMutado;
    if (dueDays < 0) {
      renewalText = 'VENCIDO HACE ${dueDays.abs()} DÍAS';
      renewalColor = AppColors.rojoCoral;
    } else if (dueDays == 0) {
      renewalText = 'VENCE HOY';
      renewalColor = AppColors.amarilloMostaza;
    } else {
      renewalText = 'VENCE EN $dueDays DÍAS';
      renewalColor = dueDays <= 5 ? AppColors.amarilloMostaza : AppColors.verdeCesped;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FichaClienteScreen(clientDni: dni),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Name and Risk Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulMarino,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: riskColor, width: 0.8),
                    ),
                    child: Text(
                      'Riesgo: $riskTier',
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Row 2: DNI
              Text(
                'DNI: $dni',
                style: const TextStyle(color: AppColors.textoMutado, fontSize: 13),
              ),
              const SizedBox(height: 12),
              
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Row 3: Renewal details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monto Sugerido:',
                        style: TextStyle(fontSize: 11, color: AppColors.textoMutado),
                      ),
                      Text(
                        'S/ ${renewalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulMarino,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: renewalColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      renewalText,
                      style: TextStyle(
                        color: renewalColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 4: Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FichaClienteScreen(clientDni: dni),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Ficha'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.azulMarino,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NuevaSolicitudScreen(prefilledDni: dni),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Solicitud'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.turquesaBrillante,
                      foregroundColor: AppColors.azulMarino,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
