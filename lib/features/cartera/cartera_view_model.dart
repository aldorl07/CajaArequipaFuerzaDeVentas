import 'package:flutter/material.dart';

class VisitClient {
  final String dni;
  final String name;
  final String managementType; // 'Renovación', 'Nuevo', 'Cobranza'
  bool isVisited; // false = pendiente, true = visitado
  final double amount;
  final String address;

  VisitClient({
    required this.dni,
    required this.name,
    required this.managementType,
    this.isVisited = false,
    required this.amount,
    required this.address,
  });
}

class CarteraViewModel extends ChangeNotifier {
  final List<VisitClient> _clients = [
    VisitClient(
      dni: '45892147',
      name: 'María Elena Flores Mamani',
      managementType: 'Renovación',
      isVisited: false,
      amount: 15000.0,
      address: 'Av. Dolores 124, José Luis Bustamante y Rivero',
    ),
    VisitClient(
      dni: '10235698',
      name: 'Juan Carlos Quispe Huamaní',
      managementType: 'Renovación',
      isVisited: false,
      amount: 25000.0,
      address: 'Calle Melgar 302, Cercado',
    ),
    VisitClient(
      dni: '29654123',
      name: 'Rosa Luz Choque Condori',
      managementType: 'Nuevo',
      isVisited: false,
      amount: 8000.0,
      address: 'Mercado El Altiplano, Puesto 45, Miraflores',
    ),
    VisitClient(
      dni: '09874512',
      name: 'Pedro Abelardo Mendoza Zúñiga',
      managementType: 'Cobranza',
      isVisited: false,
      amount: 12500.0,
      address: 'Jr. Puno 415, Yanahuara',
    ),
    VisitClient(
      dni: '41236987',
      name: 'Carmen Rosa Apaza Vargas',
      managementType: 'Cobranza',
      isVisited: false,
      amount: 4800.0,
      address: 'Asoc. Apipa Sector 3 Mz. D Lote 12, Cerro Colorado',
    ),
  ];

  List<VisitClient> get clients => _clients;

  int get totalVisits => _clients.length;
  
  int get completedVisits => _clients.where((c) => c.isVisited).length;
  
  int get pendingVisits => _clients.where((c) => !c.isVisited).length;

  void toggleVisitStatus(int index) {
    if (index >= 0 && index < _clients.length) {
      _clients[index].isVisited = !_clients[index].isVisited;
      notifyListeners();
    }
  }

  void setVisited(String dni, bool isVisited) {
    final clientIndex = _clients.indexWhere((c) => c.dni == dni);
    if (clientIndex != -1) {
      _clients[clientIndex].isVisited = isVisited;
      notifyListeners();
    }
  }
}
