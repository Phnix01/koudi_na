// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategorieAdapter extends TypeAdapter<Categorie> {
  @override
  final typeId = 4;

  @override
  Categorie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Categorie(
      id: fields[0] as String,
      libelle: fields[1] as String,
      type: fields[2] as TypeMouvement,
      iconeCode: fields[3] as String,
      couleurHex: fields[4] as String,
      pilier: fields[5] as Pilier?,
      ordre: fields[6] == null ? 0 : (fields[6] as num).toInt(),
      active: fields[7] == null ? true : fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Categorie obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.pilier)
      ..writeByte(6)
      ..write(obj.ordre)
      ..writeByte(7)
      ..write(obj.active);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
