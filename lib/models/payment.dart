import 'package:hive/hive.dart';
part 'payment.g.dart';

@HiveType(typeId: 1)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String notes;

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    this.notes = '',
  });
}