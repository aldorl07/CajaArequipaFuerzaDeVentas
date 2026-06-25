import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('caja_arequipa_fuerza_ventas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table 1: Clients (Daily portfolio cache)
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dni TEXT UNIQUE,
        name TEXT,
        address TEXT,
        phone TEXT,
        credit_renewal_amount REAL,
        credit_renewal_due_days INTEGER,
        credit_risk_tier TEXT,
        savings_balance REAL,
        current_loan_balance REAL,
        latitude REAL,
        longitude REAL,
        payment_behavior TEXT,
        visit_scheduled TEXT,
        visit_order INTEGER
      )
    ''');

    // Table 2: Credit Requests (Offline-first capture form)
    await db.execute('''
      CREATE TABLE credit_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_dni TEXT,
        client_name TEXT,
        amount REAL,
        term_months INTEGER,
        destination TEXT,
        monthly_income REAL,
        bureau_score INTEGER,
        bureau_rating TEXT,
        doc_front_path TEXT,
        doc_back_path TEXT,
        status TEXT,
        created_at TEXT
      )
    ''');

    // Seed initial mock clients
    await _seedMockData(db);
  }

  Future<void> _seedMockData(Database db) async {
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
        'visit_order': 1
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
        'visit_order': 2
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
        'visit_order': 3
      },
      {
        'dni': '09874512',
        'name': 'Pedro Abelardo Mendoza Zúñiga',
        'address': 'Jr. Puno 415, Yanahuara',
        'phone': '974512365',
        'credit_renewal_amount': 45000.0,
        'credit_renewal_due_days': -3, // Vencido
        'credit_risk_tier': 'Bajo',
        'savings_balance': 15000.0,
        'current_loan_balance': 12500.0,
        'latitude': -16.3885,
        'longitude': -71.5455,
        'payment_behavior': 'Excelente',
        'visit_scheduled': '2026-06-26',
        'visit_order': 4
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
        'visit_order': 5
      },
      {
        'dni': '30245698',
        'name': 'José Luis Medina Torres',
        'address': 'Urb. La Joya Mz. Z Lote 3, Cayma',
        'phone': '936541287',
        'credit_renewal_amount': 12000.0,
        'credit_renewal_due_days': 15,
        'credit_risk_tier': 'Medio',
        'savings_balance': 2300.0,
        'current_loan_balance': 1000.0,
        'latitude': -16.3688,
        'longitude': -71.5580,
        'payment_behavior': 'Regular',
        'visit_scheduled': '2026-06-27',
        'visit_order': 1
      },
      {
        'dni': '42369854',
        'name': 'Sofía Alejandra Ramos Pineda',
        'address': 'Av. Kennedy 804, Paucarpata',
        'phone': '912345678',
        'credit_renewal_amount': 20000.0,
        'credit_renewal_due_days': 0, // Vence hoy
        'credit_risk_tier': 'Bajo',
        'savings_balance': 4100.0,
        'current_loan_balance': 750.0,
        'latitude': -16.4180,
        'longitude': -71.5050,
        'payment_behavior': 'Excelente',
        'visit_scheduled': '2026-06-27',
        'visit_order': 2
      }
    ];

    for (var client in mockClients) {
      await db.insert('clients', client);
    }
  }

  // --- CLIENTS OPERATIONS ---

  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await database;
    return await db.query('clients', orderBy: 'visit_order ASC');
  }

  Future<Map<String, dynamic>?> getClientByDni(String dni) async {
    final db = await database;
    final results = await db.query(
      'clients',
      where: 'dni = ?',
      whereArgs: [dni],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // --- CREDIT REQUESTS OPERATIONS ---

  Future<int> insertCreditRequest(Map<String, dynamic> request) async {
    final db = await database;
    return await db.insert('credit_requests', request);
  }

  Future<List<Map<String, dynamic>>> getCreditRequests() async {
    final db = await database;
    return await db.query('credit_requests', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getPendingCreditRequests() async {
    final db = await database;
    return await db.query(
      'credit_requests',
      where: 'status = ?',
      whereArgs: ['PendingSync'],
    );
  }

  Future<int> updateRequestStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'credit_requests',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCreditRequest(int id) async {
    final db = await database;
    return await db.delete(
      'credit_requests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllRequests() async {
    final db = await database;
    await db.delete('credit_requests');
  }
}
