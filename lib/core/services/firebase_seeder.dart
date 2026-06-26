import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseSeeder {
  static Future<void> seedDatabase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('clients').limit(1).get();

      // If clients collection is empty, seed initial data
      if (querySnapshot.docs.isEmpty) {
        debugPrint('Seeding Firestore clients collection...');
        final List<Map<String, dynamic>> mockClients = [
          {
            'dni': '45892147',
            'name': 'María Elena Flores Mamani',
            'address': 'Av. Dolores 124, José Luis Bustamante y Rivero',
            'phone': '958471236',
            'credit_renewal_amount': 15000.0,
            'credit_renewal_due_days': 5,
            'credit_risk_tier': 'Bajo',
            'savings_balance': 3500.0,
            'current_loan_balance': 2400.0,
            'latitude': -16.4258,
            'longitude': -71.5235,
            'payment_behavior': 'Excelente',
            'visit_scheduled': '2026-06-26',
            'visit_order': 1,
            'isVisited': false,
            'managementType': 'Renovación',
          },
          {
            'dni': '10235698',
            'name': 'Juan Carlos Quispe Huamaní',
            'address': 'Calle Melgar 302, Cercado',
            'phone': '984512369',
            'credit_renewal_amount': 25000.0,
            'credit_renewal_due_days': 2,
            'credit_risk_tier': 'Bajo',
            'savings_balance': 8900.0,
            'current_loan_balance': 0.0,
            'latitude': -16.3989,
            'longitude': -71.5350,
            'payment_behavior': 'Excelente',
            'visit_scheduled': '2026-06-26',
            'visit_order': 2,
            'isVisited': false,
            'managementType': 'Renovación',
          },
          {
            'dni': '29654123',
            'name': 'Rosa Luz Choque Condori',
            'address': 'Mercado El Altiplano, Puesto 45, Miraflores',
            'phone': '959847123',
            'credit_renewal_amount': 8000.0,
            'credit_renewal_due_days': 12,
            'credit_risk_tier': 'Medio',
            'savings_balance': 1200.0,
            'current_loan_balance': 5400.0,
            'latitude': -16.3892,
            'longitude': -71.5098,
            'payment_behavior': 'Regular',
            'visit_scheduled': '2026-06-26',
            'visit_order': 3,
            'isVisited': false,
            'managementType': 'Nuevo',
          },
          {
            'dni': '09874512',
            'name': 'Pedro Abelardo Mendoza Zúñiga',
            'address': 'Jr. Puno 415, Yanahuara',
            'phone': '974512365',
            'credit_renewal_amount': 45000.0,
            'credit_renewal_due_days': -3,
            'credit_risk_tier': 'Bajo',
            'savings_balance': 15000.0,
            'current_loan_balance': 12500.0,
            'latitude': -16.3885,
            'longitude': -71.5455,
            'payment_behavior': 'Excelente',
            'visit_scheduled': '2026-06-26',
            'visit_order': 4,
            'isVisited': false,
            'managementType': 'Cobranza',
          },
          {
            'dni': '41236987',
            'name': 'Carmen Rosa Apaza Vargas',
            'address': 'Asoc. Apipa Sector 3 Mz. D Lote 12, Cerro Colorado',
            'phone': '948123569',
            'credit_renewal_amount': 5000.0,
            'credit_renewal_due_days': 8,
            'credit_risk_tier': 'Alto',
            'savings_balance': 350.0,
            'current_loan_balance': 4800.0,
            'latitude': -16.3355,
            'longitude': -71.5699,
            'payment_behavior': 'Crítico',
            'visit_scheduled': '2026-06-26',
            'visit_order': 5,
            'isVisited': false,
            'managementType': 'Cobranza',
          }
        ];

        for (var client in mockClients) {
          final String dni = client['dni'];
          await firestore.collection('clients').doc(dni).set(client);
        }
        debugPrint('Firestore clients collection seeded successfully.');
      } else {
        debugPrint('Firestore clients collection already seeded.');
      }

      // Seed officers collection
      final officersSnapshot = await firestore.collection('officers').limit(1).get();
      if (officersSnapshot.docs.isEmpty) {
        debugPrint('Seeding Firestore officers collection...');
        final List<Map<String, dynamic>> mockOfficers = [
          {
            'code': 'OF12345',
            'name': 'Aldo Requena',
            'password': 'caja123',
            'role': 'operador',
          },
          {
            'code': 'OF10001',
            'name': 'Carlos Mendoza',
            'password': 'caja123',
            'role': 'operador',
          },
          {
            'code': 'OF10002',
            'name': 'Ana Gómez',
            'password': 'caja123',
            'role': 'operador',
          },
          {
            'code': 'OF10003',
            'name': 'Luis Flores',
            'password': 'caja123',
            'role': 'operador',
          },
          {
            'code': 'OF10004',
            'name': 'Diana Castro',
            'password': 'caja123',
            'role': 'operador',
          },
          {
            'code': 'OF10005',
            'name': 'Fernando Torres',
            'password': 'caja123',
            'role': 'operador',
          },
        ];

        for (var officer in mockOfficers) {
          final String code = officer['code'];
          await firestore.collection('officers').doc(code).set(officer);
        }
        debugPrint('Firestore officers collection seeded successfully.');
      } else {
        debugPrint('Firestore officers collection already seeded.');
      }
    } catch (e) {
      debugPrint('Error seeding Firestore database: $e');
    }
  }
}
