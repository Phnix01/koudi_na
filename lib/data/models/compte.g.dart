// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compte.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompteAdapter extends TypeAdapter<Compte> {
  @override
  final typeId = 5;

  @override
  Compte read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Compte(
      id: fields[0] as String,
      libelle: fields[1] as String,
      type: fields[2] as TypeCompte,
      iconeCode: fields[3] as String,
      couleurHex: fields[4] as String,
      soldeInitial: fields[5] == null ? 0 : (fields[5] as num).toInt(),
      actif: fields[6] == null ? true : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Compte obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.libelle)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.iconeCode)
      ..writeByte(4)
      ..write(obj.couleurHex)
      ..writeByte(5)
      ..write(obj.soldeInitial)
      ..writeByte(6)
      ..write(obj.actif);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TypeCompteAdapter extends TypeAdapter<TypeCompte> {
  @override
  final typeId = 2;

  @override
  TypeCompte read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TypeCompte.especes;
      case 1:
        return TypeCompte.banque;
      case 2:
        return TypeCompte.mobileMoney;
      case 3:
        return TypeCompte.epargne;
      default:
        return TypeCompte.especes;
    }
  }

  @override
  void write(BinaryWriter writer, TypeCompte obj) {
    switch (obj) {
      case TypeCompte.especes:
        writer.writeByte(0);
      case TypeCompte.banque:
        writer.writeByte(1);
      case TypeCompte.mobileMoney:
        writer.writeByte(2);
      case TypeCompte.epargne:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeCompteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
