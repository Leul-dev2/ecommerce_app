import 'package:hive/hive.dart';

part 'payment_method_model.g.dart';

@HiveType(typeId: 0) // Unique typeId per model
class PaymentMethodModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String brand;

  @HiveField(2)
  final String last4;

  @HiveField(3)
  final int expMonth;

  @HiveField(4)
  final int expYear;

  PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final card = json['card'] ?? json; // supports { card: {...} } or direct
    return PaymentMethodModel(
      id: json['id'] ?? '',
      brand: card['brand'] ?? 'Unknown',
      last4: card['last4'] ?? '****',
      expMonth: card['exp_month'] ?? 0,
      expYear: card['exp_year'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
    };
  }

  PaymentMethodModel copyWith({
    String? id,
    String? brand,
    String? last4,
    int? expMonth,
    int? expYear,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          brand == other.brand &&
          last4 == other.last4 &&
          expMonth == other.expMonth &&
          expYear == other.expYear;

  @override
  int get hashCode =>
      id.hashCode ^ brand.hashCode ^ last4.hashCode ^ expMonth.hashCode ^ expYear.hashCode;
}
