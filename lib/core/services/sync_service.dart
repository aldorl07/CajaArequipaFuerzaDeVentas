import 'dart:async';
import 'package:flutter/material.dart';
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

      // Step 1: Syncing
      _syncMessage = 'Sincronizando expediente de: $clientName...';
      await DatabaseHelper.instance.updateRequestStatus(id, 'Syncing');
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1200));

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
      // We check if bureau score is low/high or random
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
