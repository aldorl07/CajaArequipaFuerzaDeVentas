import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AlertasCampanasScreen extends StatelessWidget {
  const AlertasCampanasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alertas y Campañas'),
          bottom: const TabBar(
            indicatorColor: AppColors.turquesaBrillante,
            labelColor: AppColors.turquesaBrillante,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.campaign), text: 'Campañas Activas'),
              Tab(icon: Icon(Icons.notifications_active), text: 'Alertas Operativas'),
            ],
          ),
        ),
        body: Container(
          color: AppColors.grisClaro,
          child: const TabBarView(
            children: [
              CampanasTab(),
              AlertasTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class CampanasTab extends StatelessWidget {
  const CampanasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> campaigns = [
      {
        'title': 'Campaña Fiestas Patrias 2026',
        'subtitle': 'Tasa Preferencial Microempresas',
        'desc': 'Tasas reducidas desde 18.5% TEA para clientes recurrentes en sectores Comercio y Producción. Válida hasta el 31 de Julio.',
        'tag': 'COMERCIO / PYME',
        'icon': 'flag',
      },
      {
        'title': 'Campaña Campiña Arequipeña',
        'subtitle': 'Financiamiento del Sector Agropecuario',
        'desc': 'Plazos de hasta 36 meses con pagos estacionales adaptados al ciclo de cosecha. Tasa promedio 24% TEA.',
        'tag': 'AGROPECUARIO',
        'icon': 'agriculture',
      },
      {
        'title': 'Campaña Incremento de Línea Exprés',
        'subtitle': 'Aprobación Inmediata a Sola Firma',
        'desc': 'Clientes calificados en score de buró > 740 acceden a incrementos de línea de hasta S/ 15,000 sin papeles adicionales.',
        'tag': 'RECURRENTES',
        'icon': 'bolt',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final c = campaigns[index];
        IconData itemIcon;
        Color tagColor;

        if (c['icon'] == 'flag') {
          itemIcon = Icons.outlined_flag;
          tagColor = AppColors.rojoCoral;
        } else if (c['icon'] == 'agriculture') {
          itemIcon = Icons.agriculture;
          tagColor = AppColors.verdeCesped;
        } else {
          itemIcon = Icons.offline_bolt_outlined;
          tagColor = AppColors.turquesaOscuro;
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: tagColor, width: 0.5),
                      ),
                      child: Text(
                        c['tag']!,
                        style: TextStyle(color: tagColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.share, size: 18, color: AppColors.textoMutado),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.azulMarino.withValues(alpha: 0.08),
                      child: Icon(itemIcon, color: AppColors.azulMarino),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.azulMarino),
                          ),
                          Text(
                            c['subtitle']!,
                            style: const TextStyle(color: AppColors.textoMutado, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            c['desc']!,
                            style: const TextStyle(color: AppColors.textoOscuro, fontSize: 12.5),
                          ),
                        ],
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
  }
}

class AlertasTab extends StatelessWidget {
  const AlertasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> alerts = [
      {
        'title': 'Priorización de Cartera Pendiente',
        'body': 'Recuerde prioritizar el orden de visitas diarias arrastrando y soltando (drag & drop) los clientes en su cartera hoy.',
        'severity': 'info',
        'time': 'Hace 5 min',
      },
      {
        'title': 'Alerta de Mora Crítica - SBS',
        'body': 'La cliente Carmen Rosa Apaza Vargas presenta score crítico en Buró con atraso de pago de 8 días. Registre visita de cobranza hoy.',
        'severity': 'high',
        'time': 'Hace 1 hora',
      },
      {
        'title': 'Actualización de Tipos de Cambio',
        'body': 'Los tipos de cambio referenciales para Solicitudes en Dólares (USD) se han actualizado a S/ 3.785.',
        'severity': 'normal',
        'time': 'Hace 2 horas',
      },
      {
        'title': 'Solicitud Guardada en Modo Offline',
        'body': 'Tiene expedientes en cola local. Conéctese a internet para transmitir las solicitudes de crédito pendientes.',
        'severity': 'warning',
        'time': 'Ayer',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final a = alerts[index];
        IconData itemIcon;
        Color accentColor;

        switch (a['severity']) {
          case 'high':
            itemIcon = Icons.error;
            accentColor = AppColors.rojoCoral;
            break;
          case 'warning':
            itemIcon = Icons.warning;
            accentColor = AppColors.amarilloMostaza;
            break;
          case 'info':
            itemIcon = Icons.info;
            accentColor = AppColors.turquesaOscuro;
            break;
          default:
            itemIcon = Icons.notifications;
            accentColor = AppColors.azulMarino;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(itemIcon, color: accentColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              a['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.azulMarino),
                            ),
                          ),
                          Text(
                            a['time']!,
                            style: const TextStyle(color: AppColors.textoMutado, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a['body']!,
                        style: const TextStyle(color: AppColors.textoOscuro, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
