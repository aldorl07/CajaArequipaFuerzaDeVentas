import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitClient {
  final String dni;
  final String name;
  final String managementType; // 'Renovación', 'Nuevo', 'Cobranza'
  final bool isVisited; // false = pendiente, true = visitado
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

  factory VisitClient.fromMap(Map<String, dynamic> map) {
    return VisitClient(
      dni: map['dni'] ?? '',
      name: map['name'] ?? '',
      managementType: map['managementType'] ?? 'Renovación',
      isVisited: map['isVisited'] ?? false,
      amount: (map['credit_renewal_amount'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
    );
  }
}

class CarteraViewModel extends ChangeNotifier {
  List<VisitClient> _clients = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  List<VisitClient> get clients => _clients;

  int get totalVisits => _clients.length;
  
  int get completedVisits => _clients.where((c) => c.isVisited).length;
  
  int get pendingVisits => _clients.where((c) => !c.isVisited).length;

  CarteraViewModel() {
    _listenToClients();
  }

  void _listenToClients() {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('clients')
        .orderBy('visit_order', descending: false)
        .snapshots()
        .listen((snapshot) {
      _clients = snapshot.docs
          .map((doc) => VisitClient.fromMap(doc.data()))
          .toList();
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error listening to clients: $error');
    });
  }

  Future<void> toggleVisitStatus(int index) async {
    if (index >= 0 && index < _clients.length) {
      final client = _clients[index];
      final newStatus = !client.isVisited;
      
      // Update in Firestore (works offline natively)
      try {
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(client.dni)
            .update({'isVisited': newStatus});
      } catch (e) {
        debugPrint('Error toggling visit status: $e');
      }
    }
  }

  Future<void> setVisited(String dni, bool isVisited) async {
    try {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(dni)
          .update({'isVisited': isVisited});
    } catch (e) {
      debugPrint('Error setting visited: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
