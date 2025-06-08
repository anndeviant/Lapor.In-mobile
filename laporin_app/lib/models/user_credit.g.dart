// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_credit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserCreditAdapter extends TypeAdapter<UserCredit> {
  @override
  final int typeId = 0;

  @override
  UserCredit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserCredit(
      phoneNumber: fields[0] as String,
      creditBalance: fields[1] as double,
      lastRechargeDate: fields[2] as DateTime,
      preferredCurrency: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserCredit obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.phoneNumber)
      ..writeByte(1)
      ..write(obj.creditBalance)
      ..writeByte(2)
      ..write(obj.lastRechargeDate)
      ..writeByte(3)
      ..write(obj.preferredCurrency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCreditAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
