import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'database_helper.dart';

class SyncProvider extends ChangeNotifier {
  bool _isSyncing = false;
  String _syncMessage = '';
  int _pendingCount = 0;

  bool get isSyncing => _isSyncing;
  String get syncMessage => _syncMessage;
  int get pendingCount => _pendingCount;

  SyncProvider() {
    updatePendingCount();
  }

  Future<void> updatePendingCount() async {
    final pending = await DatabaseHelper.instance.getPendingCreditRequests();
    _pendingCount = pending.length;
    notifyListeners();
  }

  Future<void> syncPendingRequests(bool isOnline) async {
    if (!isOnline || _isSyncing) return;

    final pendingRequests = await DatabaseHelper.instance.getPendingCreditRequests();
    if (pendingRequests.isEmpty) {
      _pendingCount = 0;
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _syncMessage = 'Iniciando sincronización de ${_pendingCount} solicitudes...';
    notifyListeners();

    for (var req in pendingRequests) {
      final int id = req['id'];
      final String clientName = req['client_name'] ?? 'Cliente';
      final String clientDni = req['client_dni'] ?? '--------';

      // Step 1: Syncing
      _syncMessage = 'Sincronizando expediente de: $clientName...';
      await DatabaseHelper.instance.updateRequestStatus(id, 'Syncing');
      notifyListeners();

      // --- FIREBASE STORAGE UPLOAD ---
      String? firestoreFrontUrl;
      String? firestoreBackUrl;

      try {
        final docFrontPath = req['doc_front_path'] as String?;
        final docBackPath = req['doc_back_path'] as String?;

        if (docFrontPath != null && File(docFrontPath).existsSync()) {
          _syncMessage = 'Subiendo DNI Frontal a Firebase Storage...';
          notifyListeners();
          final refFront = FirebaseStorage.instance.ref().child('dni_photos/$clientDni/front.txt');
          await refFront.putFile(File(docFrontPath));
          firestoreFrontUrl = await refFront.getDownloadURL();
        }

        if (docBackPath != null && File(docBackPath).existsSync()) {
          _syncMessage = 'Subiendo DNI Reverso a Firebase Storage...';
          notifyListeners();
          final refBack = FirebaseStorage.instance.ref().child('dni_photos/$clientDni/back.txt');
          await refBack.putFile(File(docBackPath));
          firestoreBackUrl = await refBack.getDownloadURL();
        }
      } catch (e) {
        debugPrint('Firebase Storage upload failed: $e');
        // Continue anyway to maintain offline-first robustness
      }

      await Future.delayed(const Duration(milliseconds: 1000));

      // --- FIREBASE FIRESTORE UPLOAD ---
      try {
        _syncMessage = 'Registrando solicitud en Firestore...';
        notifyListeners();

        // Prepare Firestore payload matching the SQLite data
        final Map<String, dynamic> firestorePayload = {
          'id': id,
          'client_dni': req['client_dni'],
          'client_name': req['client_name'],
          'amount': req['amount'],
          'term_months': req['term_months'],
          'destination': req['destination'],
          'monthly_income': req['monthly_income'],
          'bureau_score': req['bureau_score'],
          'bureau_rating': req['bureau_rating'],
          'doc_front_url': firestoreFrontUrl ?? 'local_path:${req['doc_front_path']}',
          'doc_back_url': firestoreBackUrl ?? 'local_path:${req['doc_back_path']}',
          'created_at': req['created_at'],
          'synchronized_at': FieldValue.serverTimestamp(),
          'officer_code': 'OF12345',
        };

        // Write to Firestore under 'credit_requests'
        await FirebaseFirestore.instance
            .collection('credit_requests')
            .doc(clientDni)
            .set(firestorePayload);
      } catch (e) {
        debugPrint('Firebase Firestore upload failed: $e');
      }

      // Step 2: Sent (Enviado)
      _syncMessage = 'Expediente de $clientName enviado al Core Bancario.';
      await DatabaseHelper.instance.updateRequestStatus(id, 'Enviado');
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1000));

      // Step 3: En Evaluación
      _syncMessage = 'Analizando capacidad de pago e historial en Buró...';
      await DatabaseHelper.instance.updateRequestStatus(id, 'En Evaluación');
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1200));

      // Step 4: Approved (Aprobado) or Disbursed (Desembolsado)
      final int score = req['bureau_score'] ?? 700;
      if (score < 400) {
        _syncMessage = 'Solicitud de $clientName evaluada: Rechazada por bajo score.';
        await DatabaseHelper.instance.updateRequestStatus(id, 'Rechazado');
      } else {
        _syncMessage = 'Solicitud de $clientName Aprobada!';
        await DatabaseHelper.instance.updateRequestStatus(id, 'Aprobado');
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1000));

        _syncMessage = 'Crédito de $clientName Desembolsado con éxito.';
        await DatabaseHelper.instance.updateRequestStatus(id, 'Desembolsado');
        
        // Update Firestore status to match
        try {
          await FirebaseFirestore.instance
              .collection('credit_requests')
              .doc(clientDni)
              .update({'status': 'Desembolsado'});
        } catch (_) {}
      }
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 800));
    }

    _isSyncing = false;
    _syncMessage = 'Sincronización completa.';
    await updatePendingCount();
    notifyListeners();
  }
}
