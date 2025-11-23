// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PillAdapter extends TypeAdapter<Pill> {
  @override
  final int typeId = 0;

  @override
  Pill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pill(
      id: fields[0] as String,
      userId: fields[1] as String?,
      name: fields[2] as String,
      color: fields[3] as String,
      brand: fields[4] as String?,
      icon: fields[5] as String,
      dailyIntakeCount: fields[6] as int,
      notificationEnabled: fields[7] as bool,
      notificationTimes: (fields[8] as List?)?.cast<String>(),
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Pill obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.brand)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.dailyIntakeCount)
      ..writeByte(7)
      ..write(obj.notificationEnabled)
      ..writeByte(8)
      ..write(obj.notificationTimes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
