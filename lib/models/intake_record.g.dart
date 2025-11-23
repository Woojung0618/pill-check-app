// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntakeRecordAdapter extends TypeAdapter<IntakeRecord> {
  @override
  final int typeId = 1;

  @override
  IntakeRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IntakeRecord(
      id: fields[0] as String,
      userId: fields[1] as String?,
      pillId: fields[2] as String,
      date: fields[3] as DateTime,
      intakeCount: fields[4] as int,
      checkedAt: fields[5] as DateTime,
      createdAt: fields[6] as DateTime,
      isLocal: fields[7] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, IntakeRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.pillId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.intakeCount)
      ..writeByte(5)
      ..write(obj.checkedAt)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isLocal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntakeRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
