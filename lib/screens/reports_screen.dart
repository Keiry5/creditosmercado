import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../core/utils/pdf_generator.dart';
import '../models/loan.dart';
import '../services/report_service.dart'; // si lo necesitas

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {

  // Lista de préstamos (cámbialo según cómo obtengas los datos)
  List<Loan> loans = [];   // ← Aquí debes cargar tus préstamos

  Future<void> _generatePDF() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      print("✅ Iniciando generación de PDF...");

      if (loans.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No hay préstamos para generar el reporte')),
        );
        return;
      }

      final pdfBytes = await generateImprovedReport(
        loans: loans,
        tituloReporte: "Reporte General de Préstamos",
      );

      await Printing.layoutPdf(
        onLayout: (format) => Future.value(pdfBytes),
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ PDF generado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      print("❌ ERROR al generar PDF: $e");
      print("Stack trace: $stackTrace");

      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar Reporte en PDF'),
              onPressed: _generatePDF,           // ← Cambiado
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.table_chart),
              label: const Text('Generar y Compartir CSV'),
              onPressed: ReportService.generateAndShareCSV,
            ),
          ],
        ),
      ),
    );
  }
}