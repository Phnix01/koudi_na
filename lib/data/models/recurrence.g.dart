// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurrenceAdapter extends TypeAdapter<Recurrence> {
  @override
  final typeId = 6;

  @override
  Recurrence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recurrence(
      id: fields[0] as String,
      libelle: fields[1] as String,
      type: fields[2] as TypeMouvement,
      montant: (fields[3] as num).toInt(),
      categorieId: fields[4] as String,
      compteId: fields[5] as String,
      jourDuMois: (fields[6] as num).toInt(),
      active: fields[7] == null ? true : fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Recurrence obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.libelle)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.montant)
      ..writeByte(4)
      ..write(obj.categorieId)
      ..writeByte(5)
      ..write(obj.compteId)
      ..writeByte(6)
      ..write(obj.jourDuMois)
      ..writeByte(7)
      ..write(obj.active);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
