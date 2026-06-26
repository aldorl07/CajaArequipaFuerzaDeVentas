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
  final double? visitLatitude;
  final double? visitLongitude;
  final String? visitTimestamp;
  final String? status;

  VisitClient({
    required this.dni,
    required this.name,
    required this.managementType,
    this.isVisited = false,
    required this.amount,
    required this.address,
    this.visitLatitude,
    this.visitLongitude,
    this.visitTimestamp,
    this.status,
  });

  factory VisitClient.fromMap(Map<String, dynamic> map) {
    return VisitClient(
      dni: map['dni'] ?? '',
      name: map['name'] ?? '',
      managementType: map['managementType'] ?? 'Renovación',
      isVisited: map['isVisited'] ?? false,
      amount: (map['credit_renewal_amount'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
      visitLatitude: (map['visit_latitude'] as num?)?.toDouble(),
      visitLongitude: (map['visit_longitude'] as num?)?.toDouble(),
      visitTimestamp: map['visit_timestamp'],
      status: map['status'],
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

  Future<void> reorderClients(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex) return;

    // Reorder locally
    final VisitClient moved = _clients.removeAt(oldIndex);
    _clients.insert(newIndex, moved);
    notifyListeners();

    // Commit reorder in batch to Firestore
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < _clients.length; i++) {
      final docRef = FirebaseFirestore.instance.collection('clients').doc(_clients[i].dni);
      batch.update(docRef, {'visit_order': i + 1});
    }

    try {
      await batch.commit();
    } catch (e) {
      debugPrint('Error saving reordered list: $e');
    }
  }

  Future<void> toggleVisitStatus(int index) async {
    if (index >= 0 && index < _clients.length) {
      final client = _clients[index];
      final newStatus = !client.isVisited;
      
      final Map<String, dynamic> updates = {
        'isVisited': newStatus,
      };

      if (newStatus) {
        // Capture simulated geolocated coordinates
        updates['visit_latitude'] = -16.4090 + (index * 0.001);
        updates['visit_longitude'] = -71.5360 - (index * 0.001);
        updates['visit_timestamp'] = DateTime.now().toIso8601String();
      } else {
        updates['visit_latitude'] = FieldValue.delete();
        updates['visit_longitude'] = FieldValue.delete();
        updates['visit_timestamp'] = FieldValue.delete();
      }

      try {
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(client.dni)
            .update(updates);
      } catch (e) {
        debugPrint('Error toggling visit status: $e');
      }
    }
  }

  Future<void> setVisited(String dni, bool isVisited) async {
    final Map<String, dynamic> updates = {
      'isVisited': isVisited,
    };

    if (isVisited) {
      updates['visit_latitude'] = -16.4090;
      updates['visit_longitude'] = -71.5360;
      updates['visit_timestamp'] = DateTime.now().toIso8601String();
    } else {
      updates['visit_latitude'] = FieldValue.delete();
      updates['visit_longitude'] = FieldValue.delete();
      updates['visit_timestamp'] = FieldValue.delete();
    }

    try {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(dni)
          .update(updates);
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

