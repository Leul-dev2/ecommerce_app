// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentMethodModelAdapter extends TypeAdapter<PaymentMethodModel> {
  @override
  final int typeId = 1;

  @override
  PaymentMethodModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentMethodModel(
      id: fields[0] as String,
      brand: fields[1] as String,
      last4: fields[2] as String,
      expMonth: fields[3] as int,
      expYear: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentMethodModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.last4)
      ..writeByte(3)
      ..write(obj.expMonth)
      ..writeByte(4)
      ..write(obj.expYear);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
