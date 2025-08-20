// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeTypeAdapter extends TypeAdapter<ChallengeType> {
  @override
  final int typeId = 4;

  @override
  ChallengeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeType.daily;
      case 1:
        return ChallengeType.weekly;
      case 2:
        return ChallengeType.monthly;
      default:
        return ChallengeType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeType obj) {
    switch (obj) {
      case ChallengeType.daily:
        writer.writeByte(0);
        break;
      case ChallengeType.weekly:
        writer.writeByte(1);
        break;
      case ChallengeType.monthly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeCategoryAdapter extends TypeAdapter<ChallengeCategory> {
  @override
  final int typeId = 5;

  @override
  ChallengeCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeCategory.spending;
      case 1:
        return ChallengeCategory.savings;
      case 2:
        return ChallengeCategory.goals;
      case 3:
        return ChallengeCategory.habits;
      case 4:
        return ChallengeCategory.social;
      default:
        return ChallengeCategory.spending;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeCategory obj) {
    switch (obj) {
      case ChallengeCategory.spending:
        writer.writeByte(0);
        break;
      case ChallengeCategory.savings:
        writer.writeByte(1);
        break;
      case ChallengeCategory.goals:
        writer.writeByte(2);
        break;
      case ChallengeCategory.habits:
        writer.writeByte(3);
        break;
      case ChallengeCategory.social:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeAdapter extends TypeAdapter<Challenge> {
  @override
  final int typeId = 6;

  @override
  Challenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Challenge(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as ChallengeType,
      category: fields[4] as ChallengeCategory,
      requirements: (fields[5] as Map).cast<String, dynamic>(),
      pointsReward: fields[6] as int,
      badgeReward: fields[7] as String?,
      icon: fields[8] as String,
      isActive: fields[9] as bool,
      activatedDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Challenge obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.requirements)
      ..writeByte(6)
      ..write(obj.pointsReward)
      ..writeByte(7)
      ..write(obj.badgeReward)
      ..writeByte(8)
      ..write(obj.icon)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.activatedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserChallengeAdapter extends TypeAdapter<UserChallenge> {
  @override
  final int typeId = 7;

  @override
  UserChallenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserChallenge(
      id: fields[0] as String,
      challengeId: fields[1] as String,
      enrolledDate: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
      completedDate: fields[4] as DateTime?,
      progress: (fields[5] as Map).cast<String, dynamic>(),
      currentStreak: fields[6] as int,
      lastActivityDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserChallenge obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.challengeId)
      ..writeByte(2)
      ..write(obj.enrolledDate)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedDate)
      ..writeByte(5)
      ..write(obj.progress)
      ..writeByte(6)
      ..write(obj.currentStreak)
      ..writeByte(7)
      ..write(obj.lastActivityDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeAdapter extends TypeAdapter<Badge> {
  @override
  final int typeId = 8;

  @override
  Badge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Badge(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      icon: fields[3] as String,
      color: fields[4] as String,
      earnedDate: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Badge obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.earnedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}