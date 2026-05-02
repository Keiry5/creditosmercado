import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan.dart';
import '../services/database_service.dart';

final loansProvider = FutureProvider<List<Loan>>((ref) async {
  final box = DatabaseService.getLoansBox();
  return box.values.toList();
});

final totalLoanedProvider = Provider<double>((ref) {
  final loans = ref.watch(loansProvider).value ?? [];
  return loans.fold(0.0, (sum, loan) => sum + loan.amount);
});

final totalCollectedProvider = Provider<double>((ref) {
  final loans = ref.watch(loansProvider).value ?? [];
  return loans.fold(0.0, (sum, loan) => sum + loan.totalPaid);
});

final totalPendingProvider = Provider<double>((ref) {
  final loans = ref.watch(loansProvider).value ?? [];
  return loans.fold(0.0, (sum, loan) => sum + (loan.remaining > 0 ? loan.remaining : 0));
});

final overdueCountProvider = Provider<int>((ref) {
  final loans = ref.watch(loansProvider).value ?? [];
  return loans.where((loan) => loan.isOverdue && !loan.isPaid).length;
});