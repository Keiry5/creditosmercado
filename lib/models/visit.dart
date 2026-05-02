import 'package:hive/hive.dart';
part 'visit.g.dart';

@HiveType(typeId: 2)
class Visit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clientName;

  @HiveField(2)
  final DateTime visitDate;

  @HiveField(3)
  final String notes;

  @HiveField(4)
  bool completed;

  Visit({
    required this.id,
    required this.clientName,
    required this.visitDate,
    this.notes = '',
    this.completed = false,
  });
}