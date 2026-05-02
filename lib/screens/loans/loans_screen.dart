import 'package:flutter/material.dart';
import '../../models/loan.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  List<Loan> loans = [];

  void _addLoan() {
    final clientController = TextEditingController();
    final sellerController = TextEditingController();
    final amountController = TextEditingController();
    final interestController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nuevo Préstamo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: clientController,
                  decoration: const InputDecoration(
                    labelText: "Nombre del Cliente",
                  ),
                ),
                TextField(
                  controller: sellerController,
                  decoration: const InputDecoration(
                    labelText: "Administrador / Vendedor",
                  ),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Monto",
                  ),
                ),
                TextField(
                  controller: interestController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tasa de Interés (Ej: 0.05)",
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      dueDate = pickedDate;
                    }
                  },
                  child: const Text("Seleccionar Fecha de Vencimiento"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Guardar"),
              onPressed: () {
                if (clientController.text.isNotEmpty &&
                    sellerController.text.isNotEmpty &&
                    amountController.text.isNotEmpty &&
                    interestController.text.isNotEmpty) {
                  setState(() {
                    loans.add(
                      Loan(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        clientName: clientController.text,
                        sellerName: sellerController.text,
                        amount: double.parse(amountController.text),
                        interestRate: double.parse(interestController.text),
                        startDate: DateTime.now(),
                        dueDate: dueDate,
                        isPaid: false,
                      ),
                    );
                  });

                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor:
                loan.isPaid ? Colors.green : Colors.orange,
                child: Icon(
                  loan.isPaid
                      ? Icons.check_circle
                      : Icons.access_time,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              title: Text(
                loan.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Prestado: \$${loan.amount.toStringAsFixed(2)}"),
                  Text("Vendedor: ${loan.sellerName}"),
                  Text(
                    "Vencimiento: ${loan.dueDate.toString().substring(0, 10)}",
                  ),
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
                      color: pendiente > 0
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  Text(
                    loan.statusText,
                    style: TextStyle(
                      color: loan.isPaid
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                    Text('Detalle de ${loan.clientName}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLoan,
        child: const Icon(Icons.add),
      ),
    );
  }
}