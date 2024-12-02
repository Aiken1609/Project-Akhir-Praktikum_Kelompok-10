// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelDonasi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DonationAdapter extends TypeAdapter<Donation> {
  @override
  final int typeId = 1;

  @override
  Donation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Donation(
      donorName: fields[0] as String,
      charityName: fields[1] as String,
      amount: fields[2] as double,
      currency: fields[3] as String,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Donation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.donorName)
      ..writeByte(1)
      ..write(obj.charityName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
