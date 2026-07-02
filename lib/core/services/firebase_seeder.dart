import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseSeeder {
  static Future<void> seedDatabase() async {
    try {
      final firestore = FirebaseFirestore.instance;

      debugPrint('Seeding Firestore clients collection with 30 cases...');

      // Definición compacta de los 30 casos de la rúbrica
      final List<Map<String, dynamic>> rawCases = [
        {'dni': '40118120', 'name': 'Anaximandro Quispe', 'phone': '964110201', 'lat': -12.0581, 'lng': -75.2027, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'El Tambo'},
        {'dni': '41223341', 'name': 'Eulalia Mamani', 'phone': '964110202', 'lat': -12.0921, 'lng': -75.2105, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Chilca'},
        {'dni': '42330336', 'name': 'Teofilo Huaman', 'phone': '964110203', 'lat': -12.0496, 'lng': -75.2486, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Pilcomayo'},
        {'dni': '43440349', 'name': 'Casandra Flores', 'phone': '964110204', 'lat': -12.0651, 'lng': -75.2049, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Huancayo'},
        {'dni': '40556071', 'name': 'Demostenes Rojas', 'phone': '964110205', 'lat': -12.0188, 'lng': -75.2271, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'San Agustin de Cajas'},
        {'dni': '41669066', 'name': 'Hipatia Condori', 'phone': '964110206', 'lat': -12.0612, 'lng': -75.2118, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'El Tambo'},
        {'dni': '43773379', 'name': 'Anibal Vargas', 'phone': '964110207', 'lat': -11.9182, 'lng': -75.3142, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Concepcion'},
        {'dni': '40886086', 'name': 'Penelope Apaza', 'phone': '964110208', 'lat': -12.1581, 'lng': -75.1762, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Sapallanga'},
        {'dni': '41990091', 'name': 'Heraclito Ccahua', 'phone': '964110209', 'lat': -12.0668, 'lng': -75.2103, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Huancayo'},
        {'dni': '43003039', 'name': 'Cleopatra Soto', 'phone': '964110210', 'lat': -12.0560, 'lng': -75.2870, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Chupaca'},
        {'dni': '40110010', 'name': 'Esquilo Ramos', 'phone': '964110211', 'lat': -12.1339, 'lng': -75.2090, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Huayucachi'},
        {'dni': '41226021', 'name': 'Ariadna Quispe', 'phone': '964110212', 'lat': -12.0573, 'lng': -75.2161, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'El Tambo'},
        {'dni': '43336033', 'name': 'Sofocles Huanca', 'phone': '964110213', 'lat': -12.0228, 'lng': -75.3134, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Sicaya'},
        {'dni': '40550055', 'name': 'Casiopea Torres', 'phone': '964110214', 'lat': -12.0512, 'lng': -75.2451, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Pilcomayo'},
        {'dni': '41669166', 'name': 'Aristofanes Cruz', 'phone': '964110215', 'lat': -11.9760, 'lng': -75.3361, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Orcotuna'},
        {'dni': '43880088', 'name': 'Calipso Mendoza', 'phone': '964110216', 'lat': -12.0689, 'lng': -75.2055, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Huancayo'},
        {'dni': '40119019', 'name': 'Demetrio Quispe', 'phone': '964110217', 'lat': -11.7752, 'lng': -75.4995, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Jauja'},
        {'dni': '41226126', 'name': 'Antigona Flores', 'phone': '964110218', 'lat': -11.9201, 'lng': -75.3110, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Concepcion'},
        {'dni': '43339033', 'name': 'Pitagoras Rojas', 'phone': '964110219', 'lat': -12.0599, 'lng': -75.2143, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'El Tambo'},
        {'dni': '40556056', 'name': 'Berenice Apaza', 'phone': '964110220', 'lat': -11.9871, 'lng': -75.2899, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'San Jeronimo de Tunan'},
        {'dni': '43889089', 'name': 'Anaxagoras Huaman', 'phone': '964110221', 'lat': -12.0644, 'lng': -75.2088, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Huancayo'},
        {'dni': '41003001', 'name': 'Climene Vargas', 'phone': '964110222', 'lat': -12.1560, 'lng': -75.1790, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Sapallanga'},
        {'dni': '40115011', 'name': 'Epaminondas Soto', 'phone': '964110223', 'lat': -12.1701, 'lng': -75.1611, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Pucara'},
        {'dni': '41336036', 'name': 'Lisistrata Ramos', 'phone': '964110224', 'lat': -12.0633, 'lng': -75.2071, 'tier': 'Bajo', 'behavior': 'Excelente', 'addr': 'Huancayo'},
        {'dni': '41552052', 'name': 'Filoctetes Cruz', 'phone': '964110225', 'lat': -12.0930, 'lng': -75.2090, 'tier': 'Medio', 'behavior': 'Regular', 'addr': 'Chilca'},
        {'dni': '41888088', 'name': 'Calirroe Mendoza', 'phone': '964110226', 'lat': -12.0588, 'lng': -75.2129, 'tier': 'Medio', 'behavior': 'Regular', 'addr': 'El Tambo'},
        {'dni': '42220022', 'name': 'Tucidides Quispe', 'phone': '964110227', 'lat': -11.9176, 'lng': -75.3155, 'tier': 'Medio', 'behavior': 'Regular', 'addr': 'Concepcion'},
        {'dni': '43337037', 'name': 'Aquiles Mamani', 'phone': '964110228', 'lat': -12.0657, 'lng': -75.2099, 'tier': 'Alto', 'behavior': 'Malo', 'addr': 'Huancayo'},
        {'dni': '41884084', 'name': 'Medea Apaza', 'phone': '964110229', 'lat': -12.0489, 'lng': -75.2470, 'tier': 'Alto', 'behavior': 'Crítico', 'addr': 'Pilcomayo'},
        {'dni': '43334034', 'name': 'Esquines Rojas', 'phone': '964110230', 'lat': -11.7740, 'lng': -75.5010, 'tier': 'Alto', 'behavior': 'Crítico', 'addr': 'Jauja'}
      ];

      int order = 1;
      for (var c in rawCases) {
        final String dni = c['dni'] as String;
        final String name = c['name'] as String;
        final String phone = c['phone'] as String;
        final double lat = c['lat'] as double;
        final double lng = c['lng'] as double;
        final String tier = c['tier'] as String;
        final String behavior = c['behavior'] as String;
        final String addr = c['addr'] as String;

        final clientData = {
          'dni': dni,
          'name': name,
          'address': 'Av. Principal ${100 + order}, $addr',
          'phone': phone,
          'credit_renewal_amount': 0.0,
          'credit_renewal_due_days': 0,
          'credit_risk_tier': tier,
          'savings_balance': 3000.0,
          'current_loan_balance': 0.0,
          'latitude': lat,
          'longitude': lng,
          'payment_behavior': behavior,
          'visit_scheduled': '2026-07-02',
          'visit_order': order,
          'isVisited': false,
          'managementType': 'Nuevo',
        };

        await firestore.collection('clients').doc(dni).set(clientData);
        order++;
      }

      // Asegurar que Aldo Alexandre Requena Lavi esté registrado en Firestore
      final aldoClient = {
        'dni': '12345678',
        'name': 'Aldo Alexandre Requena Lavi',
        'address': 'Av. Arequipa 456, Cercado',
        'phone': '999888777',
        'credit_renewal_amount': 0.0,
        'credit_renewal_due_days': 0,
        'credit_risk_tier': 'Bajo',
        'savings_balance': 2000.0,
        'current_loan_balance': 0.0,
        'latitude': -12.0496,
        'longitude': -75.2486,
        'payment_behavior': 'Excelente',
        'visit_scheduled': '2026-07-02',
        'visit_order': 31,
        'isVisited': false,
        'managementType': 'Nuevo',
      };
      await firestore.collection('clients').doc('12345678').set(aldoClient);
      debugPrint('Client Aldo Alexandre Requena Lavi seeded/updated explicitly.');

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
