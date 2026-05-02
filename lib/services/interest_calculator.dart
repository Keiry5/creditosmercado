import 'package:intl/intl.dart';
import '../models/loan.dart';

class InterestCalculator {
  /// Calcular el interés total simple entre dos fechas
  static double calculateSimpleInterest({
    required double principal,
    required double annualRate,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final days = endDate.difference(startDate).inDays;
    if (days <= 0) return 0.0;

    // Interés simple: Capital × Tasa × Tiempo
    return principal * (annualRate / 100) * (days / 365);
  }

  /// Calcular interés para un préstamo completo
  static double calculateLoanInterest(Loan loan) {
    return calculateSimpleInterest(
      principal: loan.amount,
      annualRate: loan.interestRate,
      startDate: loan.startDate,
      endDate: loan.dueDate,
    );
  }

  /// Calcular monto total a pagar (capital + interés)
  static double calculateTotalToPay(Loan loan) {
    final interest = calculateLoanInterest(loan);
    return loan.amount + interest;
  }

  /// Calcular monto pendiente actual
  static double calculateRemaining(Loan loan) {
    final totalToPay = calculateTotalToPay(loan);
    final totalPaid = loan.payments.fold(0.0, (sum, payment) => sum + payment.amount);
    return (totalToPay - totalPaid).clamp(0.0, double.infinity);
  }

  /// Verificacion de préstamo está vencido
  static bool isOverdue(Loan loan) {
    return !loan.isPaid && DateTime.now().isAfter(loan.dueDate);
  }

  /// Formatea el interés de forma legible
  static String formatInterest(double interest) {
    return NumberFormat.currency(
      locale: 'es_SV',
      symbol: '\$',
      decimalDigits: 2,
    ).format(interest);
  }

  /// Formatea el monto total
  static String formatAmount(double amount) {
    return NumberFormat.currency(
      locale: 'es_SV',
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  /// Calcula mora (interés por día después del vencimiento)
  static double calculateLateFee({
    required Loan loan,
    double dailyLateRate = 0.5, // 0.5% por día de mora por defecto
  }) {
    if (!isOverdue(loan)) return 0.0;

    final daysLate = DateTime.now().difference(loan.dueDate).inDays;
    if (daysLate <= 0) return 0.0;

    final remainingCapital = loan.amount - loan.totalPaid;

    return remainingCapital * (dailyLateRate / 100) * daysLate;
  }
}