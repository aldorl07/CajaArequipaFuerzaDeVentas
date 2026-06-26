import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class SolicitudesCreditoScreen extends StatelessWidget {
  const SolicitudesCreditoScreen({super.key});

  Future<void> _evaluarSolicitud(
    BuildContext context, {
    required String id,
    required String dni,
    required double amount,
    required bool aprobar,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (aprobar) {
        // Ejecución en transacción de Firestore
        await firestore.runTransaction((transaction) async {
          final clientRef = firestore.collection('clients').doc(dni);
          final requestRef = firestore.collection('credit_requests').doc(id);

          final clientDoc = await transaction.get(clientRef);
          if (!clientDoc.exists) {
            throw Exception('El cliente con DNI $dni no está registrado en la base de datos de Fuerza de Ventas.');
          }

          final clientData = clientDoc.data()!;
          final double savingsBalance = (clientData['savings_balance'] as num?)?.toDouble() ?? 0.0;

          // Aprobamos y acreditamos
          transaction.update(requestRef, {'status': 'Aprobado'});
          transaction.update(clientRef, {
            'current_loan_balance': amount,
            'savings_balance': savingsBalance + amount,
          });
        });

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Solicitud de crédito APROBADA con éxito. Saldo y deuda actualizados en Firestore.'),
            backgroundColor: AppColors.verdeCesped,
          ),
        );
      } else {
        // Rechazamos la solicitud
        await firestore.collection('credit_requests').doc(id).update({
          'status': 'Rechazado',
        });

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Solicitud de crédito RECHAZADA.'),
            backgroundColor: AppColors.rojoCoral,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error evaluando solicitud de crédito: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al evaluar la solicitud: $e'),
          backgroundColor: AppColors.rojoCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('Evaluación de Solicitudes'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('credit_requests')
            .where('status', isEqualTo: 'Pendiente')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          // Ordenar en memoria para priorizar las solicitudes más recientes (nuevas solicitudes arriba)
          final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
          sortedDocs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['request_date'] as Timestamp?;
            final bTime = bData['request_date'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // Descendente
          });

          if (sortedDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.azulMarino.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rate_review_outlined,
                      size: 64,
                      color: AppColors.azulMarino,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay solicitudes pendientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Las solicitudes de crédito de banca móvil aparecerán aquí.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textoMutado,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final doc = sortedDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final String id = doc.id;
              final String dni = data['dni'] ?? '';
              final String clientName = data['client_name'] ?? 'Cliente';
              final String creditType = data['credit_type'] ?? 'Crédito';
              final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
              final int term = data['term_months'] ?? 12;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.borde, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              clientName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.azulMarino,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amarilloMostaza.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'EVALUAR',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.amarilloMostaza,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'DNI: $dni',
                        style: const TextStyle(
                          color: AppColors.textoMutado,
                          fontSize: 13,
                        ),
                      ),
                      const Divider(height: 20, thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tipo de Crédito',
                                style: TextStyle(color: AppColors.textoMutado, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                creditType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Monto Solicitado',
                                style: TextStyle(color: AppColors.textoMutado, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'S/ ${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.azulMarino,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Plazo de Pago',
                                style: TextStyle(color: AppColors.textoMutado, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$term meses',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.rojoCoral.withValues(alpha: 0.12),
                              foregroundColor: AppColors.rojoCoral,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onPressed: () => _evaluarSolicitud(
                              context,
                              id: id,
                              dni: dni,
                              amount: amount,
                              aprobar: false,
                            ),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text(
                              'Rechazar',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdeCesped,
                              foregroundColor: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onPressed: () => _evaluarSolicitud(
                              context,
                              id: id,
                              dni: dni,
                              amount: amount,
                              aprobar: true,
                            ),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text(
                              'Aprobar',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
