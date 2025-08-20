// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 1;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.shortTerm;
      case 1:
        return GoalType.mediumTerm;
      case 2:
        return GoalType.longTerm;
      default:
        return GoalType.shortTerm;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.shortTerm:
        writer.writeByte(0);
        break;
      case GoalType.mediumTerm:
        writer.writeByte(1);
        break;
      case GoalType.longTerm:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavingsGoalAdapter extends TypeAdapter<SavingsGoal> {
  @override
  final int typeId = 2;

  @override
  SavingsGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsGoal(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      targetAmount: fields[3] as double,
      currentAmount: fields[4] as double,
      createdDate: fields[5] as DateTime,
      targetDate: fields[6] as DateTime,
      type: fields[7] as GoalType,
      iconPath: fields[8] as String?,
      isCompleted: fields[9] as bool,
      completedDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsGoal obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.currentAmount)
      ..writeByte(5)
      ..write(obj.createdDate)
      ..writeByte(6)
      ..write(obj.targetDate)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.iconPath)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.completedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}