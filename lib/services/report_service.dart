import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/loan.dart';
import '../services/database_service.dart';

class ReportService {


  // ==================== GENERAR Y COMPARTIR PDF ====================
  static Future<void> generateAndSharePDF() async {
    final loans = DatabaseService.getLoansBox().values.toList();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Reporte Financiero - CréditosPro',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            context: context,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            data: <List<String>>[
              ['Cliente', 'Vendedor', 'Monto', 'Interés', 'Pagado', 'Pendiente', 'Estado'],
              ...loans.map((loan) => [
                loan.clientName,
                loan.sellerName,
                '\$${loan.amount.toStringAsFixed(2)}',
                '\$${loan.totalInterest.toStringAsFixed(2)}',
                '\$${loan.totalPaid.toStringAsFixed(2)}',
                '\$${loan.remaining.toStringAsFixed(2)}',
                loan.statusText,
              ]),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Text(
            'Total Prestado: \$${loans.fold(0.0, (sum, l) => sum + l.amount).toStringAsFixed(2)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Total Pendiente: \$${loans.fold(0.0, (sum, l) => sum + l.remaining).toStringAsFixed(2)}',
          ),
        ],
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/reporte_creditos_${DateTime.now().millisecondsSinceEpoch}.pdf');

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Reporte Financiero - CréditosPro',
    );
  }

  // ==================== GENERAR Y COMPARTIR CSV ====================
  static Future<void> generateAndShareCSV() async {
    final loans = DatabaseService.getLoansBox().values.toList();

    List<List<dynamic>> rows = [
      ['Cliente', 'Vendedor', 'Monto', 'Tasa (%)', 'Fecha Inicio', 'Vencimiento', 'Total a Pagar', 'Pagado', 'Pendiente', 'Estado'],
    ];

    for (var loan in loans) {
      rows.add([
        loan.clientName,
        loan.sellerName,
        loan.amount,
        loan.interestRate,
        loan.startDate.toIso8601String(),
        loan.dueDate.toIso8601String(),
        loan.totalToPay,
        loan.totalPaid,
        loan.remaining,
        loan.statusText,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/reporte_creditos_${DateTime.now().millisecondsSinceEpoch}.csv');

    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Reporte CSV - CréditosPro',
    );
  }
}