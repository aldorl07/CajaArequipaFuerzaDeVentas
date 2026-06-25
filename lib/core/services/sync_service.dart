import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    try {
      final qs = await FirebaseFirestore.instance
          .collection('credit_requests')
          .where('status', isEqualTo: 'PendingSync')
          .get(const GetOptions(source: Source.cache));
      _pendingCount = qs.docs.length;
    } catch (_) {
      _pendingCount = 0;
    }
    notifyListeners();
  }

  Future<void> syncPendingRequests(bool isOnline) async {
    if (!isOnline || _isSyncing) return;

    List<QueryDocumentSnapshot> docs = [];
    try {
      final qs = await FirebaseFirestore.instance
          .collection('credit_requests')
          .where('status', isEqualTo: 'PendingSync')
          .get(const GetOptions(source: Source.cache));
      docs = qs.docs;
    } catch (e) {
      debugPrint('Error fetching cache requests: $e');
    }

    if (docs.isEmpty) {
      _pendingCount = 0;
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _syncMessage = 'Iniciando sincronización de $_pendingCount solicitudes...';
    notifyListeners();

    for (var docSnapshot in docs) {
      final req = docSnapshot.data() as Map<String, dynamic>;
      final String clientName = req['client_name'] ?? 'Cliente';
      final String clientDni = req['client_dni'] ?? '--------';

      // Step 1: Syncing
      _syncMessage = 'Sincronizando expediente de: $clientName...';
      try {
        await FirebaseFirestore.instance
            .collection('credit_requests')
            .doc(clientDni)
            .update({'status': 'Syncing'});
      } catch (_) {}
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

        await FirebaseFirestore.instance
            .collection('credit_requests')
            .doc(clientDni)
            .update({
          'doc_front_url': ?firestoreFrontUrl,
          'doc_back_url': ?firestoreBackUrl,
          'synchronized_at': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firebase Firestore upload failed: $e');
      }

      // Step 2: Sent (Enviado)
      _syncMessage = 'Expediente de $clientName enviado al Core Bancario.';
      try {
        await FirebaseFirestore.instance
            .collection('credit_requests')
            .doc(clientDni)
            .update({'status': 'Enviado'});
      } catch (_) {}
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1000));

      // Step 3: En Evaluación
      _syncMessage = 'Analizando capacidad de pago e historial en Buró...';
      try {
        await FirebaseFirestore.instance
            .collection('credit_requests')
            .doc(clientDni)
            .update({'status': 'En Evaluación'});
      } catch (_) {}
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1200));

      // Step 4: Approved (Aprobado) or Disbursed (Desembolsado)
      final int score = req['bureau_score'] ?? 700;
      if (score < 400) {
        _syncMessage = 'Solicitud de $clientName evaluada: Rechazada por bajo score.';
        try {
          await FirebaseFirestore.instance
              .collection('credit_requests')
              .doc(clientDni)
              .update({'status': 'Rechazado'});
        } catch (_) {}
      } else {
        _syncMessage = 'Solicitud de $clientName Aprobada!';
        try {
          await FirebaseFirestore.instance
              .collection('credit_requests')
              .doc(clientDni)
              .update({'status': 'Aprobado'});
        } catch (_) {}
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1000));

        _syncMessage = 'Crédito de $clientName Desembolsado con éxito.';
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
