import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan.dart';
import '../providers/loan_provider.dart';
import 'package:go_router/go_router.dart';

class LoanListScreen extends ConsumerStatefulWidget {
  const LoanListScreen({super.key});

  @override
  ConsumerState<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends ConsumerState<LoanListScreen> {
  String searchQuery = '';
  String filter = 'Todos'; // Todos, Pendientes, Pagados, Vencidos

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Préstamos')),
      body: loansAsync.when(
        data: (loans) {
          // Filtrado
          var filteredLoans = loans.where((loan) {
            final matchesSearch = loan.clientName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                loan.sellerName.toLowerCase().contains(searchQuery.toLowerCase());
            if (!matchesSearch) return false;

            if (filter == 'Pendientes') return !loan.isPaid;
            if (filter == 'Pagados') return loan.isPaid;
            if (filter == 'Vencidos') return loan.isOverdue && !loan.isPaid;
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar por cliente o vendedor...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Todos', label: Text('Todos')),
                    ButtonSegment(value: 'Pendientes', label: Text('Pendientes')),
                    ButtonSegment(value: 'Pagados', label: Text('Pagados')),
                    ButtonSegment(value: 'Vencidos', label: Text('Vencidos')),
                  ],
                  selected: {filter},
                  onSelectionChanged: (set) => setState(() => filter = set.first),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLoans.length,
                  itemBuilder: (context, index) {
                    final loan = filteredLoans[index];
                    final color = loan.isPaid ? Colors.green : (loan.isOverdue ? Colors.red : Colors.orange);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: color, child: Text(loan.clientName[0].toUpperCase())),
                        title: Text(loan.clientName),
                        subtitle: Text('${loan.sellerName} • \$${loan.amount.toStringAsFixed(2)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${loan.remaining.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                            Text(loan.isPaid ? 'Pagado' : (loan.isOverdue ? 'Vencido' : 'Pendiente')),
                          ],
                        ),
                        onTap: () => context.push('/payment/${loan.id}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-loan'),
        child: const Icon(Icons.add),
      ),
    );
  }
}