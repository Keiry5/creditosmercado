import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';
import '../services/database_service.dart';

final visitsProvider = FutureProvider<List<Visit>>((ref) async {
  final box = DatabaseService.getVisitsBox();
  return box.values.toList()..sort((a, b) => a.visitDate.compareTo(b.visitDate));
});

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key});

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> {
  final _uuid = const Uuid();
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> _addNewVisit() async {
    String clientName = '';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Visita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
              onChanged: (value) => clientName = value,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha y hora'),
              subtitle: Text(dateFormat.format(selectedDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDate),
                  );
                  if (time != null) {
                    setState(() {
                      selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (clientName.trim().isEmpty) return;

              final newVisit = Visit(
                id: _uuid.v4(),
                clientName: clientName.trim(),
                visitDate: selectedDate,
                notes: '',
                completed: false,
              );

              final box = DatabaseService.getVisitsBox();
              await box.put(newVisit.id, newVisit);

              if (mounted) {
                Navigator.pop(context);
                ref.invalidate(visitsProvider);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(visitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rutas y Visitas')),
      body: visitsAsync.when(
        data: (visits) => visits.isEmpty
            ? const Center(child: Text('No hay visitas programadas\nPresiona + para agregar'))
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: visits.length,
          itemBuilder: (context, index) {
            final visit = visits[index];
            final isPast = visit.visitDate.isBefore(DateTime.now());

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(
                  visit.completed
                      ? Icons.check_circle
                      : (isPast ? Icons.warning : Icons.calendar_today),
                  color: visit.completed
                      ? Colors.green
                      : (isPast ? Colors.red : Colors.blue),
                ),
                title: Text(visit.clientName),
                subtitle: Text(dateFormat.format(visit.visitDate)),
                trailing: Checkbox(
                  value: visit.completed,
                  onChanged: (value) async {
                    visit.completed = value ?? false;
                    await visit.save();
                    ref.invalidate(visitsProvider);
                  },
                ),
                onTap: () {
                  // Puedes expandir aquí para editar notas
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewVisit,
        child: const Icon(Icons.add),
      ),
    );
  }
}