import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme.dart';

class AdvisorProductivity {
  final String name;
  final int sent;
  final int approved;
  final int disbursed;
  final double totalAmount;

  double get approvalRate => sent > 0 ? (approved / sent) * 100.0 : 0.0;

  AdvisorProductivity({
    required this.name,
    required this.sent,
    required this.approved,
    required this.disbursed,
    required this.totalAmount,
  });
}

class ReportesSupervisionScreen extends StatefulWidget {
  const ReportesSupervisionScreen({super.key});

  @override
  State<ReportesSupervisionScreen> createState() => _ReportesSupervisionScreenState();
}

class _ReportesSupervisionScreenState extends State<ReportesSupervisionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<AdvisorProductivity> _productivityData = [
    AdvisorProductivity(name: 'Aldo R.', sent: 12, approved: 9, disbursed: 8, totalAmount: 145000.0),
    AdvisorProductivity(name: 'María F.', sent: 15, approved: 14, disbursed: 12, totalAmount: 198000.0),
    AdvisorProductivity(name: 'Juan Q.', sent: 8, approved: 6, disbursed: 5, totalAmount: 75000.0),
    AdvisorProductivity(name: 'Rosa C.', sent: 10, approved: 7, disbursed: 7, totalAmount: 92000.0),
    AdvisorProductivity(name: 'Pedro M.', sent: 6, approved: 4, disbursed: 3, totalAmount: 54000.0),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportPdfReport() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CAJA AREQUIPA',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#002454'),
                          ),
                        ),
                        pw.Text(
                          'Reporte de Productividad Comercial',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColor.fromHex('#008EA7'),
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Mes: Junio 2026',
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#00C4D3')),
                pw.SizedBox(height: 20),

                // Title
                pw.Text(
                  'Desempeño de Asesores de Negocios',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#002454'),
                  ),
                ),
                pw.SizedBox(height: 15),

                // Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#002454'),
                      ),
                      children: [
                        _buildPdfCell('Asesor', isHeader: true),
                        _buildPdfCell('Enviadas', isHeader: true),
                        _buildPdfCell('Aprobadas', isHeader: true),
                        _buildPdfCell('Desembolsadas', isHeader: true),
                        _buildPdfCell('Monto Total', isHeader: true),
                        _buildPdfCell('Tasa Aprob.', isHeader: true),
                      ],
                    ),
                    // Data Rows
                    ..._productivityData.map((item) {
                      return pw.TableRow(
                        children: [
                          _buildPdfCell(item.name),
                          _buildPdfCell(item.sent.toString()),
                          _buildPdfCell(item.approved.toString()),
                          _buildPdfCell(item.disbursed.toString()),
                          _buildPdfCell('S/ ${item.totalAmount.toStringAsFixed(0)}'),
                          _buildPdfCell('${item.approvalRate.toStringAsFixed(1)} %'),
                        ],
                      );
                    }),
                  ],
                ),
                
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Documento generado electrónicamente para fines de supervisión de agencia.',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisión y Reportes'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.amarilloMostaza,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Productividad'),
            Tab(icon: Icon(Icons.map_outlined), text: 'Mapa Cobertura'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductivityTab(),
          _buildCoberturaTab(),
        ],
      ),
    );
  }

  Widget _buildProductivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Desempeño de Asesores',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turquesaOscuro,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('EXPORTAR PDF', style: TextStyle(fontSize: 12)),
                onPressed: _exportPdfReport,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Productivity Table
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.azulMarino),
                headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(label: Text('Asesor')),
                  DataColumn(label: Text('Enviadas')),
                  DataColumn(label: Text('Aprobadas')),
                  DataColumn(label: Text('Desembolsadas')),
                  DataColumn(label: Text('Monto Total')),
                  DataColumn(label: Text('Tasa Aprob.')),
                ],
                rows: _productivityData.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro))),
                      DataCell(Text(item.sent.toString(), style: const TextStyle(color: AppColors.textoOscuro))),
                      DataCell(Text(item.approved.toString(), style: const TextStyle(color: AppColors.textoOscuro))),
                      DataCell(Text(item.disbursed.toString(), style: const TextStyle(color: AppColors.textoOscuro))),
                      DataCell(Text('S/ ${item.totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.verdeCesped, fontWeight: FontWeight.w600))),
                      DataCell(Text('${item.approvalRate.toStringAsFixed(1)}%', style: const TextStyle(color: AppColors.textoOscuro))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Custom Paint Productivity Chart
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Comparativa de Solicitudes (Gráfico)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Chart Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Enviadas', AppColors.azulMarino),
                      const SizedBox(width: 16),
                      _buildLegendItem('Aprobadas', AppColors.verdeCesped),
                      const SizedBox(width: 16),
                      _buildLegendItem('Desembolsadas', AppColors.amarilloMostaza),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // The CustomPaint Chart
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: ProductivityChartPainter(_productivityData),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textoOscuro, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCoberturaTab() {
    return Column(
      children: [
        // Grid map preview of supervisor tracking
        Container(
          height: 300,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.azulMarino,
            border: Border(
              bottom: BorderSide(color: AppColors.turquesaBrillante, width: 2),
            ),
          ),
          child: CustomPaint(
            painter: CoverageMapPainter(),
          ),
        ),

        // Coverage statistics list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Estatus de Cobertura de Visitas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
              ),
              const SizedBox(height: 12),
              _buildSupervisorRow('Aldo R. (Tú)', 8, 12, 'Sincronizado hace 5 min'),
              const Divider(),
              _buildSupervisorRow('María F.', 12, 15, 'Sincronizado hace 12 min'),
              const Divider(),
              _buildSupervisorRow('Juan Q.', 5, 8, 'Sincronizado hace 1 hora'),
              const Divider(),
              _buildSupervisorRow('Rosa C.', 7, 10, 'Sincronizado hace 25 min'),
              const Divider(),
              _buildSupervisorRow('Pedro M.', 3, 6, 'Sincronizado hace 3 horas'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupervisorRow(String name, int completed, int total, String syncStatus) {
    final double pct = total > 0 ? completed / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.azulMarino,
            child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                const SizedBox(height: 4),
                Text(syncStatus, style: const TextStyle(color: AppColors.textoMutado, fontSize: 11)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: pct,
                  backgroundColor: AppColors.borde,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.turquesaOscuro),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '$completed/$total',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulMarino),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw corporate bar charts
class ProductivityChartPainter extends CustomPainter {
  final List<AdvisorProductivity> data;
  ProductivityChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final bgPaint = Paint()
      ..color = AppColors.grisClaro
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Axis paints
    final axisPaint = Paint()
      ..color = AppColors.borde
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(30, h - 30), Offset(w - 10, h - 30), axisPaint); // X Axis
    canvas.drawLine(Offset(30, 10), Offset(30, h - 30), axisPaint); // Y Axis

    // Grid lines (y = 5, 10, 15)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 5; i <= 15; i += 5) {
      double y = h - 30 - ((i / 15.0) * (h - 40));
      canvas.drawLine(Offset(30, y), Offset(w - 10, y), axisPaint);
      
      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: AppColors.textoMutado, fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(15, y - 6));
    }

    if (data.isEmpty) return;

    // Draw Bars
    final double numGroups = data.length.toDouble();
    final double groupWidth = (w - 40) / numGroups;
    final double barWidth = groupWidth * 0.22;
    final double spacing = barWidth * 0.15;

    final sentPaint = Paint()..color = AppColors.azulMarino;
    final appPaint = Paint()..color = AppColors.verdeCesped;
    final disPaint = Paint()..color = AppColors.amarilloMostaza;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final double startX = 35 + (i * groupWidth);

      // Draw Sent Bar
      double sentHeight = (item.sent / 15.0) * (h - 40);
      canvas.drawRect(
        Rect.fromLTWH(startX, h - 30 - sentHeight, barWidth, sentHeight),
        sentPaint,
      );

      // Draw Approved Bar
      double appHeight = (item.approved / 15.0) * (h - 40);
      canvas.drawRect(
        Rect.fromLTWH(startX + barWidth + spacing, h - 30 - appHeight, barWidth, appHeight),
        appPaint,
      );

      // Draw Disbursed Bar
      double disHeight = (item.disbursed / 15.0) * (h - 40);
      canvas.drawRect(
        Rect.fromLTWH(startX + 2 * (barWidth + spacing), h - 30 - disHeight, barWidth, disHeight),
        disPaint,
      );

      // Draw Label
      textPainter.text = TextSpan(
        text: item.name,
        style: const TextStyle(color: AppColors.textoOscuro, fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(startX + barWidth - 4, h - 24));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Painter for Supervisor Coverage Grid Map (HU-32)
class CoverageMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Paints
    final bgPaint = Paint()
      ..color = AppColors.azulMarino
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final gridPaint = Paint()
      ..color = AppColors.turquesaBrillante.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    // Draw grid blueprint lines
    double gridSpacing = 25.0;
    for (double x = 0; x < w; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw vector roads
    canvas.drawLine(Offset(0, h * 0.4), Offset(w, h * 0.4), roadPaint);
    canvas.drawLine(Offset(0, h * 0.8), Offset(w, h * 0.8), roadPaint);
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.3, h), roadPaint);
    canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.7, h), roadPaint);

    // Draw active advisor dots
    final List<Map<String, dynamic>> advisors = [
      {'name': 'Aldo R.', 'pos': Offset(w * 0.3, h * 0.4), 'color': AppColors.turquesaBrillante},
      {'name': 'María F.', 'pos': Offset(w * 0.7, h * 0.3), 'color': AppColors.verdeCesped},
      {'name': 'Juan Q.', 'pos': Offset(w * 0.45, h * 0.8), 'color': AppColors.amarilloMostaza},
      {'name': 'Rosa C.', 'pos': Offset(w * 0.15, h * 0.6), 'color': AppColors.naranjaOcre},
    ];

    final pulsePaint = Paint()..style = PaintingStyle.fill;
    final pinPaint = Paint()..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var adv in advisors) {
      final Offset pos = adv['pos'];
      final Color color = adv['color'];

      // Draw pulse ring
      pulsePaint.color = color.withValues(alpha: 0.25);
      canvas.drawCircle(pos, 14.0, pulsePaint);

      // Draw center core
      pinPaint.color = color;
      canvas.drawCircle(pos, 6.0, pinPaint);

      // Label background card
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 22, pos.dy - 22, 44, 13),
        const Radius.circular(3),
      );
      paintLabelCard(canvas, rect, color);

      // Label text
      textPainter.text = TextSpan(
        text: adv['name'],
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - 18, pos.dy - 21));
    }
  }

  void paintLabelCard(Canvas canvas, RRect rrect, Color borderColor) {
    final cardPaint = Paint()
      ..color = AppColors.azulMarino
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, cardPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
