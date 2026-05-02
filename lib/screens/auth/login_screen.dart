import 'package:flutter/material.dart';
import '../../models/loan.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {

  List<Loan> loans = [
    Loan(
      id: '1',
      clientName: "Juan Pérez",
      sellerName: "Administrador",
      amount: 15000,
      interestRate: 0.05,
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      dueDate: DateTime.now().add(const Duration(days: 15)),
      isPaid: false,
    ),
    Loan(
      id: '2',
      clientName: "María López",
      sellerName: "Administrador",
      amount: 25000,
      interestRate: 0.04,
      startDate: DateTime.now().subtract(const Duration(days: 45)),
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      isPaid: true,
    ),
    Loan(
      id: '3',
      clientName: "Carlos Ramírez",
      sellerName: "Vendedor 1",
      amount: 8000,
      interestRate: 0.06,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(days: 25)),
      isPaid: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Préstamos")),
      body: loans.isEmpty
          ? const Center(child: Text("No hay préstamos registrados"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          final loan = loans[index];
          final pendiente = loan.remaining;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: loan.isPaid ? Colors.green : Colors.orange,
                child: Icon(
                  loan.isPaid ? Icons.check_circle : Icons.access_time,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              title: Text(
                loan.clientName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Prestado: \$${loan.amount.toStringAsFixed(2)}"),
                  Text("Vencimiento: ${loan.dueDate.toString().substring(0, 10)}"),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${pendiente.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: pendiente > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  Text(
                    loan.statusText,
                    style: TextStyle(
                      color: loan.isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Detalle de ${loan.clientName}')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nuevo préstamo - Próximamente')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}