import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/loan.dart';

// ==================== CARGAR LOGO ====================
Future<pw.ImageProvider> loadCompanyLogo() async {
  try {
    final ByteData data = await rootBundle.load('assets/images/logo_empresa.png');
    return pw.MemoryImage(data.buffer.asUint8List());
  } catch (e) {
    print('Error cargando el logo: $e');
    rethrow;
  }
}

// ==================== FUNCIÓN PRINCIPAL DEL PDF ====================
Future<Uint8List> generateImprovedReport({
  required List<Loan> loans,                    // Cambiado a "loans"
  String tituloReporte = "Reporte de Préstamos",
  DateTime? fechaInicio,
  DateTime? fechaFin,
}) async {
  final pdf = pw.Document();
  final logo = await loadCompanyLogo();
  final now = DateTime.now();

  // Calcular resumen
  final double totalPrestado = loans.fold(0.0, (sum, loan) => sum + (loan.montoPrestado ?? 0));
  final double totalCobrado = loans.fold(0.0, (sum, loan) => sum + (loan.montoCobrado ?? 0));
  final double totalPendiente = totalPrestado - totalCobrado;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => _buildHeader(logo, tituloReporte, now, fechaInicio, fechaFin),
      build: (context) => [
        _buildResumenGeneral(totalPrestado, totalCobrado, totalPendiente),
        pw.SizedBox(height: 25),
        _buildTableTitle(),
        pw.SizedBox(height: 10),
        _buildLoansTable(loans),
      ],
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ),
    ),
  );

  return pdf.save();
}

// ==================== ENCABEZADO CON LOGO ====================
pw.Widget _buildHeader(pw.ImageProvider logo, String titulo, DateTime now,
    DateTime? fechaInicio, DateTime? fechaFin) {
  return pw.Column(
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(logo, width: 90, height: 90),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Reporte de Préstamos', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.Text(titulo, style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text('Fecha del reporte: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}'),
              if (fechaInicio != null && fechaFin != null)
                pw.Text('Período: ${DateFormat('dd/MM/yyyy').format(fechaInicio)} - ${DateFormat('dd/MM/yyyy').format(fechaFin)}'),
            ],
          ),
        ],
      ),
      pw.Divider(thickness: 1),
      pw.SizedBox(height: 15),
    ],
  );
}

// ==================== RESUMEN GENERAL ====================
pw.Widget _buildResumenGeneral(double prestado, double cobrado, double pendiente) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Resumen General', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _summaryItem('Total Prestado', prestado, PdfColors.blue800),
            _summaryItem('Total Cobrado', cobrado, PdfColors.green800),
            _summaryItem('Total Pendiente', pendiente, PdfColors.red800),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _summaryItem(String titulo, double monto, PdfColor color) {
  return pw.Column(
    children: [
      pw.Text(titulo, style: const pw.TextStyle(fontSize: 13)),
      pw.SizedBox(height: 6),
      pw.Text('\$${monto.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: color)),
    ],
  );
}

// ==================== TÍTULO DE LA TABLA ====================
pw.Widget _buildTableTitle() {
  return pw.Text('Detalle de Préstamos',
      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold));
}

// ==================== TABLA DE PRÉSTAMOS ====================
pw.Widget _buildLoansTable(List<Loan> loans) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.8),
    columnWidths: {
      0: const pw.FlexColumnWidth(2.2),
      1: const pw.FlexColumnWidth(1.4),
      2: const pw.FlexColumnWidth(1.6),
      3: const pw.FlexColumnWidth(1.6),
      4: const pw.FlexColumnWidth(1.6),
      5: const pw.FlexColumnWidth(1.3),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blueGrey200),
        children: ['Cliente', 'Fecha', 'Prestado', 'Cobrado', 'Pendiente', 'Estado']
            .map((text) => pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ))
            .toList(),
      ),
      ...loans.asMap().entries.map((entry) {
        final index = entry.key;
        final loan = entry.value;
        final pendiente = (loan.montoPrestado ?? 0) - (loan.montoCobrado ?? 0);
        final estado = pendiente <= 0 ? 'Pagado' : 'Pendiente';

        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: index % 2 == 0 ? PdfColors.white : PdfColors.grey50,
          ),
          children: [
            _tableCell(loan.nombreCliente ?? 'Sin nombre'),
            _tableCell(DateFormat('dd/MM/yyyy').format(loan.dueDate)),
            _tableCell('\$${(loan.montoPrestado ?? 0).toStringAsFixed(2)}', align: pw.TextAlign.right),
            _tableCell('\$${(loan.montoCobrado ?? 0).toStringAsFixed(2)}', align: pw.TextAlign.right),
            _tableCell('\$${pendiente.toStringAsFixed(2)}',
                align: pw.TextAlign.right,

                color: pendiente > 0 ? PdfColors.red700 : PdfColors.green700),
            _tableCell(estado, color: estado == 'Pagado' ? PdfColors.green800 : PdfColors.orange800),
          ],
        );
      }),
    ],
  );
}

pw.Widget _tableCell(String text, {pw.TextAlign align = pw.TextAlign.left, PdfColor? color}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(9),
    child: pw.Text(
      text,
      textAlign: align,
      style: color != null ? pw.TextStyle(color: color) : null,
    ),
  );
}