import 'package:creditosmercado/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../providers/loan_provider.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required UserType userType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);
    final totalLoaned = ref.watch(totalLoanedProvider);
    final totalCollected = ref.watch(totalCollectedProvider);
    final totalPending = ref.watch(totalPendingProvider);
    final overdueCount = ref.watch(overdueCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CréditosPro'),
      ),
      body: loansAsync.when(
        data: (loans) => RefreshIndicator(
          onRefresh: () async => ref.refresh(loansProvider),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjetas de resumen
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Prestado',
                        value: '\$${totalLoaned.toStringAsFixed(2)}',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SummaryCard(
                        title: 'Cobrado',
                        value: '\$${totalCollected.toStringAsFixed(2)}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Pendiente',
                        value: '\$${totalPending.toStringAsFixed(2)}',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SummaryCard(
                        title: 'Vencidos',
                        value: overdueCount.toString(),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('Distribución de Préstamos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: totalCollected,
                          color: Colors.green,
                          title: 'Cobrado',
                        ),
                        PieChartSectionData(
                          value: totalPending,
                          color: Colors.orange,
                          title: 'Pendiente',
                        ),
                      ],
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => GoRouter.of(context).push('/new-loan'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Préstamo'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Préstamos'),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Rutas'),
        ],
        onTap: (index) {
          if (index == 1) GoRouter.of(context).push('/loans');
          if (index == 2) GoRouter.of(context).push('/routes');
        },
      ),
    );
  }
}