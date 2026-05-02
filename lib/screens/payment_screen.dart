import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/loan.dart';
import '../models/payment.dart';
import '../services/database_service.dart';
import '../providers/loan_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String loanId;
  const PaymentScreen({super.key, required this.loanId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final loanAsync = ref.watch(loansProvider.select((asyncLoans) {
      return asyncLoans.whenData((loans) => loans.firstWhere((l) => l.id == widget.loanId));
    }));

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Pago')),
      body: loanAsync.when(
        data: (loan) {
          final remaining = loan.remaining;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cliente: ${loan.clientName}', style: Theme.of(context).textTheme.titleLarge),
                Text('Pendiente actual: \$${remaining.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monto a pagar (\$)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notas (opcional)', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _registerPayment(loan, double.tryParse(amountCtrl.text) ?? 0, false),
                        child: const Text('Pago Parcial'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _registerPayment(loan, remaining, true),
                        child: const Text('Pago Total'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Préstamo no encontrado')),
      ),
    );
  }

  Future<void> _registerPayment(Loan loan, double amount, bool isTotal) async {
    if (amount <= 0 || amount > loan.remaining) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monto inválido')));
      return;
    }

    final payment = Payment(
      id: _uuid.v4(),
      amount: amount,
      date: DateTime.now(),
      notes: notesCtrl.text.trim(),
    );

    loan.payments.add(payment);
    if (isTotal || loan.remaining - amount <= 0.01) {
      loan.isPaid = true;
    }

    final box = DatabaseService.getLoansBox();
    await box.put(loan.id, loan);

    ref.invalidate(loansProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pago de \$${amount.toStringAsFixed(2)} registrado')));
      Navigator.pop(context);
    }
  }
}