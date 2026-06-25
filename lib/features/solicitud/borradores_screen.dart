import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import 'nueva_solicitud_screen.dart';

class BorradoresScreen extends StatefulWidget {
  const BorradoresScreen({super.key});

  @override
  State<BorradoresScreen> createState() => _BorradoresScreenState();
}

class _BorradoresScreenState extends State<BorradoresScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borradores Guardados'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('credit_requests')
            .where('status', isEqualTo: 'Borrador')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.turquesaBrillante));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar borradores: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.folder_open_outlined, size: 64, color: AppColors.textoMutado),
                  SizedBox(height: 16),
                  Text(
                    'No tienes borradores guardados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Puedes guardar borradores durante la captura.',
                    style: TextStyle(color: AppColors.textoMutado),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final String name = data['client_name'] ?? 'Borrador Sin Nombre';
              final String dni = doc.id;
              final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
              final int step = data['step_completed'] ?? 1;
              final String dateStr = data['created_at'] ?? '---';

              // Swipe to dismiss deletion
              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: AppColors.rojoCoral,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar Borrador'),
                      content: const Text('¿Está seguro de eliminar permanentemente este borrador de solicitud?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('CANCELAR'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojoCoral),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance.collection('credit_requests').doc(doc.id).delete();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Borrador eliminado con éxito.')),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('DNI: $dni • S/ ${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.textoOscuro)),
                        const SizedBox(height: 2),
                        Text('Guardado el: ${_formatDate(dateStr)}', style: const TextStyle(fontSize: 11, color: AppColors.textoMutado)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.turquesaOscuro.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Paso $step / 4',
                        style: const TextStyle(color: AppColors.turquesaOscuro, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NuevaSolicitudScreen(
                            prefilledDni: dni,
                            isResumingDraft: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return isoString;
    }
  }
}
