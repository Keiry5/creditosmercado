part of 'visit.dart';

class VisitAdapter extends TypeAdapter<Visit> {
  @override
  final int typeId = 2;

  @override
  Visit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Visit(
      id: fields[0] as String,
      clientName: fields[1] as String,
      visitDate: fields[2] as DateTime,
      notes: fields[3] as String,
      completed: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Visit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientName)
      ..writeByte(2)
      ..write(obj.visitDate)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VisitAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}