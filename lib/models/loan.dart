import 'package:creditosmercado/models/payment.dart';
import 'package:hive/hive.dart';
import '../services/interest_calculator.dart';

part 'loan.g.dart';

@HiveType(typeId: 0)
class Loan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String clientName;

  @HiveField(2)
  String sellerName;

  @HiveField(3)
  double amount;

  @HiveField(4)
  double interestRate;

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  DateTime dueDate;

  @HiveField(7)
  List<Payment> payments;

  @HiveField(8)
  bool isPaid;

  Loan({
    required this.id,
    required this.clientName,
    required this.sellerName,
    required this.amount,
    required this.interestRate,
    required this.startDate,
    required this.dueDate,
    List<Payment>? payments,
    this.isPaid = false,
  }) : payments = payments ?? <Payment>[];

  // Getters útiles
  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);

  double get remaining {
    final interest = InterestCalculator.calculateLoanInterest(this);
    return (amount + interest) - totalPaid;
  }

  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);

  String get statusText {
    if (isPaid) return 'Pagado';
    if (isOverdue) return 'Vencido';
    return 'Pendiente';
  }

  // Getters para compatibilidad con el PDF y pantallas
  String get nombreCliente => clientName;
  double get montoPrestado => amount;
  double get montoCobrado => totalPaid;
  DateTime get fecha => startDate;
  String get estado => statusText;

  get totalInterest => null;

  get totalToPay => null;
}