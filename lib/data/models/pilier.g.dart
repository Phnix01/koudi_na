// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pilier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PilierAdapter extends TypeAdapter<Pilier> {
  @override
  final typeId = 1;

  @override
  Pilier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Pilier.epargne;
      case 1:
        return Pilier.famille;
      case 2:
        return Pilier.vie;
      default:
        return Pilier.epargne;
    }
  }

  @override
  void write(BinaryWriter writer, Pilier obj) {
    switch (obj) {
      case Pilier.epargne:
        writer.writeByte(0);
      case Pilier.famille:
        writer.writeByte(1);
      case Pilier.vie:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PilierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
