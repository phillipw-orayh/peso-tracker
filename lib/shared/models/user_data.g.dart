// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 3;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      monthlyIncome: fields[3] as double,
      monthlyBudget: fields[4] as double,
      preferredLanguage: fields[5] as String,
      currentStreak: fields[6] as int,
      longestStreak: fields[7] as int,
      lastActiveDate: fields[8] as DateTime,
      completedChallenges: (fields[9] as List).cast<String>(),
      earnedBadges: (fields[10] as List).cast<String>(),
      totalPoints: fields[11] as int,
      settings: (fields[12] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.monthlyIncome)
      ..writeByte(4)
      ..write(obj.monthlyBudget)
      ..writeByte(5)
      ..write(obj.preferredLanguage)
      ..writeByte(6)
      ..write(obj.currentStreak)
      ..writeByte(7)
      ..write(obj.longestStreak)
      ..writeByte(8)
      ..write(obj.lastActiveDate)
      ..writeByte(9)
      ..write(obj.completedChallenges)
      ..writeByte(10)
      ..write(obj.earnedBadges)
      ..writeByte(11)
      ..write(obj.totalPoints)
      ..writeByte(12)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}