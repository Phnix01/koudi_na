// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_mouvement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeMouvementAdapter extends TypeAdapter<TypeMouvement> {
  @override
  final typeId = 0;

  @override
  TypeMouvement read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TypeMouvement.depense;
      case 1:
        return TypeMouvement.entree;
      default:
        return TypeMouvement.depense;
    }
  }

  @override
  void write(BinaryWriter writer, TypeMouvement obj) {
    switch (obj) {
      case TypeMouvement.depense:
        writer.writeByte(0);
      case TypeMouvement.entree:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeMouvementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
