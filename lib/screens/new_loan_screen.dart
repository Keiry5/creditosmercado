import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/loan.dart';
import '../services/database_service.dart';
import '../providers/loan_provider.dart';

class NewLoanScreen extends ConsumerStatefulWidget {
  const NewLoanScreen({super.key});

  @override
  ConsumerState<NewLoanScreen> createState() => _NewLoanScreenState();
}

class _NewLoanScreenState extends ConsumerState<NewLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final clientNameCtrl = TextEditingController();
  final sellerNameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final interestRateCtrl = TextEditingController(text: '20'); // 20% por defecto

  DateTime startDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(const Duration(days: 30));

  double calculatedInterest = 0.0;
  double totalToPay = 0.0;

  void _calculateInterest() {
    final amount = double.tryParse(amountCtrl.text) ?? 0;
    final rate = double.tryParse(interestRateCtrl.text) ?? 0;
    final days = dueDate.difference(startDate).inDays;

    setState(() {
      calculatedInterest = amount * (rate / 100) * (days / 365);
      totalToPay = amount + calculatedInterest;
    });
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(amountCtrl.text);
    final rate = double.parse(interestRateCtrl.text);

    final newLoan = Loan(
      id: _uuid.v4(),
      clientName: clientNameCtrl.text.trim(),
      sellerName: sellerNameCtrl.text.trim(),
      amount: amount,
      interestRate: rate,
      startDate: startDate,
      dueDate: dueDate,
      payments: [],
      isPaid: false,
    );

    final box = DatabaseService.getLoansBox();
    await box.put(newLoan.id, newLoan);

    ref.invalidate(loansProvider); // Actualiza el dashboard

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préstamo registrado exitosamente')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    amountCtrl.addListener(_calculateInterest);
    interestRateCtrl.addListener(_calculateInterest);
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    interestRateCtrl.dispose();
    clientNameCtrl.dispose();
    sellerNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Préstamo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: clientNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Cliente', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: sellerNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Vendedor', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto Prestado (\$)', border: OutlineInputBorder()),
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Monto inválido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: interestRateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tasa de Interés (%)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // Selector de fechas
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Fecha Inicio'),
                      subtitle: Text('${startDate.toLocal()}'.split(' ')[0]),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (picked != null) {
                          setState(() => startDate = picked);
                          _calculateInterest();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Fecha Vencimiento'),
                      subtitle: Text('${dueDate.toLocal()}'.split(' ')[0]),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: dueDate, firstDate: startDate, lastDate: DateTime(2030));
                        if (picked != null) {
                          setState(() => dueDate = picked);
                          _calculateInterest();
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cálculo Automático', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Interés: \$${calculatedInterest.toStringAsFixed(2)}'),
                      Text('Total a pagar: \$${totalToPay.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveLoan,
                  child: const Text('Registrar Préstamo', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}