import 'package:hive/hive.dart';
part 'client.g.dart';

@HiveType(typeId: 3)
class Client extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String address;

  @HiveField(4)
  String notes;

  @HiveField(5)
  DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.notes = '',
    required this.createdAt,
  });

  // metodo útil para mostrar nombre + teléfono
  String get displayName => phone.isNotEmpty ? '$name ($phone)' : name;
}